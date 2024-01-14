import 'package:BlindSightApp/utils/types.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Register extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.white,
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

    var user = new User();

    @override
    Widget build(BuildContext context) {
        return Form(
            key: _formKey,
            child: Column(
                children: <Widget>[
                    TextFormField(
                        decoration: const InputDecoration(
                            labelText: "First Name"
                        ),
                        validator: (value) {
                            if (value == Null) {
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
                            if (value == Null) {
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
                            // TODO: Check if email is unique
                            if (value == Null) {
                                return "Please enter your email!";
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
                            // TODO: Check if username is unique
                            if (value == Null) {
                                return "Please enter your last name!";
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
                            if (value == Null) {
                                return "Please enter a password!";
                            }

                            user.password = value;
                            return null;
                        },
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
                    ),
                    ElevatedButton(
                        onPressed: () {
                            if (_formKey.currentState!.validate()) {
                                // TODO: Add serverUrl to environment variables
                                final serverUrl = 'http://localhost:3000/verify';

                                final request = http.MultipartRequest("POST", Uri.parse(serverUrl));
                                request.fields["fname"] = user.fname!;
                                request.fields["lname"] = user.lname!;
                                request.fields["email"] = user.email!;
                                request.fields["username"] = user.username!;
                                request.fields["password"] = user.password!;

                                request.send();
                            }
                        }, 
                        child: Text('Register')
                    )
                ]
            )
        );
    }
}
