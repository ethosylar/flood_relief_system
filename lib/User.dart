import 'dart:convert';

Users userFromJson(String str) => Users.fromJson(json.decode(str));
String userToJson(Users data) => json.encode(data.toJson());

class Users {
  String? user_id;
  String? email;
  String? name;
  DateTime? createAt;
  String? phoneno;
  String? userType;

  Users({this.user_id, required this.email, required this.createAt, required this.name, required this.phoneno,  this.userType});

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        user_id: json["user_id"],
        email: json["email"],
        createAt: json["createAt"],
        name: json["name"],
        phoneno: json["phone"],
        userType: json["userType"]
      );

  String? getEmail() {
    return email;
  }

  String? getUser_id() {
    return user_id;
  }

  DateTime? getCreateAt() {
    return createAt;
  }

  String? getName(){
    return name;
  }

  void setName(String n){
    name = n;
  }

  void setEmail(String e) {
    email = e;
  }

  void setUser_id(String u) {
    user_id = u;
  }

  void setCreateAt(DateTime c) {
    createAt = c;
  }

  Map<String, dynamic> toJson() => {
        "user_id": user_id,
        "name": name,
        "email": email,
        "createAt": createAt,
        "phone": phoneno,
        "userType": userType,
      };
}

/*
ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text('${user.email ?? ''} (${user.user_id ?? ''})'),
                    subtitle: Text(
                        'Password: ${user.password ?? ''}\n'
                            'Created At: ${user.createAt?.toString() ?? ''}\n'
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteUser(user.user_id as String),
                    ),
                  );
                },
              ),
 */
