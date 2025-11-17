import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../di/locator.dart';
import '../../../services/local/local_services.dart';
import '../../profile/repo/profile_repo.dart';
import '../model/connect_request.dart';
import '../bloc/connect_request_bloc.dart';
import '../utils/connect_request_helper.dart';
import '../widgets/connect_request_card.dart';
import '../../booking/widgets/create_booking_dialog.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // State for API data
  List<ConnectRequest> _receivedRequests = [];
  List<ConnectRequest> _sentRequests = [];
  bool _isLoading = false;
  String? _currentUserId;
  bool _isDriver = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentUserAndFetch();
  }

  Future<void> _loadCurrentUserAndFetch() async {
    // Fetch current user profile to get user ID
    try {
      final profileRepo = locator<ProfileRepository>();
      final result = await profileRepo.getProfile();
      if (result.isSuccess && result.data != null) {
        setState(() {
          _currentUserId = result.data!.id;
        });
      }
    } catch (e) {
      // Continue even if profile fetch fails
    }

    // Load driver status
    try {
      final isDriver = await LocalService.getIsDriver();
      setState(() {
        _isDriver = isDriver ?? false;
      });
    } catch (e) {
      // Continue even if driver status fetch fails
    }

    // Fetch all requests (for "All" tab), received, and sent requests
    ConnectRequestHelper.fetchRequests(
      context: context,
      page: 1,
      limit: 50,
    );
    ConnectRequestHelper.fetchRequests(
      context: context,
      type: 'received',
      page: 1,
      limit: 50,
    );
    ConnectRequestHelper.fetchRequests(
      context: context,
      type: 'sent',
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
        content: Row(children: [Icon(isSuccess ? Icons.check_circle : Icons.error, color: Colors.white, size: 20), const SizedBox(width: 8), Expanded(child: Text(message))]),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleAcceptRequest(ConnectRequest request) {
    ConnectRequestHelper.respondToRequest(
      context: context,
      requestId: request.id!,
      action: 'accept',
    );
  }

  void _handleRejectRequest(ConnectRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reject Request?'),
          content: Text(
            'Are you sure you want to reject the connection request from ${request.requester?.name ?? 'this user'}?',
          ),
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

  void _handleDeleteRequest(ConnectRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Request?'),
          content: const Text(
            'Are you sure you want to delete this connection request? This action cannot be undone.',
          ),
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

  void _handleCreateBooking(ConnectRequest request) {
    if (request.tripId == null || request.customerRequestId == null || request.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing required information to create booking'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CreateBookingDialog(connectRequest: request);
      },
    ).then((created) {
      if (created == true) {
        // Refresh requests after booking creation
        _refreshAllTabs();
      }
    });
  }

  void _handleViewContacts(ConnectRequest request) {
    ConnectRequestHelper.fetchContactDetails(
      context: context,
      requestId: request.id!,
    );
  }

  void _refreshAllTabs() {
    ConnectRequestHelper.fetchRequests(
      context: context,
      page: 1,
      limit: 50,
    );
    ConnectRequestHelper.fetchRequests(
      context: context,
      type: 'received',
      page: 1,
      limit: 50,
    );
    ConnectRequestHelper.fetchRequests(
      context: context,
      type: 'sent',
      page: 1,
      limit: 50,
    );
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
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Icon(Icons.refresh_rounded, color: AppColors.secondary, size: 20),
            ),
            onPressed: () {
              _refreshAllTabs();
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: AppColors.textSecondary,
              dividerHeight: 0,
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
                        child: Text('${_receivedRequests.length + _sentRequests.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Received'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text('${_receivedRequests.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sent'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text('${_sentRequests.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocListener<ConnectRequestBloc, ConnectRequestState>(
        listener: (context, state) {
          if (state is ConnectRequestsLoaded) {
            setState(() {
              // Use the type from state to determine which list to update
              if (state.type == 'sent') {
                _sentRequests = state.requests;
              } else if (state.type == 'received') {
                _receivedRequests = state.requests;
              } else {
                // No type means "all" - split into received and sent
                if (state.requests.isNotEmpty && _currentUserId != null) {
                  final received = <ConnectRequest>[];
                  final sent = <ConnectRequest>[];
                  
                  for (var request in state.requests) {
                    if (request.requesterId == _currentUserId) {
                      sent.add(request);
                    } else {
                      received.add(request);
                    }
                  }
                  
                  _sentRequests = sent;
                  _receivedRequests = received;
                }
              }
              
              _isLoading = false;
            });
          } else if (state is ConnectRequestLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ConnectRequestResponded) {
            final action = state.action == 'accept' ? 'accepted' : 'rejected';
            _showSnackBar('Connection request $action!', isSuccess: state.action == 'accept');
            _refreshAllTabs();
          } else if (state is ConnectRequestDeleted) {
            _showSnackBar('Connection request deleted successfully!');
            _refreshAllTabs();
          } else if (state is ContactDetailsLoaded) {
            _showContactDetailsDialog(state.contactDetails);
            // Refresh requests to update status if it changed from hold to accepted
            _refreshAllTabs();
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
            _buildRequestsList(tabType: 'all'), // All requests
            _buildRequestsList(tabType: 'received'), // Received requests
            _buildRequestsList(tabType: 'sent'), // Sent requests
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList({required String tabType}) {
    final List<ConnectRequest> requests;
    
    if (tabType == 'all') {
      requests = [..._receivedRequests, ..._sentRequests];
    } else if (tabType == 'received') {
      requests = _receivedRequests;
    } else {
      requests = _sentRequests;
    }
    
    if (_isLoading && requests.isEmpty) {
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
              'Loading connections...',
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

    if (requests.isEmpty) {
      return _buildEmptyState(tabType);
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (tabType == 'all') {
          ConnectRequestHelper.fetchRequests(context: context, page: 1, limit: 50);
        } else if (tabType == 'received') {
          ConnectRequestHelper.fetchRequests(context: context, type: 'received', page: 1, limit: 50);
        } else {
          ConnectRequestHelper.fetchRequests(context: context, type: 'sent', page: 1, limit: 50);
        }
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          // Determine if request is sent by comparing requesterId with currentUserId
          final isSent = _currentUserId != null && request.requesterId == _currentUserId;
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutBack,
            transform: Matrix4.translationValues(0, 0, 0),
            child: ConnectRequestCard(
              request: request,
              isSent: isSent,
              currentUserId: _currentUserId,
              isDriver: _isDriver,
              onAccept: isSent ? null : () => _handleAcceptRequest(request),
              onReject: isSent ? null : () => _handleRejectRequest(request),
              onDelete: () => _handleDeleteRequest(request),
              onViewContacts: () => _handleViewContacts(request),
              onCreateBooking: request.status == ConnectRequestStatus.accepted
                  ? () => _handleCreateBooking(request)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String tabType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.textSecondary.withOpacity(0.1), AppColors.textSecondary.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(_getEmptyStateIcon(tabType), size: 60, color: AppColors.textSecondary.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),
          Text(_getEmptyStateTitle(tabType), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(_getEmptyStateMessage(tabType), style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  IconData _getEmptyStateIcon(String tabType) {
    switch (tabType) {
      case 'received':
        return Icons.inbox_rounded;
      case 'sent':
        return Icons.send_rounded;
      default:
        return Icons.connect_without_contact_rounded;
    }
  }

  String _getEmptyStateTitle(String tabType) {
    switch (tabType) {
      case 'received':
        return 'No Received Requests';
      case 'sent':
        return 'No Sent Requests';
      default:
        return 'No Connections Yet';
    }
  }

  String _getEmptyStateMessage(String tabType) {
    switch (tabType) {
      case 'received':
        return 'Connection requests sent to you will\nappear here.';
      case 'sent':
        return 'Requests you send will appear here.\nStart connecting with others!';
      default:
        return 'Your connections will appear here\nonce you start networking.';
    }
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
