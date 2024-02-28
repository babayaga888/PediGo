import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';


class Register extends StatefulWidget{
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => RegistrationScreen();
}


class RegistrationScreen extends State<Register> {
  final auth = FirebaseAuth.instance;
  var email;
  var password;
  var spinner = false;

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                    //Do something with the user input.

                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your email')),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                    //Do something with the user input.
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your Password')),
              const SizedBox(
                height: 24.0,
              ),

             Container(
                 height: 50,
                 padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                 child :ElevatedButton(

                   child: const Text(
                     'Register',
                     style: TextStyle(fontSize: 15),
                   ),
                   onPressed: () async {
                     setState(() {
                       spinner = true;
                     });
                     try {
                       final newUser = await auth.createUserWithEmailAndPassword(
                           email: email, password: password);
                       if (newUser != null) {
                         Navigator.pushNamed(context, 'loginForm');
                       }
                     } catch (e) {
                       print(e);
                     }
                     setState(() {
                       spinner = false;
                     });
                   },
                 )
             )


            ],
          ),
        ),
      ),
    );
  }
}

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  hintStyle: TextStyle(color: Colors.blue),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    // borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
  enabledBorder: OutlineInputBorder(
    // borderSide: BorderSide(color: Colors.black, width: 1.0),
    // borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
  focusedBorder: OutlineInputBorder(
    // borderSide: BorderSide(color: Colors.black, width: 2.0),
    // borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
);

