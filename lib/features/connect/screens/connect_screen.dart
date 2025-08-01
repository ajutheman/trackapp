import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/model/connect.dart';
import '../widgets/connect_card.dart';

class ConnectScreen extends StatefulWidget {
  final List<Connect> connections;

  ConnectScreen({super.key, required this.connections});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // State to manage connects, allowing updates
  List<Connect> _connects = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _connects = List.from(widget.connections);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [Icon(isSuccess ? Icons.check_circle : Icons.error, color: Colors.white, size: 20), const SizedBox(width: 8), Expanded(child: Text(message))]),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleAccept(Connect connect) {
    setState(() {
      final index = _connects.indexWhere((c) => c.id == connect.id);
      if (index != -1) {
        _connects[index] = connect.copyWith(status: ConnectStatus.accepted);
      }
    });
    _showSnackBar('Connection from ${connect.replyUserName} accepted! 🎉');
  }

  void _handleReject(Connect connect) {
    setState(() {
      final index = _connects.indexWhere((c) => c.id == connect.id);
      if (index != -1) {
        _connects[index] = connect.copyWith(status: ConnectStatus.rejected);
      }
    });
    _showSnackBar('Connection from ${connect.replyUserName} rejected', isSuccess: false);
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

  int _getTabCount(ConnectStatus? filterStatus) {
    return _getFilteredConnects(filterStatus).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Connections', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: AppColors.textSecondary,
              indicator: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              indicatorPadding: const EdgeInsets.all(2),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('All'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text('${_getTabCount(null)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pending'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text('${_getTabCount(ConnectStatus.pending)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Accepted'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text('${_getTabCount(ConnectStatus.accepted)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.textSecondary.withOpacity(0.1), AppColors.textSecondary.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(_getEmptyStateIcon(filterStatus), size: 60, color: AppColors.textSecondary.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            Text(_getEmptyStateTitle(filterStatus), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(_getEmptyStateMessage(filterStatus), style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: filteredConnects.length,
      itemBuilder: (context, index) {
        final connect = filteredConnects[index];
        bool showActions = (connect.status == ConnectStatus.pending);

        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(0, 0, 0),
          child: ConnectCard(
            connect: connect,
            onAccept: _handleAccept,
            onReject: _handleReject,
            onCall: (phoneNumber) => _showSnackBar('Calling $phoneNumber 📞'),
            onWhatsApp: (phoneNumber) => _showSnackBar('Opening WhatsApp chat 💬'),
            showActions: showActions,
          ),
        );
      },
    );
  }

  IconData _getEmptyStateIcon(ConnectStatus? filterStatus) {
    switch (filterStatus) {
      case ConnectStatus.pending:
        return Icons.hourglass_empty_rounded;
      case ConnectStatus.accepted:
        return Icons.celebration_rounded;
      default:
        return Icons.connect_without_contact_rounded;
    }
  }

  String _getEmptyStateTitle(ConnectStatus? filterStatus) {
    switch (filterStatus) {
      case ConnectStatus.pending:
        return 'No Pending Connections';
      case ConnectStatus.accepted:
        return 'No Accepted Connections';
      default:
        return 'No Connections Yet';
    }
  }

  String _getEmptyStateMessage(ConnectStatus? filterStatus) {
    switch (filterStatus) {
      case ConnectStatus.pending:
        return 'All connection requests have been\nhandled. Great job!';
      case ConnectStatus.accepted:
        return 'No accepted connections yet.\nStart connecting with others!';
      default:
        return 'Your connections will appear here\nonce you start networking.';
    }
  }
}
