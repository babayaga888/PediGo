import 'package:flutter/material.dart';


class Driver extends StatefulWidget {
  const Driver({Key? key}) : super(key: key);

  @override
  State<Driver> createState() => _driverState();
}

class _driverState extends State<Driver> {
  bool agree = false;
  String termsAndCondition = """
Welcome to PediGo, a pedicab platform in Digos City! Before you begin driving with us, please read and agree to the following terms and conditions:

Driver Requirements:
a. To become a PediGo driver, you must be at least 18 years old, possess a valid driver's license, and have a functional and reliable pedicab.
b. You must also have the legal right to work in the Philippines and must provide a valid government-issued ID during the application process.
c. PediGo reserves the right to reject any driver application that does not meet our requirements.

Driver Conduct:
a. You must comply with all traffic laws and regulations while operating your pedicab. Failure to do so may result in immediate termination of your account.
b. You must be professional and courteous to all passengers at all times. Any report of unprofessional conduct, harassment, or discrimination may result in disciplinary action or account termination.
c. You must not accept cash payments from passengers. All fares must be paid through the PediGo app.
d. You must maintain your pedicab in good working condition, including regular maintenance and cleaning.
e. You are responsible for ensuring the safety of your passengers and must ensure that all passengers wear the provided seatbelts while riding in your pedicab.

Payments:
a. PediGo will deduct a commission fee from your fares for using our platform.
b. Payments will be made to your registered bank account on a weekly basis. You are responsible for ensuring that your bank information is accurate and up-to-date.
c. You are responsible for paying all applicable taxes on the income earned through PediGo.

Termination:
a. PediGo reserves the right to terminate your account at any time for any reason.
b. You may terminate your account at any time by notifying PediGo in writing.
c. Upon termination, you must immediately stop using the PediGo platform and return any PediGo equipment in your possession.

Disclaimer of Liability:
a. PediGo is not liable for any damages, including but not limited to bodily injury, property damage, or lost profits, that may occur while using our platform.
b. You agree to indemnify PediGo against any and all claims, liabilities, and expenses arising from your use of the PediGo platform.

By agreeing to these terms and conditions, you acknowledge that you have read and understood all provisions and agree to abide by them while driving with PediGo.
""";


  void _doSomething() {

    Navigator.pushNamed(context, 'driverRequirements');

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Text(termsAndCondition),
              ),
            ),
          ),
          Row(
            children: [
              Material(
                child: Checkbox(
                  value: agree,
                  onChanged: (value) {
                    setState(() {
                      agree = value ?? false;
                    });
                  },
                ),
              ),
              const Text(
                'I have read and accept terms and conditions',
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
          ElevatedButton(
            onPressed: agree ? _doSomething : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
