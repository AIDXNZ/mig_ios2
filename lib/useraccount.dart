import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';

const greenPercent = Color(0xff14c4f7);

class UserAccount extends StatefulWidget {
  @override
  _UserAccountState createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  File _image;
  final picker = ImagePicker();

  String newCompanyId;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void getInputData() {
    setState(() {
      newCompanyId = nameController.text;
    });
  }

  _showMaterialDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Change Company ID"),
              content: TextField(
                controller: nameController,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Close me!'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    getInputData();
                    box.put("companyId", newCompanyId);
                  },
                )
              ],
            ));
  }

  final nameController = TextEditingController();

  var box = Hive.box('myBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF1c6b92),
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop()),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        notchMargin: 0.0,
        shape: CircularNotchedRectangle(),
      ),
      appBar: AppBar(
          backgroundColor: Color(0xFF1c6b92),
          title: Text('User Account Information',
              style: TextStyle(
                color: Color(0xffFFFFFF),
              ))),
      backgroundColor: Colors.white,
      body: Theme(
        data: Theme.of(context).copyWith(
          brightness: Brightness.dark,
          primaryColor: Colors.purple,
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 30.0),
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        child: _image == null
                            ? Image.asset('assets/User2.png')
                            : ClipOval(child: Image.file(_image)),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            box.get('userId') ?? "John Smith",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            box.get('companyId'),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                ListTile(
                  title: Text(
                    "Company ID",
                    //style: whiteBoldText,
                  ),
                  subtitle: Text(
                    box.get('companyId'),
                    //style: greyTExt,
                  ),
                  trailing: Icon(
                    Icons.edit,
                    color: Colors.grey.shade400,
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: Hive.box('myBox').listenable(),
                  builder: (context, box, widget) {
                    return SwitchListTile(
                        title: Text(
                          "Administrator",
                          //style: whiteBoldText,
                        ),
                        subtitle: Text(box.get('admin') ?? false ? "on" : "off"
                            //style: greyTExt,
                            ),
                        value: box.get('admin') ?? false,
                        onChanged: (val) {
                          box.put('admin', val);
                        });
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: Hive.box('myBox').listenable(),
                  builder: (context, box, widget) {
                    return SwitchListTile(
                        title: Text(
                          "Notifications",
                          //style: whiteBoldText,
                        ),
                        subtitle: Text(box.get('notif') ?? false ? "on" : "off"
                            //style: greyTExt,
                            ),
                        value: box.get('notif') ?? false,
                        onChanged: (val) {
                          box.put('notif', val);
                        });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _handleWidget() {
  return ValueListenableBuilder(
    valueListenable: Hive.box('myBox').listenable(),
    builder: (BuildContext context, box, Widget child) {
      var name = box.get('userId');
      if (name == null) {
        return Text(
          "John Smith",
          style: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        );
      } else {
        return Text(name);
      }
    },
  );
}
