import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flood_relief_system/User.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'auth/authenticationService.dart';

class InterfacePage extends StatefulWidget {
  const InterfacePage({Key? key}) : super(key: key);
  @override
  _InterfacePageState createState() => _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage> {
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  final ref = FirebaseDatabase.instance.ref('users');
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  List<Users> users = [];
  List<Map<String, dynamic>> _dataList = [];

  @override
  void initState() {
    super.initState();
    //readAllUsers();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> insertUser() async {
    final email = emailController.text;
    final password = passwordController.text;
    // Create a new user object.
    final user = Users(
        user_id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        createAt: DateTime.now(),
        name: '',
        phoneno: '',
    );
    final user_id = user.user_id;
    // Write the user to the database.
    await FirebaseDatabase.instance
        .ref('users/$user_id')
        .push()
        .set(user.toJson());
    // Update the list of users.
    setState(() async {

    });
  }

  String realTimeValue = '0';
  String getOnceValue = '0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flood Relief System'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {}, // Reload data on refresh icon pressed
            ),
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthenticationService>().signOut();
                } // Reload data on refresh icon pressed
                ),
          ],
        ),
        body: FutureBuilder(
            future: _fApp,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              } else if (snapshot.hasData) {
                return content();
              } else {
                return CircularProgressIndicator();
              }
            }));
  }

  Widget content() {
    DatabaseReference _testRef = FirebaseDatabase.instance.ref().child('count');
    _testRef.onValue.listen((event) {
      setState(() {
        realTimeValue = event.snapshot.value.toString();
      });
    });
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Users:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: StreamBuilder(
                stream: ref.onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data?.snapshot.value;
                    if (data is Iterable &&
                        data.every((element) => element is Map)) {
                      final users = data as List<Map<String, dynamic>>;
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            title: Text(user['name']),
                            subtitle: Text(user['email']),
                          );
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => insertUser(),
              child: Text('Add User'),
            ),
          ],
        ),
      ),
    );
  }
}

/*
Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Users:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: StreamBuilder(
                stream: ref.onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data?.snapshot.value;
                    if(data is Iterable && data.every((element) => element is Map)) {
                      final users = data as List<Map<String, dynamic>>;
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            title: Text(user['name']),
                            subtitle: Text(user['email']),
                          );
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => insertUser(),
              child: Text('Add User'),
            ),
          ],
        ),
      ),



      // tutorial read
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Center(child: Text("Real Time Counter : $realTimeValue")),
        SizedBox(
          height: 50,
        ),
        GestureDetector(
          onTap: () async{
            final snapshot = await _testRef.get();
            if(snapshot.exists){
              setState(() {
                getOnceValue = snapshot.value.toString();
              }
              );
            }else{
              print("No data available");
            }
          },
          child: Container(
            height: 50,
            width: 150,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Text(
                "Get Once",
                style: TextStyle(color: Colors.white),
              ), // Text
            ),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        Center(child: Text("Get Once Counter : $getOnceValue")),
      ]),
 */
