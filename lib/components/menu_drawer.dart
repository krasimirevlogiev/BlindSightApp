import 'package:flutter/material.dart';
import 'package:BlindSightApp/components/camera_page.dart';
import 'package:BlindSightApp/components/order_traking_page.dart';
import 'package:BlindSightApp/utils/camera.dart';

class MenuDrawer extends StatelessWidget {
    
    @override
    Widget build(BuildContext context) {
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
              )
            ),
            ListTile(
              title: Text('BlindSight Guidance'),
              onTap: () async {
                final camera = await initCamera();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BlindSightGuidance(camera: camera)),
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
          ],
        ),
      );
    }
}
