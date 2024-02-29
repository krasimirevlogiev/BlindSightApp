import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:BlindSightApp/components/blindsense.dart';
import 'package:BlindSightApp/components/order_traking_page.dart';
import 'package:BlindSightApp/utils/camera.dart';
import 'package:BlindSightApp/utils/auth_utils.dart';
import 'package:BlindSightApp/utils/types.dart';

import 'package:BlindSightApp/components/login_screen.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          String? userJSON = snapshot.data as String?;
          User? user;

          if (userJSON != null && userJSON.isNotEmpty) {
            user = User.fromJson(jsonDecode(userJSON) as Map<String, dynamic>);

            if (user.fname!.isEmpty ||
                user.lname!.isEmpty ||
                user.email!.isEmpty ||
                user.username!.isEmpty ||
                user.password!.isEmpty) {
              user = null;
              userJSON = null;
            }
          }

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Image.asset("assets/blindsight_logo.png"),
                    )),
                ListTile(
                  title: Text('BlindSense'),
                  onTap: () async {
                    final camera = await initCamera();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              BlindSense(camera: camera)),
                    );
                  },
                ),
                ListTile(
                  title: Text('Tracker'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderTrackingPage()),
                    );
                  },
                ),
                if (user != null)
                  ListTile(
                    title: Text(user.fname! + " " + user.lname!),
                    onTap: () async {
                      // TODO: Add link to profile page. For now it only logs user out
                      user = null;
                      userJSON = null;
                      await logout();

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPage(title: 'Login')));
                    },
                  )
                else
                  ListTile(
                      title: Text("Login"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    LoginPage(title: 'Login')));
                      })
              ],
            ),
          );
        });
  }
}
