import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'batch.dart';
import 'signin.dart';
import 'package:toast/toast.dart';
import 'extensions.dart';
import 'main.dart';

class CreateCompanyPage extends StatefulWidget {
  CreateCompanyPage({Key key}) : super(key: key);

  @override
  _CreateCompanyPageState createState() => _CreateCompanyPageState();
}

class _CreateCompanyPageState extends State<CreateCompanyPage> {
  String companyId;

  String emailData;

  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController company = TextEditingController();
  String passData;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> signUp(email, password) async {
    try {
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
          email: email, password: password)) as FirebaseUser;
      assert(user != null);
      assert(await user.getIdToken() != null);
      return user;
    } catch (e) {
      handleError(e);
      return null;
    }
  }

  Future<FirebaseUser> signIn(String email, String password) async {
    try {
      FirebaseUser user = (await _auth.signInWithEmailAndPassword(
          email: email, password: password)) as FirebaseUser;
      assert(user != null);
      assert(await user.getIdToken() != null);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      return user;
    } catch (e) {
      handleError(e);
      return null;
    }
  }

  void handleError(e) {
    Toast.show(e.toString(), context, duration: Toast.LENGTH_LONG);
  }

  getInputData() {
    setState(() {
      companyId = company.text;
      emailData = email.text;
      passData = pass.text;
    });
  }

  Widget _handleWidget() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text('Loading'),
            );
          } else {
            if (snapshot.hasData) {
              return WelcomeScreen();
            } else {
              return SignInPage();
              //return WelcomeScreen();
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Create Company',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey)),
                height: MediaQuery.of(context).size.height * .07,
                width: 300,
                child: TextFormField(
                  controller: email,
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.person_outline),
                      labelStyle: TextStyle(fontSize: 15)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey)),
                  height: MediaQuery.of(context).size.height * .07,
                  width: 300,
                  child: TextFormField(
                      controller: pass,
                      style: TextStyle(
                          color: Colors.black, fontFamily: 'SFUIDisplay'),
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          labelStyle: TextStyle(fontSize: 15))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey),
                  ),
                  height: MediaQuery.of(context).size.height * .07,
                  width: 300,
                  child: TextFormField(
                      controller: company,
                      style: TextStyle(
                          color: Colors.black, fontFamily: 'SFUIDisplay'),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'CompanyID',
                          prefixIcon: Icon(Icons.edit),
                          labelStyle: TextStyle(fontSize: 15))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    getInputData();
                    signIn(emailData, passData);
                    var box = Hive.box('myBox');
                    box.put('companyId', companyId);
                    box.put('admin', true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BatchAddPage(),
                      ),
                    );
                    Navigator.of(context).dispose();
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * .07,
                    width: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                            colors: [Colors.blue[700], Colors.blue])),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In and Create Company',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    getInputData();
                    signUp(emailData, passData);
                    var box = Hive.box('myBox');
                    box.put('companyId', companyId);
                    box.put('admin', true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BatchAddPage(),
                      ),
                    );
                    Navigator.of(context).dispose();
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * .07,
                    width: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                            colors: [Colors.orangeAccent, Colors.orange])),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign Up and Create Company',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        )
                      ],
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

Future<bool> createCompany(String companyId) async {
  var box = Hive.box('myBox');
  var time = new DateTime.now();
  box.put('isEmpty', true);
  var result = Firestore.instance.collection(companyId).getDocuments();

  result.then((value) {
    if (value.documents.isEmpty) {
      return true;
    } else {
      return false;
    }
  });
}
