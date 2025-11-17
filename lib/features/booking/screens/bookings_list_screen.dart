// lib/features/booking/screens/bookings_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/booking/bloc/booking_bloc.dart';
import 'package:truck_app/features/booking/model/booking.dart';
import 'package:truck_app/features/booking/screens/booking_detail_screen.dart';
import 'package:truck_app/features/booking/widgets/booking_card.dart';

class BookingsListScreen extends StatefulWidget {
  final String? status;
  final String? type; // 'driver' or 'customer'

  const BookingsListScreen({
    super.key,
    this.status,
    this.type,
  });

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _allBookings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    context.read<BookingBloc>().add(FetchBookings(
      status: widget.status,
      type: widget.type,
      page: 1,
      limit: 50,
    ));
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

  List<Booking> _getFilteredBookings(BookingStatus? filterStatus) {
    if (filterStatus == null) {
      return _allBookings;
    }
    return _allBookings.where((b) => b.status == filterStatus).toList();
  }

  int _getTabCount(BookingStatus? filterStatus) {
    return _getFilteredBookings(filterStatus).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
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
              context.read<BookingBloc>().add(RefreshBookings(status: widget.status));
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
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              isScrollable: true,
              tabs: [
                _buildTab('All', _getTabCount(null)),
                _buildTab('Pending', _getTabCount(BookingStatus.pending)),
                _buildTab('Confirmed', _getTabCount(BookingStatus.confirmed)),
                _buildTab('Active', _getTabCount(BookingStatus.pickedUp)),
                _buildTab('Completed', _getTabCount(BookingStatus.completed)),
              ],
            ),
          ),
        ),
      ),
      body: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingsLoaded) {
            setState(() {
              _allBookings = state.bookings;
              _isLoading = false;
            });
          } else if (state is BookingLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is BookingCreated) {
            _showSnackBar('Booking created successfully! 🎉');
            context.read<BookingBloc>().add(RefreshBookings());
          } else if (state is BookingAccepted) {
            _showSnackBar('Booking accepted successfully!');
            context.read<BookingBloc>().add(RefreshBookings());
          } else if (state is BookingRejected) {
            _showSnackBar('Booking rejected', isSuccess: false);
            context.read<BookingBloc>().add(RefreshBookings());
          } else if (state is BookingCancelled) {
            _showSnackBar('Booking cancelled');
            context.read<BookingBloc>().add(RefreshBookings());
          } else if (state is BookingError) {
            setState(() {
              _isLoading = false;
            });
            _showSnackBar(state.message, isSuccess: false);
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBookingsList(null),
            _buildBookingsList(BookingStatus.pending),
            _buildBookingsList(BookingStatus.confirmed),
            _buildBookingsList(BookingStatus.pickedUp),
            _buildBookingsList(BookingStatus.completed),
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

  Widget _buildBookingsList(BookingStatus? filterStatus) {
    if (_isLoading && _allBookings.isEmpty) {
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
              'Loading bookings...',
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

    final filteredBookings = _getFilteredBookings(filterStatus);

    if (filteredBookings.isEmpty) {
      return _buildEmptyState(filterStatus);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookingBloc>().add(RefreshBookings(status: widget.status));
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingDetailScreen(bookingId: booking.id!),
                ),
              );
            },
            child: BookingCard(booking: booking),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BookingStatus? filterStatus) {
    IconData icon;
    String title;
    String message;

    switch (filterStatus) {
      case BookingStatus.pending:
        icon = Icons.hourglass_empty_rounded;
        title = 'No Pending Bookings';
        message = 'All pending bookings have been\nhandled. Great job!';
        break;
      case BookingStatus.confirmed:
        icon = Icons.check_circle_outline_rounded;
        title = 'No Confirmed Bookings';
        message = 'Confirmed bookings will appear here.\nStart booking trips!';
        break;
      case BookingStatus.pickedUp:
        icon = Icons.local_shipping_rounded;
        title = 'No Active Bookings';
        message = 'Active bookings will appear here\nonce pickup is confirmed.';
        break;
      case BookingStatus.completed:
        icon = Icons.celebration_rounded;
        title = 'No Completed Bookings';
        message = 'Completed bookings will appear here.\nKeep up the great work!';
        break;
      default:
        icon = Icons.book_online_rounded;
        title = 'No Bookings Yet';
        message = 'Your bookings will appear here\nonce you start booking trips.';
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
}

