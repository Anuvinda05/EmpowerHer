import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:http/http.dart' as http;

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;
  late String _mapStyle;
  LatLng _selectedLocation = LatLng(12.9091, 80.2279); // Default SSN location
  BitmapDescriptor? _customMarkerIcon;
  String _locationName = "Fetching location...";
  String _locationAddress = "Fetching location...";
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String apiKey = dotenv.env['MAPS_API_KEY'] ?? 'No API Key';
  bool _permissionGranted = false;
  bool _isLoadingRoutes = false;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  LatLng? _fromLatLng;
  LatLng? _toLatLng;
  Marker? _fromMarker;
  Marker? _toMarker;

  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _showLocationPermissionPopup(); // Call the method to show the permission popup
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.json');
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
  }

  Widget _buildAddressInput(
      String label, TextEditingController controller, bool isFrom) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5)),
        ],
      ),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: controller,
        googleAPIKey: apiKey,
        inputDecoration: InputDecoration(
          hintText: "$label location...",
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        ),
        debounceTime: 500,
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (prediction) async {
          double lat = double.parse(prediction.lat!);
          double lng = double.parse(prediction.lng!);
          if (isFrom) {
            _fromLatLng = LatLng(lat, lng);
          } else {
            _toLatLng = LatLng(lat, lng);
          }

          if (_fromLatLng != null && _toLatLng != null) {
            await _fetchAndDrawRoutes(_fromLatLng!, _toLatLng!);
          }
        },
        itemClick: (prediction) {
          controller.text = prediction.description!;
        },
      ),
    );
  }

  Future<void> _fetchAndDrawRoutes(LatLng from, LatLng to) async {
    setState(() {
      _isLoadingRoutes = true; // Show loader
    });

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${from.latitude},${from.longitude}&destination=${to.latitude},${to.longitude}'
      '&alternatives=true&mode=driving&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<Polyline> newPolylines = [];

      for (int i = 0; i < data['routes'].length; i++) {
        final color = i == 0
            ? Colors.green
            : i == 1
                ? (data['routes'].length == 2 ? Colors.yellow : Colors.yellow)
                : Colors.red;

        final points =
            _decodePolyline(data['routes'][i]['overview_polyline']['points']);

        newPolylines.add(
          Polyline(
            polylineId: PolylineId('route$i'),
            color: color,
            width: 5,
            points: points,
          ),
        );
      }

      setState(() {
        _polylines.clear();
        _polylines.addAll(newPolylines);

        // Add markers for from and to
        _fromMarker = Marker(
          markerId: MarkerId("fromMarker"),
          position: from,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: "Start Point"),
        );

        _toMarker = Marker(
          markerId: MarkerId("toMarker"),
          position: to,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: "Destination"),
        );

        _isLoadingRoutes = false;
      });
    } else {
      print("Failed to fetch directions: ${response.statusCode}");
      setState(() {
        _isLoadingRoutes = false;
      });
    }
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
        ),
      ],
    );
  }

  Widget _buildLoadingSpinner() {
    return _isLoadingRoutes
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : const SizedBox.shrink();
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  // Method to get the user's location
  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the case when the user denies the permission
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Location permission is required to fetch accurate location details.")),
        );
        return;
      }
    }

    setState(() {
      _permissionGranted = true;
    });

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _updateLocationDetails(position.latitude, position.longitude);
  }

  // Method to show the location permission popup
  void _showLocationPermissionPopup() {
    Future.delayed(Duration(seconds: 2), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            "Allow DropSi to access this device's location?",
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                _getUserLocation(); // Call the method to get the user's location
              },
              child: Text(
                "ALLOW ONLY WHILE USING THE APP",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "DENY",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _updateLocationDetails(double latitude, double longitude) async {
    try {
      // Perform reverse geocoding
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Extract and prioritize relevant fields
        String buildingNumber = place.subThoroughfare ?? ""; // Building number
        String streetName = place.thoroughfare ?? ""; // Street name
        String locationName =
            _cleanSegmentIdentifier(place.name ?? ""); // Location name/building
        String locality = place.locality ?? ""; // City or town
        String administrativeArea = place.administrativeArea ?? ""; // State
        String postalCode = place.postalCode ?? ""; // Postal code
        String country = place.country ?? ""; // Country name
        String addressLine = [buildingNumber, streetName]
            .where((part) => part.isNotEmpty)
            .join(" ");
        String fullAddress = [
          if (locationName.isNotEmpty) locationName,
          if (addressLine.isNotEmpty) addressLine,
          if (locality.isNotEmpty) locality,
          if (administrativeArea.isNotEmpty) administrativeArea,
          if (postalCode.isNotEmpty) postalCode,
          if (country.isNotEmpty) country,
        ].join(", ");

        // Update the state
        setState(() {
          _selectedLocation = LatLng(latitude, longitude);
          _locationName =
              locationName.isNotEmpty ? locationName : "Unnamed Location";
          _locationAddress =
              fullAddress.isNotEmpty ? fullAddress : "Address not available";
        });

        // Move the map camera to the new location
        mapController
            .animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation, 16.0));
      } else {
        // Handle the case when no placemarks are found
        setState(() {
          _locationName = "Unknown Place";
          _locationAddress = "Address not available";
        });
      }
    } catch (e) {
      // Handle errors during reverse geocoding
      setState(() {
        _locationName = "Error Fetching Location";
        _locationAddress = "Please try again later.";
      });
      print("Error in reverse geocoding: $e");
    }
  }

  String _cleanSegmentIdentifier(String input) {
    RegExp segmentPattern = RegExp(r"^\d+\s*");
    return input.replaceAll(segmentPattern, "").trim();
  }

  // Method to locate the user
  void _locateMe() {
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _permissionGranted
          ? Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation,
                          zoom: 16.0,
                        ),
                        markers: {
                          if (_fromMarker != null) _fromMarker!,
                          if (_toMarker != null) _toMarker!,
                          Marker(
                            markerId: const MarkerId("deliveryLocation"),
                            position: _selectedLocation,
                            draggable: true,
                            onDragEnd: (LatLng newPosition) {
                              _updateLocationDetails(
                                  newPosition.latitude, newPosition.longitude);
                            },
                            icon: _customMarkerIcon ??
                                BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed),
                          ),
                        },
                        polylines: _polylines,
                        onTap: (LatLng latLng) {
                          _updateLocationDetails(
                              latLng.latitude, latLng.longitude);
                        },
                        zoomControlsEnabled: false,
                      ),
                      _buildLoadingSpinner(),
                      Positioned(
                        top: 10,
                        right: 15,
                        child: Container(
                          margin: const EdgeInsets.only(top: 150, right: 15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: Offset(0, 3)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Markers",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              _buildLegendItem("From", Colors.deepPurpleAccent),
                              _buildLegendItem("To", Colors.orange),
                              const SizedBox(height: 8),
                              const Text(
                                "Routes",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              _buildLegendItem("Safe", Colors.green),
                              _buildLegendItem("Moderate", Colors.yellow),
                              _buildLegendItem("Risky", Colors.red),
                            ],
                          ),
                        ),
                      ),

                      // From and To Input Overlay
                      Positioned(
                        top: 20,
                        left: 15,
                        right: 15,
                        child: Column(
                          children: [
                            _buildAddressInput("From", _fromController, true),
                            const SizedBox(height: 10),
                            _buildAddressInput("To", _toController, false),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: MediaQuery.of(context).size.width / 2 - 65,
                        child: GestureDetector(
                          onTap: _locateMe,
                          child: Container(
                            height: 50,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.my_location, color: Colors.green),
                                SizedBox(width: 5),
                                Text(
                                  "LOCATE ME",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
