import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/model/connect.dart';
import '../../home/widgets/connect_card.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for Connect Cards
  final List<Connect> _allConnects = [
    Connect(
      id: 'c1',
      postName: 'Load Request #54321',
      replyUserName: 'Faheem',
      postTitle: 'FMCG delivery from Calicut to Trivandrum',
      dateTime: DateTime.now().subtract(const Duration(hours: 1)),
      status: ConnectStatus.pending,
    ),
    Connect(
      id: 'c2',
      postName: 'Vehicle Availability #90876',
      replyUserName: 'Anjali',
      postTitle: 'AC container for pharma supplies',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      status: ConnectStatus.accepted,
    ),
    Connect(
      id: 'c3',
      postName: 'Load Request #33445',
      replyUserName: 'Rahul',
      postTitle: 'Furniture shifting to Thrissur',
      dateTime: DateTime.now().subtract(const Duration(minutes: 30)),
      status: ConnectStatus.completed,
    ),
    Connect(
      id: 'c4',
      postName: 'Vehicle Availability #55667',
      replyUserName: 'Sneha',
      postTitle: 'Open truck available for bulk goods',
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      status: ConnectStatus.rejected,
    ),
    Connect(
      id: 'c5',
      postName: 'Load Request #99887',
      replyUserName: 'Manoj Kumar',
      postTitle: 'Urgent delivery to Hyderabad within 24h',
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      status: ConnectStatus.pending,
    ),
  ];

  // State to manage connects, allowing updates
  List<Connect> _connects = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _connects = List.from(_allConnects); // Initialize with all connects
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  void _handleAccept(Connect connect) {
    setState(() {
      final index = _connects.indexWhere((c) => c.id == connect.id);
      if (index != -1) {
        _connects[index] = connect.copyWith(status: ConnectStatus.accepted);
      }
    });
    _showSnackBar('Connect from ${connect.replyUserName} Accepted!');
  }

  void _handleReject(Connect connect) {
    setState(() {
      final index = _connects.indexWhere((c) => c.id == connect.id);
      if (index != -1) {
        _connects[index] = connect.copyWith(status: ConnectStatus.rejected);
      }
    });
    _showSnackBar('Connect from ${connect.replyUserName} Rejected!');
  }

  // Helper to filter connects based on tab
  List<Connect> _getFilteredConnects(ConnectStatus? filterStatus) {
    if (filterStatus == null) {
      return _connects; // All
    } else if (filterStatus == ConnectStatus.pending) {
      return _connects.where((c) => c.status == ConnectStatus.pending || c.status == ConnectStatus.rejected).toList();
    } else if (filterStatus == ConnectStatus.accepted) {
      return _connects.where((c) => c.status == ConnectStatus.accepted || c.status == ConnectStatus.completed).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Connects', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.secondary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'), // Includes rejected
            Tab(text: 'Accepted'), // Includes completed
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConnectList(null), // All connects
          _buildConnectList(ConnectStatus.pending), // Pending/Rejected
          _buildConnectList(ConnectStatus.accepted), // Accepted/Completed
        ],
      ),
    );
  }

  Widget _buildConnectList(ConnectStatus? filterStatus) {
    final filteredConnects = _getFilteredConnects(filterStatus);

    if (filteredConnects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No connects found in this category.', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredConnects.length,
      itemBuilder: (context, index) {
        final connect = filteredConnects[index];
        bool showActions = (connect.status == ConnectStatus.pending); // Only show actions for pending

        return ConnectCard(
          connect: connect,
          onAccept: _handleAccept,
          onReject: _handleReject,
          onCall: (phoneNumber) => _showSnackBar('Calling $phoneNumber'),
          // Mock action
          onWhatsApp: (phoneNumber) => _showSnackBar('WhatsApping $phoneNumber'),
          // Mock action
          showActions: showActions,
        );
      },
    );
  }
}
