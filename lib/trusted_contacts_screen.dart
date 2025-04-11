import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';

class TrustedContactsScreen extends StatelessWidget {
  final List<Map<String, String>> contacts = [
    {
      "name": "Amma ❤️",
      "lastActive": "1 hrs ago",
      "phone": "9857463026",
    },
    {
      "name": "Appa 🌍",
      "lastActive": "30 mins ago",
      "phone": "3295474231",
    },
    {
      "name": "Akka 💖🎀",
      "lastActive": "Online",
      "phone": "3295474231",
    },
  ];

  void _showCallPopup(BuildContext context, String name, String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                name,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Icon(Icons.verified, color: Colors.green, size: 40),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () async {
                  Navigator.pop(context);
                  final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
                  if (await canLaunchUrl(callUri)) {
                    await launchUrl(callUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Cannot make call")));
                  }
                },
                child: Text("Ok", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }
  void _shareLiveLocation(BuildContext context, String contactName) async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final currentLocation = await location.getLocation();

    final latitude = currentLocation.latitude;
    final longitude = currentLocation.longitude;

    final googleMapsUrl = 'https://www.google.com/maps?q=$latitude,$longitude';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Location Shared With", style: TextStyle(color: Colors.white)),
              SizedBox(height: 5),
              Text(
                contactName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              Icon(Icons.location_on, size: 40, color: Colors.blue),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () async {
                  Navigator.pop(context);
                  if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                    await launchUrl(Uri.parse(googleMapsUrl),
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Text("Open Location", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
          backgroundColor: Colors.black,
        );
      },
    );
  }


  void _showLocationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your location has been shared to\nyour trusted contact\nsuccessfully !!!",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Icon(Icons.verified, color: Colors.green, size: 40),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Ok", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactCard(BuildContext context, Map<String, String> contact) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact["name"] ?? "",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 5),
            Text("Last active: ${contact["lastActive"]}",
                style: TextStyle(color: Colors.white70)),
            Text("Phone Number: ${contact["phone"]}",
                style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Send a text message...",
                hintStyle: TextStyle(color: Colors.white54),
                suffixIcon: Icon(Icons.send, color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {},
                    child: Text("I'm on my way", style: TextStyle(color: Colors.white))),
                TextButton(
                    onPressed: () {},
                    child: Text("I'm safe", style: TextStyle(color: Colors.white))),
                TextButton(
                    onPressed: () {},
                    child: Text("Help me", style: TextStyle(color: Colors.redAccent))),
              ],
            ),
            SizedBox(height: 5),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _showCallPopup(context, contact["name"]!, contact["phone"]!);
                    },
                    icon: Icon(Icons.call, color: Colors.white),
                    label: Text("Call"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add SOS alert logic
                    },
                    icon: Icon(Icons.warning, color: Colors.white),
                    label: Text("Send Alert/SOS"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _showLocationPopup(context);
                    },
                    child: Text("Share location"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Trusted Contacts"),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) =>
            _buildContactCard(context, contacts[index]),
      ),
    );
  }
}
