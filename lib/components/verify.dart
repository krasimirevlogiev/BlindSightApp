import 'package:BlindSightApp/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Verify extends StatelessWidget {

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
                            "Verify Account",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)
                            )
                        ),
                        Center(
                            child: VerifyForm()
                        )
                    ],
                ),
            ) 
        );
    }
}

class VerifyForm extends StatefulWidget {

    @override
    VerifyFormState createState() {
        return VerifyFormState();
    }
}

class VerifyFormState extends State<VerifyForm> {

    // NOTE: It should be 'FormState' here!
    final _formKey = GlobalKey<FormState>();

    int? verification_code;

    @override
    Widget build(BuildContext context) {
        return Form(
            key: _formKey,
            child: Column(
                children: <Widget>[
                    TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Verification Code"
                        ),
                        validator: (value) {
                            if (value == null || num.tryParse(value) == null) {
                                return "Please enter your verification code!";
                            }

                            verification_code = int.parse(value);
                            return null;
                        },
                    ),
                    ElevatedButton(
                        onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                                // TODO: Add serverUrl to environment variables
                                final serverUrl = 'http://10.0.2.2:3000/verify';

                                final request = http.MultipartRequest("POST", Uri.parse(serverUrl));
                                request.fields["verification_code"] = verification_code.toString();

                                final response = await request.send();

                                await authenticate(context, response);
                            }
                        }, 
                        child: Text('Register')
                    )
                ]
            )
        );
    }
}
