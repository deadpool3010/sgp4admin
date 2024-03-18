import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailing/Display.dart';
import 'package:mailing/Todo.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:mailing/firebase_options.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore fire = FirebaseFirestore.instance;
User? user;
bool cardvis = false;
TextEditingController name = TextEditingController();
TextEditingController price = TextEditingController();
TextEditingController mainCatt = TextEditingController();
TextEditingController subCatt = TextEditingController();
String catt = "";
File? image;
final ImagePicker picker = ImagePicker();
var uploadTask;
var downloadUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

Future<void> addprod() async {
  if (image != null) {
    var imageName = DateTime.now().millisecondsSinceEpoch.toString();
    var storageRef =
        FirebaseStorage.instance.ref().child('driver_images/$imageName.jpg');

    try {
      uploadTask = await storageRef.putFile(image!);
      downloadUrl = await uploadTask.ref.getDownloadURL();
      var intValue;
      var rng = new Random();
      intValue = rng.nextInt(900000000) + 10000;
      final docuse = fire.collection('product').doc(intValue.toString());

      Todo todo = Todo(
          id: intValue,
          name: name.text,
          pricet: int.parse(price.text),
          image: downloadUrl.toString(),
          mainCat: mainCat,
          subCat: subCat);

      var s = todo.tojson();
      await docuse.set(s).then((value) {
        setRef(intValue);
      });
      if (kDebugMode) {
        print('success');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error $e');
      }
    }
  }
}

// Future<void> m() async {
//   CollectionReference prodCollectionRef = FirebaseFirestore.instance
//       .collection('admin')
//       .doc(user!.uid)
//       .collection('prod');
//   // print(prodCollectionRef);

//   QuerySnapshot prod = await prodCollectionRef.get();

//   var x = prod.docs;
//   // print(x);

//   List<Admin> a =
//       x.map((e) => Admin.fromMap(e.data() as Map<String, dynamic>)).toList();
//   // // print(a);

//   // List<Map<String, dynamic>> list = [];

//   // for (var y in x) {
//   //   list.add(y.data() as Map<String, dynamic>);
//   // }
//   // print(list);

//   // List<Todo> todo = [];
//   List<Todo> todo1 = [];

//   // for (var l in list) {
//   //   var t = l['ref'];

//   //   DocumentReference reference = t;

//   //   var m = await reference.get();
//   //   var x = Todo.fromMap(m.data() as Map<String, dynamic>);
//   //   todo.add(x);
//   // }

//   //print(todo);

//   for (var i in a) {
//     var q = i.reference;

//     DocumentReference d = q as DocumentReference;
//     var m = await d.get();
//     var x = Todo.fromMap(m.data() as Map<String, dynamic>);
//     todo1.add(x);
//   }
//   print(todo1);

//   // print(p);
// }

Future<void> m() async {
  CollectionReference prodCollectionRef = FirebaseFirestore.instance
      .collection('admin')
      .doc(user!.uid)
      .collection('prod');

  QuerySnapshot prod = await prodCollectionRef.get();

  var x = prod.docs;

  List<Admin> a =
      x.map((e) => Admin.fromMap(e.data() as Map<String, dynamic>)).toList();

  List<Future<DocumentSnapshot>> documentFutures =
      a.map((admin) => admin.reference!.get()).toList();

  List<DocumentSnapshot> documents = await Future.wait(documentFutures);

  List<Todo> todo = documents
      .map((document) => Todo.fromMap(document.data() as Map<String, dynamic>))
      .toList();

//  print(todo);
}

Future<void> setRef(int val) async {
  var intValue;
  var rng = new Random();
  intValue = val;
  DocumentReference reference = fire.collection('product').doc(val.toString());
  final doc = fire
      .collection('admin')
      .doc(user!.uid)
      .collection('prod')
      .doc(intValue.toString());
  Admin admin = Admin(id: val.toString(), reference: reference);
  var j = admin.tojson();
  await doc.set(j);
  print('success add');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    auth.authStateChanges().listen((event) {
      setState(() {
        user = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: user != null
              ? InkWell(
                  child: const Icon(Icons.logout),
                  onTap: () async {
                    await signout();
                  },
                )
              : null,
        ),
        body: user != null ? const Page() : googlesigninbutton(),
        floatingActionButton: user != null
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    // cardvis = !cardvis;
                    showModelText(context);
                  });
                },
                child: const Icon(Icons.add),
              )
            : null);
  }

  Widget googlesigninbutton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 160,
            child: SignInButton(
              onPressed: () {
                signin();
              },
              Buttons.google,
              text: "Google Login",
            ),
          ),
        ],
      ),
    );
  }

  Widget logoutButton() {
    return FloatingActionButton(
      onPressed: signout,
      child: const Icon(Icons.logout),
    );
  }

  void signin() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await auth.signInWithProvider(googleProvider);
      var x = fire.collection('admin').doc(user!.uid);
      x.set({});
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  Future<void> signout() async {
    if (user != null) {
      await auth.signOut();
      await GoogleSignIn().signOut();
      setState(() {
        user = null;
      });
    }
  }
}

class Userinfo {
  String? name;
  String? email;

  Userinfo(String name, String email) {
    this.name = name;
    this.email = email;
  }
}

class CardWidget extends StatefulWidget {
  final VoidCallback onclose;

  const CardWidget({
    Key? key,
    required this.onclose,
  }) : super(key: key);

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  // Future<void> imagepick() async {
  //   try {
  //     final XFile? pick = await picker.pickImage(
  //         source: ImageSource.gallery, imageQuality: 100);

  //     if (pick != null) {
  //       File iimage = File(pick.path);
  //       setState(() {
  //         image = iimage;
  //       });
  //     }
  //   } catch (e) {}
  // }

  // Future<void> glbpicker() async {
  //   try {
  //     FilePickerResult? result =
  //         await FilePicker.platform.pickFiles(type: FileType.any);
  //     if (result != null) {
  //       File glbb = File(result.files.single.path!);
  //       setState(() {
  //         glb = glbb;
  //       });
  //     }
  //   } catch (e) {
  //     print("error to pick");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromRGBO(216, 191, 216, 1),
            ),
            height: 600,
            width: 300,
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child: const Icon(
                        Icons.close,
                        size: 35,
                      ),
                      onTap: () {
                        widget.onclose();
                      },
                    ),
                    Spacer(),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Name',
                  style: TextStyle(fontSize: 25),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'price',
                  style: TextStyle(fontSize: 25),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    controller: price,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'price',
                  style: TextStyle(fontSize: 25),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    controller: price,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                // Text(
                //   'Location',
                //   style: TextStyle(fontSize: 25),
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                // Container(
                //   margin: EdgeInsets.symmetric(vertical: 10),
                //   child: TextField(
                //     controller: location,
                //     decoration: InputDecoration(
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(20),
                //       ),
                //     ),
                //   ),
                // ),

                const SizedBox(
                  height: 20,
                ),
                Row(children: [
                  ElevatedButton(
                    onPressed: () async {
                      m().then((value) {
                        name.clear();
                        price.clear();
                      });
                      // m();

                      widget.onclose();
                    },
                    child: Text('Submit'),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        // imagepick();
                      },
                      child: Text('Pick image'))
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        if (cardvis == false) const Homee(),
        if (cardvis)
          CardWidget(onclose: () {
            setState(() {
              cardvis = false;
            });
          })
      ]),
    );
  }
}

class Homee extends StatefulWidget {
  const Homee({Key? key}) : super(key: key);

  @override
  State<Homee> createState() => _HomeeState();
}

class _HomeeState extends State<Homee> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TodoScreen(
          prodCollectionRef: FirebaseFirestore.instance
              .collection('admin')
              .doc(user!.uid)
              .collection('prod')),
    );
  }
}

List<String> maincatagory = [
  'SelectCatagory',
  'menfashion',
  'womenfashion',
  'shoes',
  'tshirt',
  'appliances',
  'watch',
  'mobile',
];

List<String> subCatagory = [
  'SelectSubCatagory',
  'Shoes',
  'Watch',
  'Glasses',
  'SmartPhones',
  'Shirts',
  'T-shirts',
  'Wall-Clock',
  'Table',
  'Chairs',
];
String mainCat = 'SelectCatagory';
String subCat = 'SelectSubCatagory';

void showModelText(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          Future<void> imagepick() async {
            try {
              final XFile? pick = await picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 20);

              if (pick != null) {
                File iimage = File(pick.path);
                setState(() {
                  image = iimage;
                });
              }
            } catch (e) {
              print('Error $e');
            }
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: price,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: mainCat,
                    items: maincatagory.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        mainCat = newValue!;
                        catt = newValue;

                        // mainCatt = newValue
                        //     as TextEditingController; // Update dropdown value
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: subCat,
                    items: subCatagory.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        subCat = newValue!;
                        // subCatt = newValue
                        //     as TextEditingController; // Update dropdown value
                      });
                    },
                  ),
                  Row(children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await addprod();
                        await m().then((value) {
                          name.clear();
                          price.clear();
                          mainCat = "SelectCatagory";
                          subCat = "SelectSubCatagory";
                          setState() {}
                        });
                      },
                      child: Text('Submit'),
                    ),
                    SizedBox(
                      width: 90,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await imagepick();
                        },
                        child: Text('Select image'))
                  ]),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
