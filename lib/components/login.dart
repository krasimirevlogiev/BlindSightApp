import 'package:BlindSightApp/components/menu_drawer.dart';
import 'package:BlindSightApp/utils/auth.dart';
import 'package:BlindSightApp/utils/types.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Login extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.white,
            drawer: MenuDrawer(),
            body: Center(
                child: ListView(
                    children: [
                        Image.asset("assets/blindsight_logo.png"),
                        Center(
                            child: Text(
                            "Login",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)
                            )
                        ),
                        Center(
                            child: LoginForm()
                        )
                    ],
                ),
            ) 
        );
    }
}

class LoginForm extends StatefulWidget {

    @override
    LoginFormState createState() {
        return LoginFormState();
    }
}

class LoginFormState extends State<LoginForm> {

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
                                    labelText: "Username or Email"
                                ),
                                validator: (value) {
                                    if (value == null || value.isEmpty) {
                                        return "Please enter your username or your email!";
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
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                        // TODO: Add serverUrl to environment variables
                                        final serverUrl = 'http://10.0.2.2:3000/login';

                                        final request = http.MultipartRequest("POST", Uri.parse(serverUrl));
                                        request.fields["username"] = user.username!;
                                        request.fields["password"] = user.password!;

                                        final response = await request.send();

                                        authenticate(context, response);
                                    }
                                }, 
                                child: Text('Register')
                           )
                       ]
                   )
           );

        }
}
