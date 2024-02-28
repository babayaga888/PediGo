import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'mapPediGo.dart';

User? loggedinUser;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final auth = FirebaseAuth.instance;
  var spinner = false;
  bool disableBackButton = true;

  void initState() {
    super.initState();
    getCurrentUser();
  }

  //using this function you can use the credentials of the user
  void getCurrentUser() async {
    try {
      final user = await auth.currentUser;
      if (user != null) {
        loggedinUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {




    return WillPopScope( // Wrap your scaffold with WillPopScope widget
      onWillPop: () async {
        return !disableBackButton; // Return opposite value of disableBackButton to allow or prevent back navigation
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue,
                            ),
                          ),
                          onPressed: () {
                            /** */
                            Navigator.pushNamed(context, 'mapPediGo');
                          },
                          child: const Text('Commuter'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue,
                            ),
                          ),
                          onPressed: () async {
                            /** */
                             FirebaseAuth _auth = FirebaseAuth.instance;
                            User? user = _auth.currentUser;
                             if (user != null) {
                               // User is logged in, check if they have uploaded an image
                              final databaseReference = FirebaseDatabase.instance.ref('driversIdentity');
                                // databaseReference.child('driversIdentity').child(user.uid).once() ;

                              if (databaseReference != null) {
                                 // User has uploaded an image, go directly to driver side
                                Navigator.pushNamed(context, 'driverSide');
                              } else {
                                // User has not uploaded an image, show terms and conditions
                                Navigator.pushNamed(context, 'termsAndConditionDriver');
                               }
                             }


                          },
                          child: const Text('Driver'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    disableBackButton = false; // Reset the disableBackButton flag when the widget is disposed
    super.dispose();
  }
}

