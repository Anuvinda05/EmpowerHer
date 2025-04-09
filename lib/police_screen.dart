import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class PoliceScreen extends StatelessWidget {
  final List<Map<String, String>> policeStations = [
    {
      "name": "Tuticorin Central Police Station",
      "address": "R858+C46, West Great Cotton Road, Thoothukudi, Tamil Nadu 628001",
      "phone": "0461 232 1600",
      "time": "8 mins",
      "image": "assets/map1.jpg",
      "mapLink": "https://maps.app.goo.gl/a97q5zfC6PWVqbs69"
    },
    {
      "name": "North Crime Police Station",
      "address": "R867+M72, Cruz Puram, Thoothukudi, Tamil Nadu 628001",
      "phone": "0461 232 1600",
      "time": "10 mins",
      "image": "assets/map2.jpg",
      "mapLink": "https://maps.app.goo.gl/2rj9g6hPuTMydkN67"
    },
    {
      "name": "South Police Station",
      "address": "R24F+PW4, National Highway 7A, Subhaiah Puram, Thoothukudi, Tamil Nadu 628002",
      "phone": "0461 232 1850",
      "time": "12 mins",
      "image": "assets/map3.jpg",
      "mapLink":"https://maps.app.goo.gl/PXchWfzqMwXpt6mC6"
    },
  ];
void _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
  void _showCallPopup(BuildContext context, String stationName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Call is being Forwarded to",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                stationName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Icon(Icons.verified, color: Colors.green, size: 40),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Ok", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
  void _showAlertPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Alert Sent!!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Icon(Icons.verified, color: Colors.green, size: 40), // Success Icon
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Ok", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/police logo.png", height: 40), // Police Logo Image
            SizedBox(width: 10),
            Text(
              "Police Stations",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: policeStations.length,
        itemBuilder: (context, index) {
          var station = policeStations[index];
          return _buildPoliceCard(context, station);
        },
      ),
    );
  }

  Widget _buildPoliceCard(BuildContext context,Map<String, String> station) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              station["name"]!,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(station["address"]!, style: TextStyle(fontSize: 14)),
            SizedBox(height: 5),
            Text("Timings: OPEN 24/7", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Row(
              children: [
                Text("Phone number: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(station["phone"]!)
              ],
            ),
            if (station["mapLink"] != null) ...[
              SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  // You need url_launcher for this to work
                  _launchURL(station["mapLink"]!);
                },
                child: Text(
                  "View on Map",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showCallPopup(context, station["name"]!);
                    },
                    icon: Icon(Icons.call, color: Colors.white),
                    label: Text("Call"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAlertPopup(context);
                    },
                    icon: Icon(Icons.warning, color: Colors.white),
                    label: Text("Send Alert/SOS"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
