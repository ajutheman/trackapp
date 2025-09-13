import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPointSelector extends StatefulWidget {
  @override
  _MapPointSelectorState createState() => _MapPointSelectorState();
}

class _MapPointSelectorState extends State<MapPointSelector> {
  LatLng? _selectedLocation;
  late GoogleMapController _mapController;

  static const CameraPosition _initialPosition = CameraPosition(target: LatLng(10.8505, 76.2711), zoom: 6);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Point on Map')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _initialPosition,
        onTap: _onTap,
        markers: _selectedLocation != null ? {Marker(markerId: MarkerId('selected_point'), position: _selectedLocation!)} : {},
      ),
      floatingActionButton:
          _selectedLocation != null
              ? FloatingActionButton.extended(
                onPressed: () {
                  print("Selected Location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}");
                  Navigator.pop(context, _selectedLocation!);
                },
                label: Text("Confirm"),
                icon: Icon(Icons.check),
              )
              : null,
    );
  }
}
