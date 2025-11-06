// lib/features/connect/screens/my_friends_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/driver_connection_bloc.dart';
import '../model/driver_connection.dart';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({super.key});

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  // Data variables - assigned in listener when success
  List<DriverFriend> _friends = [];
  List<DriverConnection> _receivedRequests = [];
  List<DriverConnection> _sentRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch data on init
    context.read<DriverConnectionBloc>().add(const FetchFriendsList());
    context.read<DriverConnectionBloc>().add(const FetchFriendRequests(type: 'received'));
    context.read<DriverConnectionBloc>().add(const FetchFriendRequests(type: 'sent'));
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

  void _showSendRequestDialog() {
    final TextEditingController phoneController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)]),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_add_rounded, size: 32, color: AppColors.secondary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Send Friend Request', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            SizedBox(height: 4),
                            Text('Enter driver phone number', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+1234567890',
                      prefixIcon: Icon(Icons.phone_rounded, color: AppColors.secondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.secondary, width: 2)),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      if (!RegExp(r'^\+?[1-9]\d{7,14}$').hasMatch(value)) {
                        return 'Invalid phone number format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: AppColors.border),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.of(dialogContext).pop();
                              context.read<DriverConnectionBloc>().add(SendFriendRequest(mobileNumber: phoneController.text.trim()));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Send Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleAccept(DriverConnection connection) {
    context.read<DriverConnectionBloc>().add(RespondToFriendRequest(connectionId: connection.id!, action: 'accept'));
  }

  void _handleReject(DriverConnection connection) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reject Request?'),
          content: Text('Are you sure you want to reject the friend request from ${connection.requester?.name ?? 'this driver'}?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<DriverConnectionBloc>().add(RespondToFriendRequest(connectionId: connection.id!, action: 'reject'));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _handleRemoveFriend(DriverFriend friend) {
    if (friend.connectionId == null) {
      _showSnackBar('Cannot remove self-drive option', isSuccess: false);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Remove Friend?'),
          content: Text('Are you sure you want to remove ${friend.name} from your friends list?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<DriverConnectionBloc>().add(RemoveFriend(connectionId: friend.connectionId!));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Remove', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Friends', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
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
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Icon(Icons.add_rounded, color: AppColors.secondary, size: 20),
            ),
            onPressed: _showSendRequestDialog,
            tooltip: 'Send Friend Request',
          ),
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
              // Refresh all lists
              context.read<DriverConnectionBloc>().add(const FetchFriendsList());
              context.read<DriverConnectionBloc>().add(const FetchFriendRequests(type: 'received'));
              context.read<DriverConnectionBloc>().add(const FetchFriendRequests(type: 'sent'));
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
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [Tab(text: 'Friends'), Tab(text: 'Received'), Tab(text: 'Sent')],
            ),
          ),
        ),
      ),
      body: BlocConsumer<DriverConnectionBloc, DriverConnectionState>(
        listener: (context, state) {
          if (state is FriendsListLoaded) {
            setState(() {
              _friends = state.friends;
            });
          } else if (state is FriendRequestsLoaded) {
            setState(() {
              if (state.type == 'received') {
                _receivedRequests = state.requests;
              } else if (state.type == 'sent') {
                _sentRequests = state.requests;
              }
            });
          } else if (state is FriendRequestSent) {
            _showSnackBar('Friend request sent successfully! 🎉');
            context.read<DriverConnectionBloc>().add(const FetchFriendsList());
            context.read<DriverConnectionBloc>().add(const FetchFriendRequests(type: 'received'));
            context.read<DriverConnectionBloc>().add(const FetchFriendRequests(type: 'sent'));
          } else if (state is FriendRequestResponded) {
            final action = state.action == 'accept' ? 'accepted' : 'rejected';
            _showSnackBar('Friend request $action successfully!', isSuccess: state.action == 'accept');
            context.read<DriverConnectionBloc>().add(const FetchFriendsList());
            context.read<DriverConnectionBloc>().add(const FetchFriendRequests(type: 'received'));
            context.read<DriverConnectionBloc>().add(const FetchFriendRequests(type: 'sent'));
          } else if (state is FriendRemoved) {
            _showSnackBar('Friend removed successfully!');
            context.read<DriverConnectionBloc>().add(const FetchFriendsList());
          } else if (state is DriverConnectionError) {
            _showSnackBar(state.message, isSuccess: false);
          }
        },
        builder: (context, state) {
          return TabBarView(controller: _tabController, children: [_buildFriendsList(state), _buildRequestsList(state, 'received'), _buildRequestsList(state, 'sent')]);
        },
      ),
    );
  }

  Widget _buildFriendsList(DriverConnectionState state) {
    final isLoading = state is DriverConnectionLoading;

    if (isLoading && _friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary), strokeWidth: 3),
            const SizedBox(height: 16),
            Text('Loading friends...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    if (_friends.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<DriverConnectionBloc>().add(const FetchFriendsList());
          await Future.delayed(const Duration(seconds: 1));
        },
        color: AppColors.secondary,
        child: _buildEmptyState(icon: Icons.people_outline_rounded, title: 'No Friends Yet', message: 'Start connecting with other drivers\nby sending friend requests!'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DriverConnectionBloc>().add(const FetchFriendsList());
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return _buildFriendCard(friend);
        },
      ),
    );
  }

  Widget _buildRequestsList(DriverConnectionState state, String type) {
    final isLoading = state is DriverConnectionLoading;
    final requests = type == 'received' ? _receivedRequests : _sentRequests;

    if (isLoading && requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary), strokeWidth: 3),
            const SizedBox(height: 16),
            Text('Loading requests...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<DriverConnectionBloc>().add(FetchFriendRequests(type: type));
          await Future.delayed(const Duration(seconds: 1));
        },
        color: AppColors.secondary,
        child: _buildEmptyState(
          icon: type == 'received' ? Icons.inbox_outlined : Icons.send_outlined,
          title: type == 'received' ? 'No Received Requests' : 'No Sent Requests',
          message: type == 'received' ? 'Friend requests you receive will\nappear here.' : 'Friend requests you send will\nappear here.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DriverConnectionBloc>().add(FetchFriendRequests(type: type));
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request, type);
        },
      ),
    );
  }

  Widget _buildFriendCard(DriverFriend friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: friend.isSelfDrive == true ? AppColors.secondary.withOpacity(0.2) : AppColors.background,
          child: Icon(Icons.person_rounded, color: friend.isSelfDrive == true ? AppColors.secondary : AppColors.textSecondary, size: 28),
        ),
        title: Text(friend.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: friend.isSelfDrive == true ? AppColors.secondary : AppColors.textPrimary)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(friend.phone, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            if (friend.connectedSince != null)
              Text('Connected ${DateFormat('MMM dd, yyyy').format(friend.connectedSince!)}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        trailing:
            friend.isSelfDrive == true
                ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('SELF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                )
                : IconButton(icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary), onPressed: () => _showFriendOptionsDialog(friend)),
      ),
    );
  }

  Widget _buildRequestCard(DriverConnection request, String type) {
    final isReceived = type == 'received';
    final friend = isReceived ? request.requester : request.requested;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: request.status == DriverConnectionStatus.pending ? AppColors.secondary.withOpacity(0.3) : AppColors.border.withOpacity(0.3),
          width: request.status == DriverConnectionStatus.pending ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(radius: 28, backgroundColor: AppColors.secondary.withOpacity(0.1), child: Icon(Icons.person_rounded, color: AppColors.secondary, size: 28)),
        title: Text(friend?.name ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(friend?.phone ?? '', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            if (request.requestedAt != null)
              Text('Requested ${DateFormat('MMM dd, yyyy').format(request.requestedAt!)}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        trailing:
            isReceived && request.status == DriverConnectionStatus.pending
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.check_rounded, color: AppColors.success, size: 20),
                      ),
                      onPressed: () => _handleAccept(request),
                      tooltip: 'Accept',
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                      ),
                      onPressed: () => _handleReject(request),
                      tooltip: 'Reject',
                    ),
                  ],
                )
                : request.status == DriverConnectionStatus.pending
                ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('PENDING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning)),
                )
                : request.status == DriverConnectionStatus.rejected
                ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('REJECTED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.error)),
                )
                : null,
      ),
    );
  }

  void _showFriendOptionsDialog(DriverFriend friend) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.phone_rounded, color: AppColors.secondary),
                  title: const Text('Call'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    // Implement call functionality
                  },
                ),
                ListTile(
                  leading: Icon(Icons.chat_rounded, color: AppColors.secondary),
                  title: const Text('Message'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    // Implement message functionality
                  },
                ),
                if (friend.connectionId != null)
                  ListTile(
                    leading: Icon(Icons.person_remove_rounded, color: AppColors.error),
                    title: Text('Remove Friend', style: TextStyle(color: AppColors.error)),
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      _handleRemoveFriend(friend);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String message}) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200, // Ensure enough height for centering
        child: Center(
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
                child: Icon(icon, size: 60, color: AppColors.textSecondary.withOpacity(0.6)),
              ),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(message, style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
