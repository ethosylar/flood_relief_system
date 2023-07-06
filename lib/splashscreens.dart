import 'package:flood_relief_system/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flood_relief_system/home.dart';
import 'package:flood_relief_system/interface.dart';

class splash extends StatefulWidget {
  const splash({Key? key}) : super(key: key);

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    navigateHome();
  }
  void navigateHome() async{
    await Future.delayed(Duration(seconds: 5),(){});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.blue,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    child: Image.asset('images/FlooRS_Logo.png', height: 200, width: 200,)
                ),
                Container(
                  child: Text("FlooRS: Flood Relief System",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ),
        )
    );
  }

}
