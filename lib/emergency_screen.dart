import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool isMicrophoneOn = true;
  bool isPanicMovementOn = true;

  String selectedAction = "";
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isSirenPlaying = false;

  Future<void> _playSiren() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('siren.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Emergency / SOS",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Card(
                color: Colors.grey[900],
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Smart Detection System", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("Bluetooth Device: Smartwatch connected ✅", style: TextStyle(color: Colors.green)),
                      Text("Charge: 76% 🔋   Time remaining: 3hr 40 mins", style: TextStyle(color: Colors.white)),
                      SizedBox(height: 10),
                      _statusBar("Heart Rate", 85, Colors.red),
                      _statusBar("Blood Pressure", 115, Colors.green),
                    ],
                  ),
                ),
              ),
              Card(
                color: Colors.grey[850],
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Voice and Panic Movement Detection System", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _toggleSetting("Microphone Access", isMicrophoneOn, (val) {
                            setState(() {
                              isMicrophoneOn = val;
                            });
                          }),
                          _toggleSetting("Panic Movement", isPanicMovementOn, (val) {
                            setState(() {
                              isPanicMovementOn = val;
                            });
                          }),
                        ],
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Record your voice note here...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {},
                        child: Text("Send recorded voice note", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _actionButton(Icons.flashlight_on, "Torch"),
                    _actionButton(Icons.warning, "Siren"),
                    _actionButton(Icons.phone, "Auto Call"),
                    _actionButton(Icons.location_on, "Live Location"),
                    _actionButton(Icons.mic, "Audio Recorder"),
                    _actionButton(Icons.local_hospital, "Medical"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Click your Volume Down button 3 times or shake your phone 5 times to send an ALERT!",
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value", style: TextStyle(color: Colors.white)),
        LinearProgressIndicator(
          value: value / 200,
          backgroundColor: Colors.white,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _toggleSetting(String label, bool isOn, Function(bool) onChanged) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Colors.white)),
        Switch(value: isOn, onChanged: onChanged),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    bool isSelected = selectedAction == label;

    return GestureDetector(
      onTap: () async {
        if (label == "Siren") {
          if (isSelected) {
            // Stop siren and deselect
            await _audioPlayer.stop();
            setState(() {
              selectedAction = "";
            });
          } else {
            // Play siren and select
            await _playSiren();
            setState(() {
              selectedAction = "Siren";
            });
          }
        } else {
          setState(() {
            selectedAction = label;
          });
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isSelected ? Colors.blue : Colors.grey[800],
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[300],
              size: 30,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
