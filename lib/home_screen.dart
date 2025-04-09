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
  int _selectedIndex = 0; // Current selected tab index

  // List of destinations
  final List<Widget?> _pages = [
    null, // Home (Already on HomeScreen)
    TravelScreen(),
    PoliceScreen(), // Police
    TrustedContactsScreen(),// Contacts
    null, // Emergency
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_pages[index] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]!),
      );
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
        title: Text(
          "Home",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map Image
          Positioned.fill(
            child: Image.asset(
              "assets/homemap.jpg",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    "Image not found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, "Home", 0),
                  _buildNavItem(Icons.directions_car, "Travel", 1),
                  _buildNavItem(Icons.local_police, "Police", 2),
                  _buildNavItem(Icons.contacts, "Contacts", 3),
                  _buildNavItem(Icons.warning, "Emergency", 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.white, // Highlight selected icon
            size: isSelected ? 35 : 30, // Increase size if selected
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.white, // Highlight text
              fontSize: isSelected ? 14 : 12, // Slightly increase font size if selected
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
