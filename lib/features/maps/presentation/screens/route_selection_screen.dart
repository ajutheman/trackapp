import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import '../../repo/route_repository.dart';
import '../../data/models/route_model.dart';

class RouteSelectionScreen extends StatefulWidget {
  final LatLng startPoint;
  final LatLng endPoint;

  const RouteSelectionScreen({
    super.key,
    // Defaulting to Kochi -> Bangalore for demo if not provided
    this.startPoint = const LatLng(9.9312, 76.2673),
    this.endPoint = const LatLng(12.9716, 77.5946),
  });

  @override
  State<RouteSelectionScreen> createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  final RouteRepository _repository = RouteRepository();
  List<RouteModel> _routes = [];
  int _selectedRouteIndex = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final routes = await _repository.getRoutes(
        widget.startPoint,
        widget.endPoint,
      );
      setState(() {
        _routes = routes;
        _isLoading = false;
        if (routes.isNotEmpty) {
          _selectedRouteIndex = 0; // Select first (usually best) by default
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onRouteSelected(int index) {
    setState(() {
      _selectedRouteIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Route'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.startPoint, // Center on start typically
              initialZoom: 7.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.spydo.truck_app',
              ),
              if (_routes.isNotEmpty)
                PolylineLayer(
                  polylines:
                      _routes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final route = entry.value;
                        final isSelected = index == _selectedRouteIndex;

                        return Polyline(
                          points: route.points,
                          strokeWidth: isSelected ? 5.0 : 3.0,
                          color:
                              isSelected
                                  ? Colors.blue
                                  : Colors.grey.withOpacity(0.6),
                          // We can add interaction here if supported by newer flutter_map,
                          // or just rely on the bottom sheet for selection.
                        );
                      }).toList(),
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.startPoint,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  Marker(
                    point: widget.endPoint,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else if (_routes.isEmpty)
            const Center(child: Text('No routes found')),

          if (!_isLoading && _routes.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Available Routes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _routes.length,
                        itemBuilder: (context, index) {
                          final route = _routes[index];
                          final isSelected = index == _selectedRouteIndex;
                          final durationMins = (route.duration / 60).round();
                          final distanceKm = (route.distance / 1000)
                              .toStringAsFixed(1);

                          return GestureDetector(
                            onTap: () => _onRouteSelected(index),
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.blue
                                          : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Route ${index + 1}',
                                    // route.description ?? 'Route ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$durationMins min',
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.blue
                                              : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '$distanceKm km',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Return the selected route
                        Navigator.pop(context, _routes[_selectedRouteIndex]);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Select Route',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
