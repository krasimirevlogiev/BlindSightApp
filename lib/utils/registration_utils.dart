import 'package:http/http.dart' as http;

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

