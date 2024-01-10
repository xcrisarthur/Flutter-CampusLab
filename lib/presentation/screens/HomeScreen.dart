import 'package:cuberto_bottom_bar/internal/internal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_uilogin/presentation/screens/LabPage.dart';
import 'package:flutter_uilogin/presentation/screens/ProfileScreen.dart';
import 'package:flutter_uilogin/presentation/screens/ReportScreen.dart';
import 'package:flutter_uilogin/presentation/screens/AttendanceScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> usersData = [];
  Map<String, dynamic> loggedInUserData = {};

  Map<String, int> userDataCounts = {
    'Dosen': 0,
    'Mahasiswa': 0,
    'Staff': 0,
  };

  bool isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchUserDataByEmail();
  }

  void fetchUserDataByEmail() async {
    try {
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? "";
      loggedInUserData = await getUserByEmail(userEmail);
      setState(() {
        isLoading = false;
      });
      // print('Logged-in User Data: $loggedInUserData');
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void fetchData() async {
    try {
      List<Map<String, dynamic>> userData = await getAllUsersData();
      Map<String, int> counts = countUserDataByRole(userData);
      setState(() {
        usersData = userData;
        userDataCounts = counts;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsersData() async {
    final QuerySnapshot usersQuery =
        await FirebaseFirestore.instance.collection('users').get();

    return usersQuery.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
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

  Map<String, int> countUserDataByRole(List<Map<String, dynamic>> userData) {
    int jumlahDosen = 0;
    int jumlahMahasiswa = 0;
    int jumlahStaff = 0;

    for (var user in userData) {
      String role = user['role'];
      if (role == 'dosen') {
        jumlahDosen++;
      } else if (role == 'mahasiswa') {
        jumlahMahasiswa++;
      } else if (role == 'staff') {
        jumlahStaff++;
      }
    }

    return {
      'Dosen': jumlahDosen,
      'Mahasiswa': jumlahMahasiswa,
      'Staff': jumlahStaff,
    };
  }

  double _fontSizeHeading = 1;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    double screenWidth = MediaQuery.of(context).size.width;
    _fontSizeHeading = screenWidth * 0.05;

    _fontSizeHeading = _fontSizeHeading.clamp(0.0, 25);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentPage == 0
            ? Text('Dashboard - ${loggedInUserData['role']}',
                style: TextStyle(
                  fontSize: _fontSizeHeading,
                  // fontWeight: FontWeight.bold,
                ))
            : _currentPage == 1
                ? Text('Reports')
                : _currentPage == 2
                    ? Text('Profile')
                    : Text('Attendance'),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(Icons.logout, size: _fontSizeHeading),
            ),
          )
        ],
      ),
      body: isLoading
          ? CircularProgressIndicator()
          : IndexedStack(
              index: _currentPage,
              children: [
                HomeScreen(
                  userDataCounts: userDataCounts,
                  usersData: usersData,
                  loggedInUserData:
                      loggedInUserData, // Pass loggedInUserData to HomeScreen
                ),
                Report(),
                Profile(),
                Attendance(),
              ],
            ),
      bottomNavigationBar: CubertoBottomBar(
        tabs: [
          TabData(
            iconData: Icons.home,
            title: '•',
            tabColor: Colors.amber[900],
          ),
          TabData(
            iconData: Icons.file_open,
            title: '•',
          ),
          TabData(
            iconData: Icons.person,
            title: '•',
          ),
          if (loggedInUserData['role'] == 'staff')
            TabData(
              iconData: Icons.access_alarm,
              title: '•',
            ),
        ],
        selectedTab: _currentPage,
        onTabChangedListener: (position, title, color) {
          setState(() {
            _currentPage = position;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Map<String, int> userDataCounts;
  final List<Map<String, dynamic>> usersData;
  final Map<String, dynamic> loggedInUserData;

  HomeScreen({
    required this.userDataCounts,
    required this.usersData,
    required this.loggedInUserData,
  });
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<CardContent> cardContents = [
    CardContent(
      title: "Multimedia",
      icon: Icons.computer,
      labType: "Multimedia",
    ),
    CardContent(
      title: "Database",
      icon: Icons.dataset,
      labType: "Database",
    ),
    CardContent(
      title: "Network",
      icon: Icons.network_check,
      labType: "Network",
    ),
  ];

  double _fontSize = 1;
  double _fontSizeHeading = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    double screenWidth = MediaQuery.of(context).size.width;
    _fontSize = screenWidth * 0.03;
    _fontSize = _fontSize.clamp(0.0, 15);

    _fontSizeHeading = screenWidth * 0.04;
    _fontSizeHeading = _fontSizeHeading.clamp(0.0, 20);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Text(
              "Hai ${widget.loggedInUserData['name']}",
              style: TextStyle(
                fontSize: _fontSizeHeading,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.userDataCounts.length,
            itemBuilder: (context, index) {
              String role = widget.userDataCounts.keys.elementAt(index);
              int count = widget.userDataCounts[role] ?? 0;
              return Card(
                elevation: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Jumlah $role',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _fontSize,
                      ),
                    ),
                    Text(
                      count.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _fontSize,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Text(
              "Labolatorium",
              style: TextStyle(
                fontSize: _fontSizeHeading,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: cardContents.length,
            itemBuilder: (context, index) {
              CardContent content = cardContents[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LabPage(
                          labType: content.labType,
                          userRole: widget
                              .loggedInUserData['role'], // Pass the user role
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(content.icon, size: _fontSize),
                      Text(
                        content.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: _fontSize),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CardContent {
  final String title;
  final IconData icon;
  final String labType;

  CardContent({required this.title, required this.icon, required this.labType});
}
