import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'updatemachine.dart';
import 'extensions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'generateQr.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:barcode_scan/barcode_scan.dart';

const flashOn = 'FLASH ON';
const flashOff = 'FLASH OFF';
const frontCamera = 'FRONT CAMERA';
const backCamera = 'BACK CAMERA';

class QRViewExample extends StatefulWidget {
  const QRViewExample({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermission();
    _scan();
  }

  getPermission() async {
    await Permission.camera.request();
  }

  _scan() async {
    var result = await BarcodeScanner.scan();
    setState(() {
      qrText = result.rawContent;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateMachinePage(qrText, qrText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UpdateMachinePage(qrText, qrText);
  }
}

class UpdateMachinePage extends StatefulWidget {
  final String docRef;
  final String name;

  UpdateMachinePage(this.docRef, this.name);

  @override
  _UpdateMachinePageState createState() => _UpdateMachinePageState();
}

class _UpdateMachinePageState extends State<UpdateMachinePage> {
  var time = new DateTime.now();

  TextEditingController controller;

  String name;
  String data;
  String notes;

  bool cleaned = false;

  final cminController = TextEditingController();
  final cmaxController = TextEditingController();

  String cMin;

  String cMax;

  Widget _handleWidget() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('myBox').listenable(),
      builder: (BuildContext context, box, Widget child) {
        var isAdmin = box.get('admin');
        if (isAdmin == false) {
          return Container();
        } else {
          return Container(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      cMin = value;
                    });
                  },
                  keyboardType: TextInputType.number,
                  controller: controller,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Min Coolant % (Optional)',
                      labelStyle: TextStyle(fontSize: 15)),
                ).padding(),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      cMax = value;
                    });
                  },
                  keyboardType: TextInputType.number,
                  controller: controller,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Max Coolant % (Optional)',
                      labelStyle: TextStyle(fontSize: 15)),
                ).padding()
              ],
            ),
          );
        }
      },
    );
  }

  void getInputData() {
    setState(() {
      cMin = cminController.text;
      cMax = cmaxController.text;
    });
  }

  void getName(String docRef) {
    var box = Hive.box('myBox');
    var result = Firestore.instance
        .collection(box.get('companyId'))
        .document(docRef)
        .get();
    result.then((doc) {
      setState(() {
        name = doc.data['name'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(
          'Add Refractometer Reading',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1c6b92),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  '${widget.name}',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 8, 4),
                child: Text(
                  "Enter Coolant Percentage",
                  style: TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    data = value;
                  });
                },
                keyboardType: TextInputType.number,
                controller: controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Coolant Percentage',
                    labelStyle: TextStyle(fontSize: 15)),
              ).padding(),
              //Text('Optional'),
              TextField(
                onChanged: (value) {
                  setState(() {
                    notes = value;
                  });
                },
                controller: controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Add any notes (Optional)',
                    labelStyle: TextStyle(fontSize: 15)),
              ).padding(),
              Container(child: _handleWidget()),
              SwitchListTile(
                  title: Text(
                    "Was The Sump Cleaned?",
                    //style: whiteBoldText,
                  ),
                  value: cleaned,
                  onChanged: (val) {
                    setState(() {
                      cleaned = val;
                    });
                  }),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        var box = Hive.box('myBox');
                        if (data != null) {
                          Firestore.instance
                              .collection(box.get('companyId'))
                              .document("${widget.docRef}")
                              .updateData({
                            "coolant-percent": "$data",
                            "last-updated": "$time"
                          });
                          Firestore.instance
                              .collection(box.get('companyId'))
                              .document("${widget.docRef}")
                              .collection('history')
                              .document("$time")
                              .setData({"data": "$data", "time": "$time"});
                        }
                        if (notes != null) {
                          Firestore.instance
                              .collection(box.get('companyId'))
                              .document("${widget.docRef}")
                              .collection("notes")
                              .document("$time")
                              .setData({"note": "$notes", "time": "$time"});
                        }

                        if (cleaned != false) {
                          Firestore.instance
                              .collection(box.get('companyId'))
                              .document("${widget.docRef}")
                              .updateData({"last-cleaned": "$time"});
                        }

                        if (cMin != null) {
                          Firestore.instance
                              .collection(box.get('companyId'))
                              .document("${widget.docRef}")
                              .updateData({"c-min": "$cMin"});
                        }
                        if (cMax != null) {
                          Firestore.instance
                              .collection(box.get('companyId'))
                              .document("${widget.docRef}")
                              .updateData({"c-max": "$cMax"});
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                          height: 50,
                          width: 300,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(colors: [
                                Colors.blueAccent[700],
                                Colors.blue
                              ])),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenerateButton extends StatelessWidget {
  const GenerateButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => GenerateScreen()));
        },
        onLongPress: () => {},
        child: Container(
            height: 50,
            width: 300,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                    colors: [Colors.lightBlue, Colors.lightBlueAccent])),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings_applications,
                  color: Colors.white,
                ),
                Text(
                  ' Generate QR Code',
                  style: TextStyle(color: Colors.white),
                )
              ],
            )),
      ),
    );
  }
}
