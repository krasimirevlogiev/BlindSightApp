class User {
    String? fname;
    String? lname;
    String? email;
    String? username;
    String? password;

    User();

    User.fromJson(Map<String, dynamic> json) : 
        fname = json['fname'],
        lname = json['lname'],
        email = json['email'],
        username = json['username'],
        password = json['password'];

}
