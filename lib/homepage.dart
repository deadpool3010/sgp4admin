import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailing/Todo.dart';
import 'package:mailing/main.dart';

Future<void> add() async {
  final docuse = fire.collection('product').doc("1");
  Todo t = Todo(id: 2, name: "rapoo", image: "", pricet: 1200);
  var s = t.tojson();
  docuse.set(s);
}

Future<void> admin() async {
  var intValue;
  var rng = new Random();
  intValue = rng.nextInt(900000000) + 10000;

  DocumentReference productRef = fire.collection('product').doc('1');
  final doc = fire
      .collection('admin')
      .doc(user!.uid)
      .collection('prod')
      .doc(intValue.toString());
  Admin a = Admin(id: user!.uid, reference: productRef);
  var x = a.tojson();
  doc.set(x);
}

Future<void> refdata() async {
  QuerySnapshot queryDocumentSnapshot = await fire.collection('admin').get();
  var data = queryDocumentSnapshot.docs[0].data();
  Map<String, dynamic> d = data as Map<String, dynamic>;
  var reff = d['ref'];
  DocumentReference reference = reff;
  var x = await reference.get();
  print(x.data());
}

class Home extends StatefulWidget {
  Userinfo? userinfo;
  Home(Userinfo userinfo) {
    this.userinfo = userinfo;
  }
  final logger = Logger();

  String username = 'dhairyagohil8@gmail.com';
  String password = 'csey nefd xwev tiul';
  Future<bool> mail() async {
    final Completer<bool> completer = Completer<bool>();
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Dhairya')
      ..recipients.add(userinfo!.email.toString())
      ..subject = 'Test Dart Mailer library :: 😀 :: ${DateTime.now()}'
      ..text = 'Lovday apna kam karna'
      ..html = "hello";

    try {
      final sendReport = await send(message, smtpServer);
      logger.i('Message sent: $sendReport');
      completer.complete(true);
    } on MailerException catch (e) {
      logger.e('Message not sent: $e');
      completer.complete(false);
    }
    return completer.future;
  }

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.userinfo!.email.toString()),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                // setState(() {
                //   _isLoading = true;
                // });
                // final bool success = await widget.mail();
                // setState(() {
                //   _isLoading = false;
                // });
                // if (success) {
                //   showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         title: Text('Success'),
                //         content: Text('Mail sent successfully!'),
                //         actions: [
                //           TextButton(
                //             onPressed: () {
                //               Navigator.of(context).pop();
                //             },
                //             child: Text('OK'),
                //           ),
                //         ],
                //       );
                //     },
                //   );
                // } else {
                //   showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         title: Text('Error'),
                //         content: Text('Failed to send mail.'),
                //         actions: [
                //           TextButton(
                //             onPressed: () {
                //               Navigator.of(context).pop();
                //             },
                //             child: Text('OK'),
                //           ),
                //         ],
                //       );
                //     },
                //   );
                // }
                //    await add();
                //await refdata();
                await admin();
                print('success');
              },
              child: Text('Send'),
            ),
            if (_isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
