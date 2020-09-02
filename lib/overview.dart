import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const greenPercent = Color(0xff14c4f7);

class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overview of Machines'),
        toolbarHeight:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? AppBar().preferredSize.height
                : 0,
        backgroundColor: Color(0xFF1c6b92),
      ),
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
      backgroundColor: Colors.lightBlue[200],
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [.0, .2, .7, 1],
          colors: [
            Color(0xFF192b32),
            Color(0xFF1c6b92),
            Color(0xFF1c6b92),
            Color(0xFF192b32),

            // #0b1c36 dark purple blue
            // #c74300 orange
            // #446280 bluish orange
            // #abc0df light blue
            // #395473
            // #1c6b92
            // #8eaec9 Light Blue
          ],
        )),
        child: ListView(shrinkWrap: true, children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: SafeArea(
                  child: Text(
                    'Machine Overview',
                    style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: _buildBody(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

Widget _buildBody(BuildContext context) {
  var box = Hive.box('myBox');
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance.collection(box.get('companyId')).snapshots(),
    builder: (context, snapshot) {
      assert(snapshot != null);
      if (!snapshot.hasData) {
        return SizedBox(
            height: 2.0, width: 20.0, child: LinearProgressIndicator());
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 800.0,
            ),
            color: Colors.white,
            child: DataTable(columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Coolant %')),
              DataColumn(label: Text('Last\nUpdate')),
              DataColumn(label: Text('Last\nCleaned')),
            ], rows: _buildList(context, snapshot.data.documents)),
          ),
        );
      }
    },
  );
}

Color getColor(number) {
  if (number > 0 && number < 100) return Colors.red;
  if (number >= 100 && number < 200) return Colors.blue;
  //color: double.parse(machines['coolant-percent']) < double.parse(machines['c-min'])
}

List _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
  return snapshot.map((data) => _buildListItem(context, data)).toList();
}

DataRow _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
  DocumentSnapshot machines = snapshot;

  return DataRow(
    cells: [
      DataCell(Container(
        width: 80,
        child: Text(
          machines['name'].length > 17
              ? machines['name'].substring(0, 16) + "..."
              : machines['name'],
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
      )),
      DataCell(Container(
        width: 45,
        child: Text(
            machines['coolant-percent'] +
                "% (" +
                machines['c-min'] +
                "-" +
                machines['c-max'] +
                ")",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: double.parse(machines['coolant-percent']) <
                            double.parse(machines['c-max']) &&
                        double.parse(machines['coolant-percent']) >
                            double.parse(machines['c-min'])
                    ? Colors.greenAccent[700]
                    : Colors.red)),
      )),
      DataCell(Container(
        width: 45,
        child: Text(
          machines['last-updated'].substring(5, 7) +
              "/" +
              machines['last-updated'].substring(8, 10), // +
          //"/" +
          //machines['last-updated'].substring(2, 4),
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
      )),
      DataCell(Container(
        width: 45,
        child: Text(
          machines['last-cleaned'].substring(5, 7) +
                  "/" +
                  machines['last-cleaned'].substring(8, 10) // +
              //"/" +
              //machines['last-cleaned'].substring(2, 4)
              ??
              "No Input",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
      )),
    ],
  );
}

// Color getColor(number) {
//    if (double.parse(machines['coolant-percent']) < double.parse(machines['c-min'])) return Colors.red;
//    if (double.parse(machines['coolant-percent']) > double.parse(machines['c-max'])) return Colors.red;
// }
