import 'package:BlindSightApp/components/order_traking_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    } else {
        err = SnackBar(content: Text("Unkown error occured!"));
    }

    if (err != null) ScaffoldMessenger.of(context).showSnackBar(err);
}
