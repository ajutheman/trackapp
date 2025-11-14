import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../connect/widgets/connect_card.dart';
import '../../post/bloc/customer_request_bloc.dart';
import '../model/post.dart';
import '../model/connect.dart';
import '../widgets/post_card.dart';
import '../widgets/location_dropdown.dart';
import '../../connect/bloc/connect_request_bloc.dart';
import '../../connect/model/connect_request.dart';

class HomeScreenDriver extends StatefulWidget {
  const HomeScreenDriver({super.key});

  @override
  State<HomeScreenDriver> createState() => _HomeScreenDriverState();
}

class _HomeScreenDriverState extends State<HomeScreenDriver> {
  List<Post> _latestPosts = [];
  List<ConnectRequest> _connectRequests = [];
  bool _isLoading = false;
  bool _isLoadingConnections = false;
  String? _errorMessage;

  // Location related state
  String _fromLocation = 'Current location';
  String _toLocation = 'Search trips, locations, or goods...';
  bool _isLoadingLocation = false;
  double? _fromLatitude; // From location (current location)
  double? _fromLongitude;
  double? _toLatitude; // To location (destination)
  double? _toLongitude;
  
  // Inline search state for "To" location only
  final TextEditingController _toSearchController = TextEditingController();
  final FocusNode _toFocusNode = FocusNode();
  List<Map<String, dynamic>> _toSearchResults = [];
  bool _isToSearching = false;
  bool _isSettingSelectedLocation = false; // Flag to prevent search when setting selected location

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _toSearchController.addListener(() {
      if (!_isSettingSelectedLocation) {
        _searchToLocation(_toSearchController.text);
      }
    });
    _toFocusNode.addListener(() {
      if (!_toFocusNode.hasFocus && _toSearchController.text.isEmpty) {
        setState(() {
          _toSearchResults = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _toSearchController.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    // Fetch customer requests (posts) for drivers with location filters
    _fetchPostsWithFilters();
    // Fetch connect requests for drivers
    context.read<ConnectRequestBloc>().add(const FetchConnectRequests(page: 1, limit: 10));
  }

  void _fetchPostsWithFilters() {
    // Build location strings for API (format: "lng,lat")
    String? startLocation;
    String? destination;
    
    if (_fromLatitude != null && _fromLongitude != null) {
      startLocation = '$_fromLongitude,$_fromLatitude';
    }
    if (_toLatitude != null && _toLongitude != null) {
      destination = '$_toLongitude,$_toLatitude';
    }
    
    context.read<CustomerRequestBloc>().add(
      FetchAllCustomerRequests(
        page: 1,
        limit: 20,
        startLocation: startLocation,
        destination: destination,
      ),
    );
  }

  Future<void> _refreshAllData() async {
    _loadInitialData();
    // Wait a bit for data to load
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Handle from location selection (from dropdown button)
  void _handleFromLocationSelection(String location, double? latitude, double? longitude) {
    setState(() {
      _fromLocation = location;
      _fromLatitude = latitude;
      _fromLongitude = longitude;
      _isLoadingLocation = false;
    });

    // Refresh posts with new from location filter
    _fetchPostsWithFilters();
    debugPrint('Selected from location: $location ($latitude, $longitude)');
  }

  /// Handle to location selection (search bar)
  void _handleToLocationSelection(String location, double? latitude, double? longitude) {
    // Set flag to prevent listener from triggering search
    _isSettingSelectedLocation = true;
    
    setState(() {
      _toLocation = location;
      _toLatitude = latitude;
      _toLongitude = longitude;
      _toSearchController.text = location;
      _toSearchResults = []; // Hide results after selection
      _isToSearching = false;
      _toFocusNode.unfocus();
    });

    // Reset flag after a short delay to allow setState to complete
    Future.microtask(() {
      _isSettingSelectedLocation = false;
    });

    // Refresh posts with new to location filter
    _fetchPostsWithFilters();
    debugPrint('Selected to location: $location ($latitude, $longitude)');
  }

  /// Search to location
  Future<void> _searchToLocation(String query) async {
    if (query.isEmpty || query.length < 2) {
      setState(() {
        _toSearchResults = [];
        _isToSearching = false;
      });
      return;
    }

    setState(() {
      _isToSearching = true;
    });

    try {
      final locations = await locationFromAddress(query);
      final results = <Map<String, dynamic>>[];
      
      for (var location in locations.take(5)) {
        try {
          final placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
          if (placemarks.isNotEmpty) {
            final place = placemarks[0];
            final addressParts = <String>[];
            if (place.locality != null && place.locality!.isNotEmpty) {
              addressParts.add(place.locality!);
            }
            if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
              addressParts.add(place.administrativeArea!);
            }
            final address = addressParts.isNotEmpty ? addressParts.join(', ') : query;
            results.add({
              'address': address,
              'latitude': location.latitude,
              'longitude': location.longitude,
            });
          }
        } catch (e) {
          // Skip this location if address lookup fails
        }
      }

      if (mounted) {
        setState(() {
          _toSearchResults = results;
          _isToSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _toSearchResults = [];
          _isToSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocListener<ConnectRequestBloc, ConnectRequestState>(
        listener: (context, state) {
          if (state is ConnectRequestsLoaded) {
            setState(() {
              _connectRequests = state.requests;
              _isLoadingConnections = false;
            });
          } else if (state is ConnectRequestLoading) {
            setState(() {
              _isLoadingConnections = true;
            });
          } else if (state is ConnectRequestError) {
            setState(() {
              _isLoadingConnections = false;
            });
            // Show error message
            if (!state.message.toLowerCase().contains('no connect')) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          } else if (state is ConnectRequestResponded) {
            // Update the specific request in the list
            setState(() {
              final index = _connectRequests.indexWhere((req) => req.id == state.request.id);
              if (index != -1) {
                _connectRequests[index] = state.request;
              }
              _isLoadingConnections = false;
            });

            // Show success message
            final actionText = state.action == 'accept' ? 'Accepted' : 'Rejected';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connect request $actionText successfully'), backgroundColor: AppColors.success));

            // Refresh the list after a short delay to get updated data
            Future.delayed(const Duration(milliseconds: 500), () {
              context.read<ConnectRequestBloc>().add(const FetchConnectRequests(page: 1, limit: 10));
            });
          }
        },
        child: BlocListener<CustomerRequestBloc, CustomerRequestState>(
          listenWhen: (previous, current) {
            return current is CustomerRequestsLoaded || current is CustomerRequestLoading || current is CustomerRequestError;
          },
          listener: (context, state) {
            if (state is CustomerRequestsLoaded) {
              setState(() {
                _latestPosts = state.requests;
                _isLoading = false;
                _errorMessage = null;
              });
            } else if (state is CustomerRequestLoading) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            } else if (state is CustomerRequestError) {
              setState(() {
                _isLoading = false;
                _errorMessage = state.message;
              });
            }
          },
          child: RefreshIndicator(
            onRefresh: _refreshAllData,
            color: AppColors.secondary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationSelectorSection(),
                  const SizedBox(height: 24),
                  _buildListOfPostsSection(),
                  const SizedBox(height: 24),
                  _buildConnectRequestsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white, Colors.white.withOpacity(0.95)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App Logo with animation
            Hero(tag: 'app_logo', child: SizedBox(height: 35, child: Image.asset(AppImages.appIconWithName))),
            // From Location Button (Current Location)
            _buildLocationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return LocationDropdown(
      currentLocation: _fromLocation,
      isLoading: _isLoadingLocation,
      onLocationSelected: _handleFromLocationSelection,
    );
  }

  Widget _buildConnectRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.people_rounded, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Leads', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
            const Spacer(),
            if (_connectRequests.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/connect-requests');
                },
                child: Text('See All', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  context.read<ConnectRequestBloc>().add(const FetchConnectRequests(page: 1, limit: 10));
                },
                icon: Icon(Icons.refresh_rounded, color: AppColors.secondary, size: 22),
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Display Connect Cards
        _isLoadingConnections
            ? Center(
              child: Padding(padding: const EdgeInsets.all(40.0), child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary), strokeWidth: 3)),
            )
            : _connectRequests.isEmpty
            ? Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border.withOpacity(0.2))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined, color: AppColors.textSecondary, size: 32),
                    const SizedBox(height: 8),
                    Text('No connect requests yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
            )
            : Column(
              children:
                  _connectRequests.map((request) {
                    final connect = _convertConnectRequestToConnect(request);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ConnectCard(
                        connect: connect,
                        onAccept: (connect) {
                          _handleAcceptConnect(request);
                        },
                        onReject: (connect) {
                          _handleRejectConnect(request);
                        },
                        onCall: (phoneNumber) => _makePhoneCall(phoneNumber),
                        onWhatsApp: (phoneNumber) => _launchWhatsApp(phoneNumber),
                      ),
                    );
                  }).toList(),
            ),
      ],
    );
  }

  // Helper method to convert ConnectRequest to Connect model for display
  Connect _convertConnectRequestToConnect(ConnectRequest request) {
    final String userName = request.requester?.name ?? request.recipient?.name ?? 'Unknown';

    String postTitle = request.message ?? '';
    if (request.trip != null) {
      postTitle = request.trip!.title ?? 'Trip to ${request.trip!.destination ?? "Unknown"}';
    } else if (request.customerRequest != null) {
      postTitle = request.customerRequest!.details ?? 'Customer Request';
    }

    return Connect(
      id: request.id ?? '',
      postName: request.tripId != null ? 'Trip Request' : 'Customer Request',
      replyUserName: userName,
      postTitle: postTitle,
      dateTime: request.createdAt ?? DateTime.now(),
      status: _mapConnectRequestStatus(request.status),
      isUser: false, // Driver view
    );
  }

  ConnectStatus _mapConnectRequestStatus(ConnectRequestStatus status) {
    switch (status) {
      case ConnectRequestStatus.accepted:
        return ConnectStatus.accepted;
      case ConnectRequestStatus.rejected:
        return ConnectStatus.rejected;
      case ConnectRequestStatus.cancelled:
        return ConnectStatus.rejected;
      case ConnectRequestStatus.hold:
        return ConnectStatus.hold;
      case ConnectRequestStatus.pending:
      default:
        return ConnectStatus.pending;
    }
  }

  void _handleAcceptConnect(ConnectRequest request) {
    if (request.id != null) {
      context.read<ConnectRequestBloc>().add(RespondToConnectRequest(requestId: request.id!, action: 'accept'));
      _showSnackBar('Accepted connect from ${request.requester?.name ?? "user"}');
    }
  }

  void _handleRejectConnect(ConnectRequest request) {
    if (request.id != null) {
      context.read<ConnectRequestBloc>().add(RespondToConnectRequest(requestId: request.id!, action: 'reject'));
      _showSnackBar('Rejected connect from ${request.requester?.name ?? "user"}');
    }
  }

  Widget _buildListOfPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.local_shipping_rounded, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Latest Posts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  context.read<CustomerRequestBloc>().add(const FetchAllCustomerRequests(page: 1, limit: 20));
                },
                icon: Icon(Icons.refresh_rounded, color: AppColors.secondary, size: 22),
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary), strokeWidth: 3),
                  const SizedBox(height: 16),
                  Text('Loading posts...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          )
        else if (_errorMessage != null)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.withOpacity(0.2))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text('Oops! Something went wrong', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(_errorMessage!, style: TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _isLoading = true;
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          _isLoading = false;
                        });
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_latestPosts.isEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.surface, AppColors.surface.withOpacity(0.5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.15), AppColors.secondary.withOpacity(0.05)]),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.inbox_outlined, color: AppColors.secondary, size: 56),
                  ),
                  const SizedBox(height: 20),
                  Text('No Posts Available', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Check back later for new posts', style: TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          _isLoading = false;
                        });
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    label: const Text('Refresh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _latestPosts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AnimatedOpacity(opacity: 1.0, duration: Duration(milliseconds: 300 + (index * 50)), child: PostCard(post: _latestPosts[index])),
              );
            },
          ),
      ],
    );
  }

  // Location Selector Section - Only "To" location with inline search
  Widget _buildLocationSelectorSection() {
    final bool hasToLocation = _toLocation != 'Search trips, locations, or goods...';
    final Color orangeColor = Colors.orange;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // To Location with inline search
        Row(
          children: [
            Expanded(
              child: _buildLocationSearchField(
                controller: _toSearchController,
                focusNode: _toFocusNode,
                hintText: 'Type to search destination...',
                icon: Icons.search_outlined,
                color: orangeColor,
                results: _toSearchResults,
                isSearching: _isToSearching,
                onLocationSelected: _handleToLocationSelection,
              ),
            ),
            if (hasToLocation) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _toLocation = 'Search trips, locations, or goods...';
                    _toLatitude = null;
                    _toLongitude = null;
                    _toSearchController.clear();
                  });
                  _fetchPostsWithFilters();
                },
                icon: Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 20),
                tooltip: 'Clear destination',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.border.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSearchField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> results,
    required bool isSearching,
    required Function(String, double, double) onLocationSelected,
  }) {
    final hasLocation = controller.text.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasLocation
                  ? [color.withOpacity(0.1), color.withOpacity(0.05)]
                  : [Colors.white, AppColors.surface.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 15),
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 12,left: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              suffixIcon: isSearching
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    )
                  : controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 20),
                          onPressed: () {
                            controller.clear();
                            setState(() {
                              _toLocation = 'Search trips, locations, or goods...';
                              _toLatitude = null;
                              _toLongitude = null;
                            });
                            _fetchPostsWithFilters();
                          },
                        )
                      : null,
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: TextStyle(
              color: hasLocation ? AppColors.textPrimary : AppColors.textHint,
              fontSize: 15,
              fontWeight: hasLocation ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
        // Search Results List
        if (results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: results.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.border.withOpacity(0.2)),
              itemBuilder: (context, index) {
                final result = results[index];
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.location_on_rounded, color: color, size: 20),
                  ),
                  title: Text(
                    result['address'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                  onTap: () {
                    onLocationSelected(
                      result['address'],
                      result['latitude'],
                      result['longitude'],
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1)));
  }

  // Function to launch phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnackBar('Could not launch $phoneNumber');
    }
  }

  // Function to launch WhatsApp chat
  Future<void> _launchWhatsApp(String phoneNumber) async {
    // WhatsApp URL scheme for Android and iOS
    final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      _showSnackBar('WhatsApp is not installed or could not launch $phoneNumber');
    }
  }
}
