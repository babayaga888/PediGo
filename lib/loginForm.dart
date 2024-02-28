import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign_up.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';


class MyStateFulWidget extends StatefulWidget{
  const MyStateFulWidget({Key? key}) : super(key: key);

  @override
  State<MyStateFulWidget> createState() => MyStatefulWidgets();
}

FirebaseAuth auth = FirebaseAuth.instance;
class MyStatefulWidgets extends State<MyStateFulWidget> {
  //FirebaseAuth user = FirebaseAuth.instance;
  //User? currentUser = user.currentUser;
  TextEditingController nameController = TextEditingController();
 TextEditingController passwordController = TextEditingController();
  //var signUp = const Register();



  final formkey = GlobalKey<FormState>();
  var email;
  var password;
  var spinner = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
          inAsyncCall: spinner,
          child: SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'pediGo',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontSize: 30),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Sign in',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value){
                email = value;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TextField(
              obscureText: true,
              onChanged: (value){
                password = value;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          if (errorMessage.isNotEmpty)
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                spinner = true;
                errorMessage = '';
              });
              try {
                final user = await auth.signInWithEmailAndPassword(
                    email: email, password: password);
                if (user != null) {
                  Navigator.pushNamed(context, 'homeScreen');
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found' || e.code == 'wrong-password') {
                  setState(() {
                    errorMessage = 'Incorrect email or password';
                  });
                } else {
                  setState(() {
                    errorMessage = 'An error occurred while signing in';
                  });
                }
              } catch (e) {
                setState(() {
                  errorMessage = 'An error occurred while signing in';
                });
              }
              setState(() {
                spinner = false;
              });
            },
            child: const Text('Login'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Does not have account?'),
              TextButton(
                child: const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Register()),
                  );

                },
              )
            ],
          ),
        ],
      ),
    ),
    ),
    ),
    );
  }
}
