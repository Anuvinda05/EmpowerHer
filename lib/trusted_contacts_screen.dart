import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:url_launcher/url_launcher.dart';

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  _TrustedContactsScreenState createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  List<Contact> deviceContacts = [];
  List<TextEditingController> _controllers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndFetchContacts();
  }

  Future<void> _requestPermissionAndFetchContacts() async {
    final status = await Permission.contacts.status;

    if (status.isGranted) {
      fetchContacts();
    } else if (status.isDenied) {
      final result = await Permission.contacts.request();
      if (result.isGranted) {
        fetchContacts();
      } else {
        _showPermissionDenied();
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void fetchContacts() async {
    final contacts = await ContactsService.getContacts(withThumbnails: false);
    setState(() {
      deviceContacts = contacts.where((c) => c.phones!.isNotEmpty).toList();
      _controllers =
          List.generate(deviceContacts.length, (_) => TextEditingController());
      isLoading = false;
    });
  }

  void _showPermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permission denied to access contacts'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  void _sendRealSMS(String phone, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch SMS app')),
      );
    }
  }

  void _showCallPopup(
      BuildContext context, String name, String phoneNumber) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Call is being Forwarded to",
                style: TextStyle(fontSize: 16, color: Colors.white)),
            SizedBox(height: 5),
            Text(name,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 10),
            Icon(Icons.verified, color: Colors.green, size: 40),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
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
      ),
    );
  }

  void _showMessagePopup(
      BuildContext context, String name, String message, Icon icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Message sent to", style: TextStyle(color: Colors.white)),
            SizedBox(height: 5),
            Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white)),
            SizedBox(height: 10),
            icon,
            SizedBox(height: 10),
            Text(message,
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
              child: Text("Ok", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  void _shareLiveLocation(BuildContext context, String contactName) async {
    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    var permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }

    final currentLocation = await location.getLocation();
    final latitude = currentLocation.latitude;
    final longitude = currentLocation.longitude;

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Unable to fetch location")));
      return;
    }

    final googleMapsUrl = 'https://www.google.com/maps?q=$latitude,$longitude';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.black,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Location Shared With", style: TextStyle(color: Colors.white)),
            SizedBox(height: 5),
            Text(contactName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white)),
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
              child:
                  Text("Open Location", style: TextStyle(color: Colors.white)),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              itemCount: deviceContacts.length,
              itemBuilder: (context, index) {
                final contact = deviceContacts[index];
                final name = contact.displayName ?? "Unnamed";
                final phone = contact.phones!.isNotEmpty
                    ? contact.phones!.first.value ?? "No number"
                    : "No number";
                final messageController = _controllers[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text("Phone: $phone",
                            style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 10),
                        Text("Quick Message:",
                            style: TextStyle(color: Colors.white)),
                        Wrap(
                          spacing: 10,
                          runSpacing: 5,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _sendRealSMS(phone, "I'm on my way "),
                              child: Text("I'm on my way",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            TextButton(
                              onPressed: () => _sendRealSMS(phone, "I'm safe"),
                              child: Text("I'm safe",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            TextButton(
                              onPressed: () => _sendRealSMS(phone, "Help me"),
                              child: Text("Help me",
                                  style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: messageController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Type your message...",
                                    hintStyle: TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.send, color: Colors.lightBlue),
                                onPressed: () {
                                  final message = messageController.text.trim();
                                  if (message.isNotEmpty) {
                                    _sendRealSMS(phone, message);
                                    messageController.clear();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _showCallPopup(context, name, phone),
                              icon: Icon(Icons.call, color: Colors.white),
                              label: Text("Call"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                loc.Location location = loc.Location();
                                var currentLocation =
                                    await location.getLocation();
                                final latitude = currentLocation.latitude;
                                final longitude = currentLocation.longitude;

                                final locationLink =
                                    "https://maps.google.com/?q=$latitude,$longitude";
                                final sosMessage =
                                    "🚨 Emergency! I need help. My location: $locationLink";

                                _sendRealSMS(phone, sosMessage);
                              },
                              icon: Icon(Icons.warning, color: Colors.white),
                              label: Text("Send Alert/SOS"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _shareLiveLocation(context, name),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue),
                              child: Text("Share location"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
