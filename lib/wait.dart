import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({Key? key}) : super(key: key);

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  String message = "Waiting for drivers...";
  late DatabaseReference waitingScreenRef;
  late StreamSubscription waitingScreenSub;

  String get userId => "";

  @override
  void initState() {
    super.initState();
    // Set up a Realtime Database reference to the waiting screen text location
    waitingScreenRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(userId)
        .child("waiting_screen");

    // Listen for changes to the waiting screen text
    waitingScreenSub = waitingScreenRef.onValue.listen((event) {
      final message = event.snapshot.value as String?;
      if (message != null) {
        setState(() {
          this.message = message;
        });
      }
    });
  }

  @override
  void dispose() {
    // Clean up the Realtime Database subscription
    waitingScreenSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Stack(
            children: [
              SpinKitRipple(
                size: 450,
                color: Colors.blue.shade600,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 200,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      message,
                      style: const TextStyle(fontSize: 18.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin:const EdgeInsets.only(top: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        // Close the app
                        SystemNavigator.pop();
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.close,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}