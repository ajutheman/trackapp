import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/location/location_service.dart';
import '../widgets/location_dropdown.dart';

class LocationFilterDialog extends StatefulWidget {
  final String? currentPickupLocation;
  final String? currentDropoffLocation;
  final bool? currentPickupDropoffBoth;

  const LocationFilterDialog({
    super.key,
    this.currentPickupLocation,
    this.currentDropoffLocation,
    this.currentPickupDropoffBoth,
  });

  @override
  State<LocationFilterDialog> createState() => _LocationFilterDialogState();
}

class _LocationFilterDialogState extends State<LocationFilterDialog> {
  final LocationService _locationService = LocationService();
  
  String? _pickupLocation;
  double? _pickupLatitude;
  double? _pickupLongitude;
  
  String? _dropoffLocation;
  double? _dropoffLatitude;
  double? _dropoffLongitude;
  
  String? _currentLocation;
  double? _currentLatitude;
  double? _currentLongitude;
  
  bool _pickupDropoffBoth = false;
  bool _useCurrentLocation = false;
  bool _isLoadingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _pickupLocation = widget.currentPickupLocation;
    _dropoffLocation = widget.currentDropoffLocation;
    _pickupDropoffBoth = widget.currentPickupDropoffBoth ?? false;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      final locationData = await _locationService.getCurrentLocationWithAddress();
      setState(() {
        _currentLocation = locationData['address'];
        _currentLatitude = locationData['latitude'];
        _currentLongitude = locationData['longitude'];
        _useCurrentLocation = true;
        _isLoadingCurrentLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCurrentLocation = false;
      });
      
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

  void _clearFilters() {
    setState(() {
      _pickupLocation = null;
      _pickupLatitude = null;
      _pickupLongitude = null;
      _dropoffLocation = null;
      _dropoffLatitude = null;
      _dropoffLongitude = null;
      _currentLocation = null;
      _currentLatitude = null;
      _currentLongitude = null;
      _pickupDropoffBoth = false;
      _useCurrentLocation = false;
    });
  }

  /// Formats location coordinates for API (verified: server expects "longitude,latitude" format)
  /// This format is used for geospatial queries with 5km search radius
  /// Edge cases handled: null coordinates return null, invalid coordinates are filtered by server
  String? _formatLocationForApi(double? lat, double? lng) {
    // Validate coordinates exist before formatting
    if (lat != null && lng != null) {
      // Format: "longitude,latitude" (lng,lat) as per server requirements
      // Edge case: Server will validate coordinate ranges, client just formats correctly
      return '$lng,$lat';
    }
    // Edge case: Return null if coordinates are missing (no filter applied)
    return null;
  }

  void _applyFilters() {
    // Format locations as "longitude,latitude" for API
    // Verified: All location parameters use this format for geospatial queries
    String? pickupLocationParam = _formatLocationForApi(_pickupLatitude, _pickupLongitude);
    String? dropoffLocationParam = _formatLocationForApi(_dropoffLatitude, _dropoffLongitude);
    String? currentLocationParam = _useCurrentLocation 
        ? _formatLocationForApi(_currentLatitude, _currentLongitude)
        : null;
    
    // pickupDropoffBoth: When true, requires BOTH pickup and dropoff locations to match
    // Verified: Server uses AND logic when this flag is set
    bool? pickupDropoffBothParam = (_pickupLocation != null && _dropoffLocation != null && _pickupDropoffBoth) 
        ? true 
        : null;

    Navigator.of(context).pop({
      'pickupLocation': pickupLocationParam,
      'dropoffLocation': dropoffLocationParam,
      'currentLocation': currentLocationParam,
      'pickupDropoffBoth': pickupDropoffBothParam,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.filter_list_rounded, color: AppColors.secondary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Filter by Location',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Current Location Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.my_location_rounded, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use Current Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_currentLocation != null)
                          Text(
                            _currentLocation!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (_isLoadingCurrentLocation)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Switch(
                      value: _useCurrentLocation,
                      onChanged: (value) {
                        if (value && _currentLocation == null) {
                          _getCurrentLocation();
                        } else {
                          setState(() {
                            _useCurrentLocation = value;
                          });
                        }
                      },
                      activeColor: AppColors.secondary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Pickup Location
            Text(
              'Pickup Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            LocationDropdown(
              currentLocation: _pickupLocation ?? 'Select pickup location',
              isLoading: false,
              onLocationSelected: (location, latitude, longitude) {
                setState(() {
                  _pickupLocation = location;
                  _pickupLatitude = latitude;
                  _pickupLongitude = longitude;
                });
              },
            ),
            const SizedBox(height: 20),
            
            // Dropoff Location
            Text(
              'Dropoff Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            LocationDropdown(
              currentLocation: _dropoffLocation ?? 'Select dropoff location',
              isLoading: false,
              onLocationSelected: (location, latitude, longitude) {
                setState(() {
                  _dropoffLocation = location;
                  _dropoffLatitude = latitude;
                  _dropoffLongitude = longitude;
                });
              },
            ),
            const SizedBox(height: 20),
            
            // Pickup + Dropoff Both Option
            if (_pickupLocation != null && _dropoffLocation != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz_rounded, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Require both pickup and dropoff locations',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Switch(
                      value: _pickupDropoffBoth,
                      onChanged: (value) {
                        setState(() {
                          _pickupDropoffBoth = value;
                        });
                      },
                      activeColor: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppColors.border),
                    ),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.85)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}














