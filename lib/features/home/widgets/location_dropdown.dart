import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/location/location_service.dart';
import 'package:geocoding/geocoding.dart';

class LocationDropdown extends StatefulWidget {
  final String currentLocation;
  final bool isLoading;
  final Function(String location, double? latitude, double? longitude) onLocationSelected;

  const LocationDropdown({
    super.key,
    required this.currentLocation,
    required this.isLoading,
    required this.onLocationSelected,
  });

  @override
  State<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<LocationDropdown> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _buttonKey = GlobalKey();
  
  OverlayEntry? _overlayEntry;
  List<Location> _searchResults = [];
  bool _isSearching = false;
  bool _isFetchingCurrentLocation = false;

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleDropdown() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    // Get button size and position
    final RenderBox? renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width.clamp(280.0, 400.0), // Min 280, max 400
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: _buildDropdownContent(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildDropdownContent() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchLocation(value);
              },
              decoration: InputDecoration(
                hintText: 'Search location...',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: AppColors.secondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _searchLocation('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          
          const Divider(height: 1),
          
          // Location options
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                // Current Location option
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.15),
                          AppColors.secondary.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.my_location, color: AppColors.secondary, size: 18),
                  ),
                  title: Text(
                    'Use Current Location',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: _isFetchingCurrentLocation
                      ? const Text(
                          'Fetching location...',
                          style: TextStyle(fontSize: 11),
                        )
                      : null,
                  trailing: _isFetchingCurrentLocation
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          ),
                        )
                      : Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.secondary),
                  onTap: _isFetchingCurrentLocation ? null : _getCurrentLocation,
                ),
                
                if (_searchController.text.isNotEmpty) ...[
                  const Divider(height: 1),
                  
                  // Search results or loading
                  if (_isSearching)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Searching...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_searchResults.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              color: AppColors.textSecondary,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No locations found',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Try different keywords',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._searchResults.map((location) {
                      return FutureBuilder<String>(
                        future: _getAddressFromLocation(location),
                        builder: (context, snapshot) {
                          String displayText = snapshot.data ?? 'Loading...';
                          
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.location_on_outlined,
                                color: AppColors.secondary,
                                size: 16,
                              ),
                            ),
                            title: Text(
                              displayText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () {
                              widget.onLocationSelected(
                                displayText,
                                location.latitude,
                                location.longitude,
                              );
                              _removeOverlay();
                            },
                          );
                        },
                      );
                    }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      _overlayEntry?.markNeedsBuild();
      return;
    }

    setState(() {
      _isSearching = true;
    });
    _overlayEntry?.markNeedsBuild();

    try {
      List<Location> locations = await locationFromAddress(query);
      
      setState(() {
        _searchResults = locations.take(5).toList();
        _isSearching = false;
      });
      _overlayEntry?.markNeedsBuild();
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      _overlayEntry?.markNeedsBuild();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingCurrentLocation = true;
    });
    _overlayEntry?.markNeedsBuild();

    try {
      final locationData = await _locationService.getCurrentLocationWithAddress();
      widget.onLocationSelected(
        locationData['address'],
        locationData['latitude'],
        locationData['longitude'],
      );
      _removeOverlay();
    } catch (e) {
      setState(() {
        _isFetchingCurrentLocation = false;
      });
      _overlayEntry?.markNeedsBuild();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<String> _getAddressFromLocation(Location location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        
        return addressParts.isNotEmpty ? addressParts.join(', ') : 'Unknown Location';
      }
    } catch (e) {
      return 'Location (${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)})';
    }
    return 'Unknown Location';
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _buttonKey,
        onTap: widget.isLoading ? null : _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      ),
                    )
                  : Icon(Icons.location_on_outlined, color: AppColors.textPrimary, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.currentLocation,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _overlayEntry != null ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
