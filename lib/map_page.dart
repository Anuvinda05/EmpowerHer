import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

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

  final List<LatLng> safeRoute = [
    LatLng(12.9091, 80.2279),
    LatLng(12.9100, 80.2300),
    LatLng(12.9115, 80.2320),
  ];

  final List<LatLng> moderateRoute = [
    LatLng(12.9091, 80.2279),
    LatLng(12.9080, 80.2290),
    LatLng(12.9075, 80.2310),
  ];

  final List<LatLng> riskyRoute = [
    LatLng(12.9091, 80.2279),
    LatLng(12.9065, 80.2280),
    LatLng(12.9050, 80.2300),
  ];

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
    setState(() {
      _setPolylines();
    });
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

  void _setPolylines() {
    _polylines.addAll([
      Polyline(
        polylineId: PolylineId("safe"),
        points: safeRoute,
        color: Colors.green,
        width: 5,
      ),
      Polyline(
        polylineId: PolylineId("moderate"),
        points: moderateRoute,
        color: Colors.yellow,
        width: 5,
      ),
      Polyline(
        polylineId: PolylineId("risky"),
        points: riskyRoute,
        color: Colors.red,
        width: 5,
      ),
    ]);
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
                      // Floating Search Bar
                      Positioned(
                        top: 20,
                        left: 15,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          child: GooglePlaceAutoCompleteTextField(
                            textEditingController: _searchController,
                            googleAPIKey: apiKey, // Replace with your API Key
                            inputDecoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search location...",
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            debounceTime:
                                500, // Delay in milliseconds before API request
                            isLatLngRequired: true, // Get Latitude & Longitude
                            getPlaceDetailWithLatLng: (prediction) async {
                              double lat = double.parse(prediction.lat!);
                              double lng = double.parse(prediction.lng!);
                              _updateLocationDetails(lat, lng);
                            },
                            itemClick: (prediction) {
                              _searchController.text = prediction.description!;
                            },
                            boxDecoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            focusNode: _searchFocusNode,
                          ),
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
                _buildBottomBar(_locationName, _locationAddress),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  // Method to build the bottom bar
  Widget _buildBottomBar(String locationName, String locationAddress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        locationName, // Dynamic place name
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(_searchFocusNode);
                },
                child: const Text(
                  "CHANGE",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            locationAddress, // Dynamic address
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              print(locationName);
              print(locationAddress);
              _showmodalbottomsheet(context);
            },
            child: const Text(
              "CONFIRM LOCATION",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showmodalbottomsheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8, // Covers 80% of the screen height
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationName, // Location Name (Bold, Poppins)
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  _locationAddress, // Location Address (Poppins)
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Alert Box (Beige Background)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0), // Light beige background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "A detailed address will help our Delivery Partner reach your doorstep easily",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.brown,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Address Input Fields
                const TextField(
                  decoration: InputDecoration(
                    labelText: "HOUSE / FLAT / BLOCK NO.",
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                const TextField(
                  decoration: InputDecoration(
                    labelText: "APARTMENT / ROAD / AREA (OPTIONAL)",
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                const TextField(
                  decoration: InputDecoration(
                    labelText: "DIRECTIONS TO REACH (OPTIONAL)",
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    border: UnderlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
