import 'package:flutter/material.dart';
import 'package:truck_app/core/constants/dummy_data.dart';
import 'package:truck_app/features/notification/screen/notification_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../connect/widgets/connect_card.dart';
import '../../search/screens/search_screen.dart';
import '../model/post.dart';
import '../widgets/post_card.dart';

class HomeScreenDriver extends StatefulWidget {
  const HomeScreenDriver({super.key});

  @override
  State<HomeScreenDriver> createState() => _HomeScreenDriverState();
}

class _HomeScreenDriverState extends State<HomeScreenDriver> {
  // Mock data for Latest Posts
  final List<Post> _latestPosts = [
    Post(
      id: '68ee48f0cfd19f82c673a512',
      title: 'Fresh Vegetables Delivery to Kochi',
      description: 'Transporting fresh vegetables from Pathanamthitta to Kochi via Kottayam.',
      date: DateTime.now().subtract(const Duration(hours: 1)),
      routeGeoJSON: RouteGeoJSON(
        type: 'LineString',
        coordinates: [
          [76.7704, 9.2645],
          [76.5212, 9.5916],
          [76.3516, 10.1076],
          [76.2875, 9.9674],
        ],
      ),
      distance: Distance(value: 135.5, text: '135.5 km'),
      duration: TripDuration(value: 150, text: '2 hours 30 mins'),
      currentLocation: TripLocation(coordinates: [76.7704, 9.2645]),
      tripAddedBy: User(id: '68e0156e2655da19d6948c7d', name: 'SDSDsd', phone: '1212121212', email: '1212@sdasd.com'),
      vehicleDetails: Vehicle(id: '68ee48c8cfd19f82c673a4da', vehicleNumber: 'KL12AB1212', vehicleType: 'Mini Truck', vehicleBodyType: 'Refrigerated'),
      driver: User(id: '68e0156e2655da19d6948c7d', name: 'SDSDsd', phone: '1212121212', email: '1212@sdasd.com'),
      selfDrive: true,
      goodsTypeDetails: GoodsType(id: '684aa733b88048daeaebff93', name: 'Food', description: 'Food products and consumables'),
      tripStartLocation: TripLocation(address: 'Pathanamthitta Bus Stand, Kerala', coordinates: [76.7704, 9.2645]),
      tripDestination: TripLocation(address: 'Kochi, Kerala', coordinates: [76.2875, 9.9674]),
      tripStartDate: DateTime.now().add(const Duration(hours: 3)),
      tripEndDate: DateTime.now().add(const Duration(hours: 6)),
      isStarted: false,
      isActive: true,
      imageUrl: 'https://via.placeholder.com/600x400.png?text=Vegetable+Delivery',
    ),
    Post(
      id: '68ee49b9cfd19f82c673a5ab',
      title: 'Bulk Construction Material Delivery to Palakkad',
      description: 'Delivering cement and steel rods from Thrissur to Palakkad.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      routeGeoJSON: RouteGeoJSON(
        type: 'LineString',
        coordinates: [
          [76.2133, 10.5276],
          [76.4650, 10.7740],
        ],
      ),
      distance: Distance(value: 90.0, text: '90 km'),
      duration: TripDuration(value: 120, text: '2 hours'),
      currentLocation: TripLocation(coordinates: [76.2133, 10.5276]),
      tripAddedBy: User(id: '68e0156e2655da19d6948c7f', name: 'BuildLogistics', phone: '7890123456', email: 'contact@buildlog.com'),
      vehicleDetails: Vehicle(id: '68ee48c8cfd19f82c673a4dc', vehicleNumber: 'KL09XY9999', vehicleType: 'Heavy Truck', vehicleBodyType: 'Open Body'),
      driver: User(id: '68e0156e2655da19d6948c80', name: 'Rajeev Menon', phone: '9988771122', email: 'rajeev@driver.com'),
      selfDrive: false,
      goodsTypeDetails: GoodsType(id: '684aa733b88048daeaebff95', name: 'Construction Materials', description: 'Cement, rods, and construction items'),
      tripStartLocation: TripLocation(address: 'Thrissur Industrial Estate', coordinates: [76.2133, 10.5276]),
      tripDestination: TripLocation(address: 'Palakkad Construction Site', coordinates: [76.4650, 10.7740]),
      tripStartDate: DateTime.now().add(const Duration(days: 1)),
      tripEndDate: DateTime.now().add(const Duration(days: 1, hours: 3)),
      isStarted: false,
      isActive: true,
      imageUrl: 'https://via.placeholder.com/600x400.png?text=Construction+Delivery',
    ),
  ];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildSearchBox(), const SizedBox(height: 24), _buildListOfPostsSection(), const SizedBox(height: 24), _buildConnectRequestsSection()],
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
            TextButton(
              onPressed: () {
                _showSnackBar('View All Requests tapped!');
              },
              child: Text('See All', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Display Connect Cards
        DummyData.driverConnections.isEmpty
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
                  DummyData.driverConnections
                      .map(
                        (connect) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ConnectCard(
                            connect: connect,
                            onAccept: (connect) {
                              _showSnackBar('Accepted connect from ${connect.replyUserName}');
                              // Implement actual accept logic
                            },
                            onReject: (connect) {
                              _showSnackBar('Rejected connect from ${connect.replyUserName}');
                              // Implement actual reject logic
                            },
                            onCall: (phoneNumber) => _makePhoneCall(phoneNumber),
                            onWhatsApp: (phoneNumber) => _launchWhatsApp(phoneNumber),
                          ),
                        ),
                      )
                      .toList(),
            ),
      ],
    );
  }

  Widget _buildLocationButton() {
    return GestureDetector(
      onTap: () {
        _showSnackBar('Location feature coming soon!');
        // TODO: Implement location picker
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, color: AppColors.textPrimary, size: 18),
            const SizedBox(width: 6),
            Text('Current location', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 18),
          ],
        ),
      ),
    );
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
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  // Simulate loading
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      _isLoading = false;
                    });
                    _showSnackBar('Refreshed successfully!');
                  });
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
