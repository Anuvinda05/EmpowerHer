import 'package:empower_her/map_page.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'travel_screen.dart';
import 'police_screen.dart';
import 'trusted_contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget?> _pages = [
    null, // Home
    TravelScreen(),
    PoliceScreen(),
    TrustedContactsScreen(),
    null, // Emergency
  ];

  void _onItemTapped(int index) async {
    if (_pages[index] != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]!),
      );
      setState(() {
        _selectedIndex = 0; // Reset to Home after coming back
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: MapsPage(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: "Travel",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_police),
            label: "Police",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: "Emergency",
          ),
        ],
      ),
    );
  }
}
