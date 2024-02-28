import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pedi_go/driverRequirements.dart';
import 'loginForm.dart';
import 'sign_up.dart';
import 'homeScreen.dart';
import 'mapPediGo.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'termsAndConditionDriver.dart';
import 'driverSide.dart';
import 'wait.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();





  runApp( MyApp());
}




class MyApp extends StatelessWidget {
   MyApp({Key? key}) : super(key: key);

  static const String title1 = 'pediGo';
  static const String title2 = 'log in';
  final DriverSide inventory = DriverSide();





  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title2,
      initialRoute: 'loginForm' , // set the initial route to the home screen
      routes: {
        // define the named routes for each screen
        'loginForm': (context) => Scaffold(
          appBar: AppBar(title: const Text("")),
          body: const MyStateFulWidget(),
        ),
        'sign_up': (context) => Scaffold(
          appBar: AppBar(title: const Text(title1)),
          body:  const Register(),

        ),
        'homeScreen': (context) => Scaffold(
          appBar: AppBar(
            title: const Text(title1),
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                  onPressed: (){

                  },
                  icon: const Icon(
                    Icons.more_vert_outlined,
                    color: Colors.white,
                  )
              )
            ],

          ),
          body:  const HomeScreen(),

        ),
        'mapPediGo': (context) => Scaffold(
          appBar: AppBar(
            title: const Text(title1),

          ),
          body:  const CustomerMap(),

        ),

        'termsAndConditionDriver': (context) => Scaffold(
          appBar: AppBar(title:const Text(title1),
          ),
          body: const Driver(),
        ),
        'driverRequirements' : (context) => Scaffold(
          appBar: AppBar(title: const Text (title1)
          ),
          body: const Requirements(),
        ),
        'driverSide' : (context) =>  const Scaffold(


          body:  DriverSide(),
        ),
        'wait' : (context) => const Scaffold(

          body: WaitingScreen(),
        )


      },
    );
  }
}

