import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../connect/widgets/connect_card.dart';
import '../../search/screens/search_screen.dart';
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
  String _currentLocation = 'Current location';
  bool _isLoadingLocation = false;
  double? _currentLatitude; // Can be used for filtering posts by location
  double? _currentLongitude; // Can be used for filtering posts by location

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Fetch customer requests (posts) for drivers
    context.read<CustomerRequestBloc>().add(const FetchAllCustomerRequests(page: 1, limit: 20));
    // Fetch connect requests for drivers
    context.read<ConnectRequestBloc>().add(const FetchConnectRequests(page: 1, limit: 10));
  }

  Future<void> _refreshAllData() async {
    _loadInitialData();
    // Wait a bit for data to load
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Handle location selection from dropdown
  void _handleLocationSelection(String location, double? latitude, double? longitude) {
    setState(() {
      _currentLocation = location;
      _currentLatitude = latitude;
      _currentLongitude = longitude;
      _isLoadingLocation = false;
    });

    // You can use the coordinates for filtering posts or other purposes
    debugPrint('Selected location: $location ($latitude, $longitude)');
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
                children: [_buildSearchBox(), const SizedBox(height: 24), _buildListOfPostsSection(), const SizedBox(height: 24), _buildConnectRequestsSection()],
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
            // Notification Icon with badge
            _buildLocationButton(),
          ],
        ),
      ),
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
            Text('Connect Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
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

  Widget _buildLocationButton() {
    return LocationDropdown(currentLocation: _currentLocation, isLoading: _isLoadingLocation, onLocationSelected: _handleLocationSelection);
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

  // Search Box Widget
  Widget _buildSearchBox() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, AppColors.surface.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.secondary.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -2),
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
          border: Border.all(color: AppColors.secondary.withOpacity(0.08), width: 1),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary.withOpacity(0.15), AppColors.secondary.withOpacity(0.08)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.search_rounded, color: AppColors.secondary, size: 22),
            ),
            Expanded(child: Text('Search trips, locations, or goods...', style: TextStyle(color: AppColors.textHint, fontSize: 15, fontWeight: FontWeight.w400))),
          ],
        ),
      ),
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
