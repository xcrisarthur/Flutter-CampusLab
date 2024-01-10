import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? loggedInUserData;
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLoggedInUserData();
  }

  void fetchLoggedInUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        QuerySnapshot usersQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (mounted) {
          loggedInUserData = usersQuery.docs.isNotEmpty
              ? usersQuery.docs.first.data() as Map<String, dynamic>
              : {};

          _nameController.text = loggedInUserData?['name'] ?? '';

          setState(() {});
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void updateUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .get()
            .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            querySnapshot.docs.first.reference.update({
              'name': _nameController.text,
            });
          }
        });

        fetchLoggedInUserData();
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loggedInUserData != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${loggedInUserData!['name']}'),
                  Text('Email: ${loggedInUserData!['email']}'),
                  Text('Role: ${loggedInUserData!['role']}'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'New Name'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: updateUserData,
                    child: Text('Update Profile'),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
