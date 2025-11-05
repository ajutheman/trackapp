// lib/features/connect/screens/connect_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/connect/bloc/connect_request_bloc.dart';
import 'package:truck_app/features/connect/model/connect_request.dart';
import 'package:truck_app/features/connect/widgets/connect_request_card.dart';
import 'package:truck_app/features/connect/utils/connect_request_helper.dart';

class ConnectRequestsScreen extends StatefulWidget {
  const ConnectRequestsScreen({super.key});

  @override
  State<ConnectRequestsScreen> createState() => _ConnectRequestsScreenState();
}

class _ConnectRequestsScreenState extends State<ConnectRequestsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<ConnectRequest> _allRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Fetch connection requests on init
    ConnectRequestHelper.fetchRequests(
      context: context,
      page: 1,
      limit: 50,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleAccept(ConnectRequest request) {
    ConnectRequestHelper.respondToRequest(
      context: context,
      requestId: request.id!,
      action: 'accept',
    );
  }

  void _handleReject(ConnectRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reject Request?'),
          content: Text('Are you sure you want to reject the connection request from ${request.requester?.name ?? 'this user'}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ConnectRequestHelper.respondToRequest(
                  context: context,
                  requestId: request.id!,
                  action: 'reject',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _handleDelete(ConnectRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Request?'),
          content: const Text('Are you sure you want to delete this connection request? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ConnectRequestHelper.deleteRequest(
                  context: context,
                  requestId: request.id!,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _handleViewContacts(ConnectRequest request) {
    ConnectRequestHelper.fetchContactDetails(
      context: context,
      requestId: request.id!,
    );
  }

  List<ConnectRequest> _getFilteredRequests(ConnectRequestStatus? filterStatus) {
    if (filterStatus == null) {
      return _allRequests;
    }
    return _allRequests.where((r) => r.status == filterStatus).toList();
  }

  int _getTabCount(ConnectRequestStatus? filterStatus) {
    return _getFilteredRequests(filterStatus).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Connection Requests',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.refresh_rounded, color: AppColors.secondary, size: 20),
            ),
            onPressed: () {
              ConnectRequestHelper.refreshRequests(context: context);
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: AppColors.textSecondary,
              dividerHeight: 0,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorPadding: const EdgeInsets.all(2),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: [
                _buildTab('All', _getTabCount(null)),
                _buildTab('Pending', _getTabCount(ConnectRequestStatus.pending)),
                _buildTab('Accepted', _getTabCount(ConnectRequestStatus.accepted)),
                _buildTab('Rejected', _getTabCount(ConnectRequestStatus.rejected)),
              ],
            ),
          ),
        ),
      ),
      body: BlocListener<ConnectRequestBloc, ConnectRequestState>(
        listener: (context, state) {
          if (state is ConnectRequestsLoaded) {
            setState(() {
              _allRequests = state.requests;
              _isLoading = false;
            });
          } else if (state is ConnectRequestLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ConnectRequestSent) {
            _showSnackBar('Connection request sent successfully! 🎉');
            ConnectRequestHelper.refreshRequests(context: context);
          } else if (state is ConnectRequestResponded) {
            final action = state.action == 'accept' ? 'accepted' : 'rejected';
            _showSnackBar('Connection request $action successfully!', isSuccess: state.action == 'accept');
            ConnectRequestHelper.refreshRequests(context: context);
          } else if (state is ConnectRequestDeleted) {
            _showSnackBar('Connection request deleted successfully!');
            ConnectRequestHelper.refreshRequests(context: context);
          } else if (state is ContactDetailsLoaded) {
            _showContactDetailsDialog(state.contactDetails);
          } else if (state is ConnectRequestError) {
            setState(() {
              _isLoading = false;
            });
            _showSnackBar(state.message, isSuccess: false);
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildRequestsList(null),
            _buildRequestsList(ConnectRequestStatus.pending),
            _buildRequestsList(ConnectRequestStatus.accepted),
            _buildRequestsList(ConnectRequestStatus.rejected),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(ConnectRequestStatus? filterStatus) {
    if (_isLoading && _allRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading requests...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final filteredRequests = _getFilteredRequests(filterStatus);

    if (filteredRequests.isEmpty) {
      return _buildEmptyState(filterStatus);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ConnectRequestHelper.refreshRequests(context: context);
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: filteredRequests.length,
        itemBuilder: (context, index) {
          final request = filteredRequests[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutBack,
            transform: Matrix4.translationValues(0, 0, 0),
            child: ConnectRequestCard(
              request: request,
              onAccept: () => _handleAccept(request),
              onReject: () => _handleReject(request),
              onDelete: () => _handleDelete(request),
              onViewContacts: () => _handleViewContacts(request),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ConnectRequestStatus? filterStatus) {
    IconData icon;
    String title;
    String message;

    switch (filterStatus) {
      case ConnectRequestStatus.pending:
        icon = Icons.hourglass_empty_rounded;
        title = 'No Pending Requests';
        message = 'All connection requests have been\nhandled. Great job!';
        break;
      case ConnectRequestStatus.accepted:
        icon = Icons.celebration_rounded;
        title = 'No Accepted Requests';
        message = 'Accepted connections will appear here.\nStart connecting with others!';
        break;
      case ConnectRequestStatus.rejected:
        icon = Icons.block_rounded;
        title = 'No Rejected Requests';
        message = 'Rejected connection requests\nwill appear here.';
        break;
      default:
        icon = Icons.connect_without_contact_rounded;
        title = 'No Requests Yet';
        message = 'Your connection requests will appear here\nonce you start networking.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.textSecondary.withOpacity(0.1),
                  AppColors.textSecondary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showContactDetailsDialog(ContactDetails contactDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.2),
                        AppColors.secondary.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.contact_phone_rounded, size: 48, color: AppColors.secondary),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Contact Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                if (contactDetails.name != null) ...[
                  _buildContactInfoRow(Icons.person_rounded, 'Name', contactDetails.name!),
                  const SizedBox(height: 16),
                ],
                if (contactDetails.phone != null) ...[
                  _buildContactInfoRow(Icons.phone_rounded, 'Phone', contactDetails.phone!),
                  const SizedBox(height: 16),
                ],
                if (contactDetails.email != null) ...[
                  _buildContactInfoRow(Icons.email_rounded, 'Email', contactDetails.email!),
                  const SizedBox(height: 24),
                ],
                if (contactDetails.phone == null && contactDetails.email == null && contactDetails.name == null) ...[
                  Text(
                    'No contact details available',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

