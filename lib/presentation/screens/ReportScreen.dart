import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_uilogin/presentation/screens/AddReport.dart';
import 'package:intl/intl.dart';

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final FetchUsers fetchUsers = FetchUsers();
  final FetchReports fetchReports = FetchReports();
  final FetchLabData fetchLabData = FetchLabData();

  double _fontSize = 1;
  double _fontSizeHeading = 1;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> labData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    users = await fetchUsers.fetchUsers();
    reports = await fetchReports.fetchReports();
    labData = await fetchLabData.fetchLabData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String currentUserEmail =
        FirebaseAuth.instance.currentUser?.email ?? "";

    List<Map<String, dynamic>> currentUserData =
        users.where((user) => user['email'] == currentUserEmail).toList();

    String currentUserId =
        currentUserData.isNotEmpty ? currentUserData[0]['id'] : '';

    List<Map<String, dynamic>> filteredReports =
        reports.where((report) => report['NRP/NIM'] == currentUserId).toList();

    double screenWidth = MediaQuery.of(context).size.width;
    _fontSizeHeading = screenWidth * 0.05;
    _fontSizeHeading = _fontSizeHeading.clamp(0.0, 25);
    _fontSize = screenWidth * 0.03;
    _fontSize = _fontSize.clamp(0.0, 20);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Text(
                'Your Report History',
                style: TextStyle(
                  fontSize: _fontSizeHeading,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (var report in filteredReports)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Card(
                  elevation: 10,
                  margin: EdgeInsets.symmetric(vertical: 1),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Location: ${report['location']}',
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Description: ${report['description']}',
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Date: ${_formatDate(report['date'])}',
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReport()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}

class FetchUsers {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    QuerySnapshot querySnapshot = await usersCollection.get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}

class FetchReports {
  final CollectionReference reportsCollection =
      FirebaseFirestore.instance.collection('reports');

  Future<List<Map<String, dynamic>>> fetchReports() async {
    QuerySnapshot querySnapshot = await reportsCollection.get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}

class FetchLabData {
  final CollectionReference labCollection =
      FirebaseFirestore.instance.collection('labolatorium');

  Future<List<Map<String, dynamic>>> fetchLabData() async {
    QuerySnapshot querySnapshot = await labCollection.get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
