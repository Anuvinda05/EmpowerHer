import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TravelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Travel",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Box
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.radio_button_checked, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        "Your location",
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.black),
                      ),
                    ],
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Enter your Destination",
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // List of Locations
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildLocationItem(Icons.home, "Home"),
                  _buildLocationItem(Icons.location_on, "Our Lady of Snows Basilica"),
                  _buildLocationItem(Icons.beach_access, "Hare Island"),
                  _buildLocationItem(Icons.landscape, "Manapad Beach"),
                  _buildLocationItem(Icons.temple_hindu, "Sri Vaikuntam Temple"),
                  _buildLocationItem(Icons.fort, "Kattabomman Memorial Fort"),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Places Nearby Section
            Text(
              "Places Nearby Your Location",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSafetyCard("assets/lady-of-snows.jpg", "Our Lady of Snows Basilica", "9", "HIGHLY SAFE", Colors.green),
                _buildSafetyCard("assets/harbour_beach.jpg", "Thoothukudi Harbour Beach", "5", "UNSAFE", Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Location List Item
  Widget _buildLocationItem(IconData icon, String location) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        location,
        style: TextStyle(color:Colors.black,fontSize: 16),
      ),
      onTap: () {
        // Navigate to the selected location
      },
    );
  }

  // Safety Cards
  Widget _buildSafetyCard(String imagePath, String place, String score, String status, Color color) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: 80, fit: BoxFit.cover),
          SizedBox(height: 5),
          Text(place, style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 3),
          Text(
            "SAFETY SCORE: $score",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            status,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
