import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const GeolocatorApp(),
    );
  }
}

class GeolocatorApp extends StatefulWidget {
  const GeolocatorApp({super.key});

  @override
  State<GeolocatorApp> createState() => _GeolocatorAppState();
}

class _GeolocatorAppState extends State<GeolocatorApp> {
  late bool servicePermission = false;
  late LocationPermission permission;

  Position? _currentLocation;
  Location? _selectedLocation;

  String _currentAddress = "";
  String _selectedAddress = "";

  int _distance = 0;

  Future<Position> _getCurrentLocation() async {
    // check if the user have permission to access location service
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print("service disabled");
    }

    // when the location service is enabled on the device, check if it has permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }

  // convert the coorninate into address
  _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_currentLocation!.latitude, _currentLocation!.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = "${place.locality}, ${place.country}";
      });
    } catch (e) {
      print('Error: ${e}');
    }
  }

  String _getSelectedAddress() {
    String address = "Chicago";
      setState(() {
        _selectedAddress = address;
      });
    return address;
  }

  _getCoordinatesFromAddress() async {
    try {

      List<Location> locations = await locationFromAddress(_selectedAddress);

      setState(() {
        _selectedLocation = locations.first;
      });
      print('Selected location - Latitude: ${_selectedLocation?.latitude}, Longitude: ${_selectedLocation?.longitude}');
    } catch (e) {
      print('Error: ${e}');
    }
  }

  // calculate distance between current location and selected location
  _calculateDistance() {
    if (_currentLocation != null && _selectedLocation != null) { 
      double distanceInMeters = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );
      
      // Convert distance in meters to miles
      const double metersToMiles = 1609.34;
      int distanceInMiles = (distanceInMeters / metersToMiles).round();

      setState(() {
        _distance = distanceInMiles;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Geolocator"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                _currentLocation = await _getCurrentLocation();
                await _getAddressFromCoordinates();
              }, 
              child: Text("get current location")
            ),

            SizedBox(height: 30),

            Text(
              "Current location coordinates", 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 6),
            Text("Latitude: ${_currentLocation?.latitude}; Longitude: ${_currentLocation?.longitude}"),

            SizedBox(height: 30),

            Text(
              "Current location address", 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 6),
            Text("${_currentAddress}"),

            SizedBox(height: 50),
            
            ElevatedButton(
              onPressed: () async {
                _selectedAddress = _getSelectedAddress();
                await _getCoordinatesFromAddress();
                print("${_selectedLocation}");
                print("${_selectedAddress}");
              }, 
              child: Text("get selected location")
            ),

            SizedBox(height: 30),

            Text(
              "Selected location coordinates", 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 6),
            Text("Latitude: ${_selectedLocation?.latitude}; Longitude: ${_selectedLocation?.longitude}"),

            SizedBox(height: 30),

            Text(
              "Selected location address", 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 6),
            Text("${_selectedAddress}"),

            SizedBox(height: 50),
            
            ElevatedButton(
              onPressed: () async {
                await _calculateDistance();
              }, 
              child: Text("calculate distance")
            ),

            SizedBox(height: 30),

            Text(
              "Distance", 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 6),
            Text("${_distance} miles"),
          ],
      )),
    );
  }
}