import 'dart:convert';

import 'package:BlindSightApp/components/menu_drawer.dart';
import 'package:BlindSightApp/components/verify.dart';
import 'package:BlindSightApp/utils/types.dart';
import 'package:BlindSightApp/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Register extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(title: Text("BlindSight Registration")),
            drawer: MenuDrawer(),
            body: Center(
                child: ListView(
                    children: [
                        Image.asset("assets/blindsight_logo.png"),
                        Center(
                            child: Text(
                            "Create Account",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)
                            )
                        ),
                        Center(
                            child: RegisterForm()
                        )
                    ],
                ),
            ) 
        );
    }
}

class RegisterForm extends StatefulWidget {

    @override
    RegisterFormState createState() {
        return RegisterFormState();
    }
}

class RegisterFormState extends State<RegisterForm> {

    // NOTE: It should be 'FormState' here!
    final _formKey = GlobalKey<FormState>();


    List<dynamic>? users;

    var user = new User();

    @override
    Widget build(BuildContext context) {
        return FutureBuilder<String>(
            future: getUsers(), 
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                } else {
                    if (snapshot.data != null && snapshot.data != "") {
                        users = jsonDecode(snapshot.data!);
                    }

                    return Form(
                        key: _formKey,
                        child: Column(
                            children: <Widget>[
                                TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "First Name"
                                    ),
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return "Please enter your first name!";
                                        }

                                        user.fname = value;
                                        return null;
                                    },
                                ),
                                TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "Last Name"
                                    ),
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return "Please enter your last name!";
                                        }

                                        user.lname = value;
                                        return null;
                                    },
                                ),
                                TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "Email"
                                    ),
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return "Please enter your email!";
                                        }

                                        if (!value.contains('@')) {
                                            return "Please enter a valid email address!";
                                        }

                                        if (users != null) {
                                            if (!isUniqueEmail(users!, value)) {
                                                return "This email is already in use!";
                                            }

                                        }

                                        user.email = value;
                                        return null;
                                    },
                                ),
                                TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "Username"
                                    ),
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return "Please enter your last name!";
                                        }

                                        if (users != null) {
                                            if (!isUniqueUsername(users!, value)) {
                                                return "This username is already in use!";
                                            }
                                        }

                                        user.username = value;
                                        return null;
                                    },
                                ),
                                TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "Password"
                                    ),
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return "Please enter a password!";
                                        }

                                        user.password = value;
                                        return null;
                                    },
                                    obscureText: true,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    
                                ),
                                TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "Confirm password"
                                    ),
                                    validator: (value) {
                                        if (value != user.password) {
                                            return "Passwords must match!";
                                        }

                                        return null;
                                    },
                                    obscureText: true,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                            // TODO: Add serverUrl to environment variables
                                            final serverUrl = 'http://10.0.2.2:3000/register';

                                            final request = http.MultipartRequest("POST", Uri.parse(serverUrl));
                                            request.fields["fname"] = user.fname!;
                                            request.fields["lname"] = user.lname!;
                                            request.fields["email"] = user.email!;
                                            request.fields["username"] = user.username!;
                                            request.fields["password"] = user.password!;

                                            await request.send();

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => Verify())
                                            );
                                        }
                                    }, 
                                    child: Text('Register')
                               )
                           ]
                       )
                   );

                }
        });
    }
}
