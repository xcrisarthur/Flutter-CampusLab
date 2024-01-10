import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Attendance extends StatefulWidget {
  const Attendance({Key? key});

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  String? selectedJobType; // Store the selected job type
  late TextEditingController descriptionController;

  DateTime? selectedStartTime;
  DateTime? selectedEndTime;

  late Stream<QuerySnapshot<Map<String, dynamic>>> attendanceStream;

  @override
  void initState() {
    super.initState();
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();
    selectedJobType = null;
    descriptionController = TextEditingController();

    // Fetch attendance data when the widget is initialized
    fetchAttendanceData();
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Function to calculate total time difference in hours
  double calculateTotalTime(DateTime start, DateTime end) {
    Duration difference = end.difference(start);
    return difference.inHours.toDouble();
  }

  // Function to show notification or pop-up
  Future<void> _showNotification(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to add data to the "attendance" collection
  Future<void> addAttendanceData() async {
    try {
      // Get user-input values
      DateTime startTime = selectedStartTime ?? DateTime.now();
      DateTime endTime =
          selectedEndTime ?? DateTime.now().add(Duration(hours: 2));
      String jobType = selectedJobType ?? "";
      String description = descriptionController.text;
      // Get the current user's email
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? "";
      // Calculate total time in hours
      double totalTime = calculateTotalTime(startTime, endTime);

      // Add data to the "attendance" collection
      await FirebaseFirestore.instance.collection('attendance').add({
        'email': userEmail,
        'start_time': startTime,
        'end_time': endTime,
        'job_type': jobType,
        'description': description,
        'total_time': totalTime,
      });
      // Show a success message or perform other actions
      print('Attendance data added successfully!');
    } catch (e) {
      // Handle errors and show a notification
      print('Error adding attendance data: $e');
      _showNotification('Error adding attendance data: $e');
    }
  }

  // Function to fetch attendance data from Firestore
  void fetchAttendanceData() {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      attendanceStream = FirebaseFirestore.instance
          .collection('attendance')
          .where('email', isEqualTo: userEmail)
          .snapshots();
    }
  }

  // Function to calculate the sum of total_time values for a specific job type
  Future<double> calculateTotalTimeSum(String jobType) async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('attendance')
          .where('email', isEqualTo: userEmail)
          .where('job_type', isEqualTo: jobType)
          .get();
      double sum = 0.0;
      for (var doc in snapshot.docs) {
        sum += doc['total_time'];
      }
      return sum;
    }
    return 0.0;
  }

  Future<void> _selectStartTime(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedStartTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          startTimeController.text = selectedStartTime!.toLocal().toString();
        });
      }
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    if (selectedStartTime == null) {
      // Show an error message or handle the case where start_time is not selected
      print('Please select start time first');
      _showNotification('Please select start time first');
      return;
    }
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartTime!,
      firstDate: selectedStartTime!,
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        DateTime selectedEndDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (selectedEndDateTime
            .isAfter(selectedStartTime!.add(Duration(hours: 1)))) {
          setState(() {
            selectedEndTime = selectedEndDateTime;
            endTimeController.text = selectedEndTime!.toLocal().toString();
          });
        } else {
          // Show an error message or handle the case where end_time is less than 1 hour after start_time
          print('End time must be at least 1 hour after start time');
          _showNotification(
              'End time must be at least 1 hour after start time');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int fixedRate = 12000;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Attendance Data:"),
            // Display total time sum for 'staff' job type
            FutureBuilder<double>(
              future: calculateTotalTimeSum('staff'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                double? sum = snapshot.data;
                return Text('Total Time (Staff): ${sum ?? 0} Hours');
              },
            ),
            // Display total time sum for 'maintenance' job type
            FutureBuilder<double>(
              future: calculateTotalTimeSum('maintenance'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                double? sum = snapshot.data;
                return Text('Total Time (Maintenance): ${sum ?? 0} Hours');
              },
            ),

            // Display total time sum for both 'staff' and 'maintenance'
            FutureBuilder<double>(
              future: calculateTotalTimeSumForBoth(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                double? totalSum = snapshot.data;
                num salary =
                    fixedRate * (totalSum ?? 0); // Calculate the salary

                // Format the salary as Indonesian Rupiah
                String formattedSalary = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp. ',
                  decimalDigits: 0,
                ).format(salary);

                return Column(
                  children: [
                    Text(
                      'Total Time (Staff + Maintenance): ${totalSum ?? 0.0} Hours',
                    ),
                    Text('Salary: $formattedSalary'),
                  ],
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
              child: Text("Enter Attendance:"),
            ),
            TextFormField(
              controller: startTimeController,
              onTap: () {
                _selectStartTime(context);
              },
              decoration: InputDecoration(labelText: 'Start Time'),
            ),
            TextFormField(
              controller: endTimeController,
              onTap: () {
                _selectEndTime(context);
              },
              decoration: InputDecoration(labelText: 'End Time'),
            ),
            DropdownButtonFormField<String>(
              value: selectedJobType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedJobType = newValue;
                });
              },
              items: <String>['maintenance', 'staff']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Job Type'),
            ),
            Visibility(
              visible: selectedJobType == 'maintenance',
              child: TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  // Call the function to add attendance data
                  addAttendanceData();
                },
                child: Text('Add Attendance'),
              ),
            ),
            SizedBox(height: 20),
            Text("Attendance History:"),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: attendanceStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  // Display the attendance data
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 5),
                        // Display individual attendance records
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.docs.length ?? 0,
                          itemBuilder: (context, index) {
                            var document = snapshot.data?.docs[index].data();
                            DateTime startTime =
                                (document?['start_time'] as Timestamp).toDate();
                            DateTime endTime =
                                (document?['end_time'] as Timestamp).toDate();

                            String formattedStartTime =
                                DateFormat('yyyy-MM-dd').format(startTime);
                            String formattedStartHours =
                                DateFormat('HH:mm').format(startTime);
                            String formattedEndHours =
                                DateFormat('HH:mm').format(endTime);

                            return Card(
                              elevation: 10,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text('Date: $formattedStartTime'),
                                    subtitle: Text(
                                        'Time: $formattedStartHours -> $formattedEndHours (${document?['job_type']})'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to calculate the sum of total_time values for both 'staff' and 'maintenance'
  Future<double> calculateTotalTimeSumForBoth() async {
    double staffSum = await calculateTotalTimeSum('staff');
    double maintenanceSum = await calculateTotalTimeSum('maintenance');

    return staffSum + maintenanceSum;
  }
}
