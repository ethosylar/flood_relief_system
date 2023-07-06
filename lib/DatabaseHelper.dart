import 'package:firebase_database/firebase_database.dart';
import 'package:flood_relief_system/User.dart';
import 'package:flood_relief_system/FloodVictim.dart';
import 'package:flood_relief_system/Rescuers.dart';

class DatabaseHelper {
  final _databaseReference = FirebaseDatabase.instance.ref();
  final dbHelper = FirebaseDatabase.instance;
  static final table = 'users_table';
  static final columnId = 'id';
  static final columnEmail = 'email';
  static final columnPassword = 'password';
  static final columnCreatedAt = 'created_at';
  static final columnName = 'name';
  static final columnPhoneno = 'phoneno';
  List<Users> users = [];
  //DatabaseHelper._privateConstructor();
  //static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<void> insert(Users user) async {
    await _databaseReference.child(table).push().set(user.toJson());
  }
/*
  Future<List<User>> queryAllRows() async {
    final snapshot = await _databaseReference.child(table).once();
    final usersMap = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (usersMap == null) {
      return [];
    }

    return usersMap.entries
        .map((entry) => User(
      user_id: entry.key,
      email: entry.value[columnEmail],
      password: entry.value[columnPassword],
      createAt: DateTime.parse(entry.value[columnCreatedAt]),
    ))
        .toList();
  }

  void readAllUsers() async {
    final DatabaseReference usersRef  = FirebaseDatabase.instance.ref().child('users');
    usersRef.onValue.listen((event) {
      final dynamic data = event.snapshot.value;
      final userList = <User>[];
      if (data != null) {
        final Map<dynamic, dynamic> dataMap = data;
        dataMap.forEach((key, value) {
          final user = User.fromJson(value);
          user.key = key;
          userList.add(user);
        });
      }
      setState(() {
        users = userList;
      });
    });
  }*/

  Future<List<Users>> queryRows(String email) async {
    final snapshot = await _databaseReference
        .child(table)
        .orderByChild(columnEmail)
        .equalTo(email)
        .once();
    final usersMap = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (usersMap == null) {
      return [];
    }

    return usersMap.entries
        .map((entry) => Users(
      user_id: entry.key,
      email: entry.value[columnEmail],
      createAt: DateTime.parse(entry.value[columnCreatedAt]),
      name: entry.value[columnName],
      phoneno: entry.value[columnPhoneno],
    ))
        .toList();
  }

  Future<int?> queryRowCount() async {
    final snapshot = await _databaseReference.child(table).once();
    final usersMap = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    return usersMap?.length;
  }

  Future<void> update(Users user) async {
    await _databaseReference.child(table).child(user.user_id!).set(user.toJson());
  }

  Future<void> delete(String user_id) async {
    await _databaseReference.child(table).child(user_id).remove();
  }

  void setState(Null Function() param0) {}
}