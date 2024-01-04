import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddReport extends StatefulWidget {
  const AddReport({Key? key}) : super(key: key);

  @override
  _AddReportState createState() => _AddReportState();
}

class _AddReportState extends State<AddReport> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  TextEditingController noItemController = TextEditingController();

  int selectedNumber = 1;
  int selectedItemIndex = 0;

  Map<String, dynamic> loggedInUserData = {};
  List<String> locationOptions = [];
  String selectedLocation = '';

  List<String> itemOptions = [];
  String selectedItem = '';

  Map<String, dynamic> pcData = {};
  int jumlahValue = 0;

  @override
  void initState() {
    super.initState();
    fetchUserDataByEmail();
    fetchLabData();
  }

  Future<void> fetchDocumentData() async {
    try {
      DocumentSnapshot labolatoriumDoc = await FirebaseFirestore.instance
          .collection('labolatorium')
          .doc(selectedLocation)
          .get();

      if (labolatoriumDoc.exists) {
        Map<String, dynamic> documentData =
            labolatoriumDoc.data() as Map<String, dynamic>;

        setState(() {
          itemOptions = documentData.keys.toList();
          selectedItem = itemOptions.isNotEmpty ? itemOptions[0] : '';

          var itemData = documentData[selectedItem];
          if (itemData is Map<String, dynamic>) {
            pcData = itemData;
            jumlahValue = itemData['jumlah'];
          } else {
            if (kDebugMode) {
              print('Error: Invalid data format for $selectedItem');
            }
            pcData = {};
          }
        });
      } else {
        if (kDebugMode) {
          print('Labolatorium document does not exist');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching lab data: $e');
      }
    }
  }

  void fetchUserDataByEmail() async {
    try {
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? "";
      loggedInUserData = await getUserByEmail(userEmail);
      setState(() {
        // Update the UI with the fetched user data
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    final QuerySnapshot usersQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (usersQuery.docs.isNotEmpty) {
      return usersQuery.docs.first.data() as Map<String, dynamic>;
    } else {
      throw Exception('User not found');
    }
  }

  Future<void> updateStatusInArray() async {
    try {
      DocumentSnapshot labDocument = await FirebaseFirestore.instance
          .collection('labolatorium')
          .doc(selectedLocation)
          .get();

      if (labDocument.exists) {
        List<dynamic> currentStatusArray = labDocument[selectedItem]['status'];
        int noItem = int.tryParse(noItemController.text.trim()) ?? 0;

        currentStatusArray[noItem - 1] = descriptionController.text.trim();

        await FirebaseFirestore.instance
            .collection('labolatorium')
            .doc(selectedLocation)
            .update({
          '$selectedItem.status': currentStatusArray,
        });

        fetchDocumentData();
      } else {
        if (kDebugMode) {
          print('Labolatorium document does not exist');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating status: $e');
      }
    }
  }

  Future<void> fetchLabData() async {
    try {
      final QuerySnapshot labDataQuery =
          await FirebaseFirestore.instance.collection('labolatorium').get();

      setState(() {
        locationOptions = labDataQuery.docs
            .map((doc) => doc['labolatorium'] as String)
            .toList();
        selectedLocation = locationOptions.isNotEmpty ? locationOptions[0] : '';
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching lab data: $e');
      }
    }
  }

  Future<void> addReport() async {
    try {
      String userId = loggedInUserData['id'];
      Timestamp currentDate = Timestamp.now();

      String location = selectedLocation;
      String description = descriptionController.text.trim();
      String item = selectedItem;
      int noItem = int.tryParse(noItemController.text.trim()) ?? 0;

      await FirebaseFirestore.instance.collection('reports').add({
        'NRP/NIM': userId,
        'date': currentDate,
        'location': location,
        'description': description,
        'item': item,
        'noItem': noItem,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report added successfully'),
        ),
      );
    } catch (e) {
      print('Error adding report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField(
              value: selectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  selectedLocation = newValue!;
                });
                fetchDocumentData();
              },
              items: locationOptions
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(labelText: 'LABOLATORIUM'),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField(
              value: selectedItem,
              onChanged: (String? newValue) {
                setState(() {
                  selectedItem = newValue!;
                });
              },
              items: itemOptions
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(labelText: 'ITEM'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: noItemController,
              decoration: const InputDecoration(labelText: 'NO ITEM'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'DESCRIPTION'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                addReport();
                updateStatusInArray();
              },
              child: const Text('Add Report'),
            ),
          ],
        ),
      ),
    );
  }
}
