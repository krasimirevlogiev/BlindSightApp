import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BlindSightApp/components/order_traking_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

Future<String?> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final result = await prefs.getString("blindsight-user");

    return result;
}

Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("blindsight-user");

    return;
}

Future<String> getUsers() async {
    // TODO: put server IP in environment variable
    var response = await http.get(Uri.parse("http://10.0.2.2:3000/users"));

    return response.body;
}

bool isUniqueEmail(List<dynamic> users, String email) {

    for (int i = 0; i < users.length; i++) {
        if (users[i]['email'] == email) {
            return false;
        }
    }
    return true;
}

bool isUniqueUsername(List<dynamic> users, String username) {

    for (int i = 0; i < users.length; i++) {
        if (users[i]['username'] == username) {
            return false;
        }
    }
    return true;
}

Future<void> authenticate(BuildContext context, StreamedResponse response) async {

    SnackBar? err;

    // NOTE: Status code 201 means something has been CREATED.
    if (response.statusCode == 201) {
        final userJSON = await response.stream.bytesToString();

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("blindsight-user", userJSON);

        Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => OrderTrackingPage())
        );

    } else if (response.statusCode == 202) {
        err = SnackBar(content: Text("Verification code must be a number!"));

    } else if (response.statusCode == 203 || response.statusCode == 204) {
        err = SnackBar(content: Text("Wrong code! Please try again!"));

    } else if (response.statusCode == 205) {
        err = SnackBar(content: Text("Wrong credentials!"));

    } else {
        err = SnackBar(content: Text("Unkown error occured!"));
    }

    if (err != null) ScaffoldMessenger.of(context).showSnackBar(err);
}
