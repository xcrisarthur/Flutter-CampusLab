import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LabPage extends StatelessWidget {
  final String labType;
  double _fontSize = 1;
  double _fontSizeHeading = 1;
  LabPage({super.key, required this.labType});

  Future<Map<String, dynamic>> fetchLabData() async {
    try {
      final labTypeLowerCase = labType.toLowerCase();
      var docSnapshot = await FirebaseFirestore.instance
          .collection('labolatorium')
          .doc(labTypeLowerCase)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print("Data Tidak Ada");
        }
        return {};
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    _fontSizeHeading = screenWidth * 0.05;
    _fontSizeHeading = _fontSizeHeading.clamp(0.0, 20);

    _fontSize = screenWidth * 0.03;
    _fontSize = _fontSize.clamp(0.0, 20);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laboratorium $labType',
          style: TextStyle(fontSize: _fontSizeHeading),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchLabData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            var labData = snapshot.data!;
            var pcCount = labData['pc']['jumlah'] ?? 0;
            return SingleChildScrollView(
              child: Column(
                children: [
                  buildPCCards(pcCount, labData),
                ],
              ),
            );
          } else {
            return const Center(child: Text("Tidak ada data."));
          }
        },
      ),
    );
  }

  Widget buildPCCards(int pcCount, Map<String, dynamic> labData) {
    var pcStatusList = labData['pc']['status'] as List<dynamic>;
    var keyboardStatusList = labData['keyboard']['status'] as List<dynamic>;
    var mouseStatusList = labData['mouse']['status'] as List<dynamic>;
    var kursiStatusList = labData['kursi']['status'] as List<dynamic>;
    var mejaStatusList = labData['meja']['status'] as List<dynamic>;
    var monitorStatusList = labData['monitor']['status'] as List<dynamic>;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: pcCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        var pcStatus = pcStatusList[index % pcStatusList.length] ?? "unknown";
        var keyboardStatus =
            keyboardStatusList[index % keyboardStatusList.length] ?? "unknown";
        var mouseStatus =
            mouseStatusList[index % mouseStatusList.length] ?? "unknown";
        var kursiStatus =
            kursiStatusList[index % kursiStatusList.length] ?? "unknown";
        var mejaStatus =
            mejaStatusList[index % mejaStatusList.length] ?? "unknown";
        var monitorStatus =
            monitorStatusList[index % monitorStatusList.length] ?? "unknown";

        return SizedBox(
          width: 150,
          height: 200,
          child: Card(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Column(
                children: [
                  Text(
                    '0${index + 1}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: _fontSize),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'PC',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                      ),
                      Column(children: [
if (pcStatus == 'good')
                        Text(
                          "Good",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        )
                      else
                        Text(
                          "Broken",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                      ],),
                      
                        
                      if (pcStatus == 'good')
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: monitorStatus,
                          item: "Monitor",
                          icon: Icons.check_circle_sharp,
                        )
                      else
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: monitorStatus,
                          item: "Monitor",
                          icon: Icons.error,
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Keyboard',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                      ),
                      if (keyboardStatus == 'good')
                        Text(
                          "Good",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        )
                      else
                        Text(
                          "Broken",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                      if (keyboardStatus == 'good')
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: keyboardStatus,
                          item: "Keyboard",
                          icon: Icons.check_circle_sharp,
                        )
                      else
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: keyboardStatus,
                          item: "Keyboard",
                          icon: Icons.error,
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mouse',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                      ),
                      
                      if (mouseStatus == 'good')
                        Text(
                          "Good",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        )
                      else
                        Text(
                          "Broken",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        if (mouseStatus == 'good')
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: mouseStatus,
                          item: "Mouse",
                          icon: Icons.check_circle_sharp,
                        )
                      else
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: mouseStatus,
                          item: "Mouse",
                          icon: Icons.error,
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Meja',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                      ),
                      if (mejaStatus == 'good')
                        Text(
                          "Good",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        )
                      else
                        Text(
                          "Broken",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        if (mejaStatus == 'good')
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: mejaStatus,
                          item: "Meja",
                          icon: Icons.check_circle_sharp,
                        )
                      else
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: mejaStatus,
                          item: "Meja",
                          icon: Icons.error,
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Kursi',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                      ),
                      if (kursiStatus == 'good')
                        Text(
                          "Good",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        )
                      else
                        Text(
                          "Broken",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        if (kursiStatus == 'good')
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: kursiStatus,
                          item: "Kursi",
                          icon: Icons.check_circle_sharp,
                        )
                      else
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: kursiStatus,
                          item: "Kursi",
                          icon: Icons.error,
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Monitor',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                      ),
                      if (monitorStatus == 'good')
                        Text(
                          "Good",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        )
                      else
                        Text(
                          "Broken",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        if (monitorStatus == 'good')
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: monitorStatus,
                          item: "Monitor",
                          icon: Icons.check_circle_sharp,
                        )
                      else
                        MonitorStatusButton(
                          index: index,
                          monitorStatus: monitorStatus,
                          item: "Monitor",
                          icon: Icons.error,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MonitorStatusButton extends StatelessWidget {
  final int index;
  final String monitorStatus;
  final String item;
  final IconData icon;

  const MonitorStatusButton({
    Key? key,
    required this.index,
    required this.monitorStatus,
    required this.item,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: IconButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text('Status $item 0${index + 1}'),
                content: Text(monitorStatus),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Close'),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
            icon: Icon(icon),
            // iconSize: 10.0,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

