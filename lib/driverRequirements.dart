import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Requirements extends StatefulWidget {
  const Requirements({Key? key}) : super(key: key);

  @override
  State<Requirements> createState() => _RequirementsState();
}

class _RequirementsState extends State<Requirements> {
  XFile? image;

  FirebaseAuth _auth = FirebaseAuth.instance;





  final ImagePicker picker = ImagePicker();
  final TextEditingController _licenseEditingController = TextEditingController();

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    User? user = _auth.currentUser;
    // Upload image to Firebase Storage
    Reference ref = FirebaseStorage.instance.ref().child('driversIdentity/${DateTime
        .now()
        .millisecondsSinceEpoch}.jpg');
    UploadTask uploadTask = ref.putFile(File(img!.path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    // Store image URL and label in Firebase Realtime Database
    final DatabaseReference database = FirebaseDatabase.instance.reference();
    database.child('driversIdentity').push().set({
      'imageUrl': imageUrl,
      'label': 'driverlicense',
      'userId': user!.uid,
      'licenseNumber': _licenseEditingController.text,
    });


    setState(() {
      image = img;
    });
  }


  Future<void> uploadText(
      TextEditingController licenseEditingController) async {
    String license = _licenseEditingController.text;
    Reference reference =
    FirebaseStorage.instance.ref().child('text_files').child('DriversData.txt');
    UploadTask uploadLicense = reference.putString(license);
    await uploadLicense.whenComplete(() => print('License Uploaded'));
  }

  //show popup dialog
  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose media to select'),
            content: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void sendTheSameTime() async {
    uploadText(_licenseEditingController);
    myAlert();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _licenseEditingController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Drivers License No.'
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    sendTheSameTime();
                  },
                  child: const Text('Upload Photo'),
                ),
                const SizedBox(
                  height: 10,
                ),
                //if image not null show the image
                //if image null show text
                image != null
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      //to show image, you type like this.
                      File(image!.path),
                      fit: BoxFit.cover,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: 300,
                    ),
                  ),
                )
                    : const Text(
                  "No Image",
                  style: TextStyle(fontSize: 20),
                ),
                Visibility(
                  visible: image != null,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "driverSide");
                      },
                      child: const Text('Proceed'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


}
