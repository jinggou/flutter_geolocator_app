import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

const List<String> cityList = <String>['Chicago', 'New York', 'Paris', 'Singapore'];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late bool servicePermission = false;
  late LocationPermission permission;

  Position? _currentLocation;
  Location? _selectedLocation;

  String _currentAddress = "";
  String _selectedAddress = cityList.first;

  int _distance = 0;

  @override
  initState() {
    super.initState();

     // Fetch location when the app starts
    _initialize();
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    if (_currentLocation != null) {
      await _getAddressFromCoordinates(_currentLocation!);
    }
    if (_selectedAddress != "") {
      await _getCoordinatesFromAddress(_selectedAddress);
    }
    await _calculateDistance();
  }

  Future<void> _getCurrentLocation() async {
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

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = position;
    });
  }

  // convert the coorninate into address
  _getAddressFromCoordinates(Position location) async {
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

  _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      setState(() {
        _selectedLocation = locations.first;
      });
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
            Text(
              "Current Location", 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 6),
            LocationCard(currentAddress: _currentAddress, currentLocation: _currentLocation),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await _getCurrentLocation();
                if (_currentLocation != null) {
                  await _getAddressFromCoordinates(_currentLocation!);
                }
              }, 
              child: Text("Update")
            ),

            SizedBox(height: 60),

            Text(
              "Select City", 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 6),
            DropdownButton(
              value: _selectedAddress,
              items: cityList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) async {
                setState(() {
                  _selectedAddress = value!;
                });
                await _getCoordinatesFromAddress(value!);
              },
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
            ),

            SizedBox(height: 60),

            Text(
              "Distance", 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 6),
            Text("${_distance} miles"),
            
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await _calculateDistance();
              },
              child: Text("Calculate")
            ),
          ],
      )),
    );
  }
}

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.currentAddress,
    required this.currentLocation,
  });

  final String currentAddress;
  final Position? currentLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text("${currentAddress}", style: style),
            SizedBox(height: 5),
            Text("(${currentLocation?.latitude}, ${currentLocation?.longitude})", style: style),
          ],
        ),
      ),
    );
  }
}