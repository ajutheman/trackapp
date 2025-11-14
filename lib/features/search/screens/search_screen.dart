import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/home/bloc/posts_bloc.dart';
import 'package:truck_app/features/home/model/post.dart';
import 'package:truck_app/features/home/widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _fromLocation;
  String? _toLocation;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _sampleLocations = [
    'Kochi',
    'Thrissur',
    'Thiruvananthapuram',
    'Kozhikode',
    'Malappuram',
    'Kannur',
    'Palakkad',
    'Alappuzha',
    'Kottayam',
    'Idukki',
    'Ernakulam',
    'Bengaluru',
    'Chennai',
    'Hyderabad',
    'Mumbai',
  ];

  @override
  void initState() {
    _searchTrips();
    super.initState();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: Text('Search Trips', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      body: BlocListener<PostsBloc, PostsState>(
        listener: (context, state) {
          if (state is PostsLoaded) {
            setState(() {
              _posts = state.posts;
              _isLoading = false;
              _errorMessage = null;
            });
          } else if (state is PostsLoading) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          } else if (state is PostsError) {
            setState(() {
              _isLoading = false;
              _errorMessage = state.message;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: Column(
          children: [
            // Search Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // From Location
                  _buildLocationRow(
                    label: 'From',
                    value: _fromLocation,
                    icon: Icons.my_location_rounded,
                    iconColor: Colors.green.shade600,
                    onTap: () => _openLocationInput(isFrom: true),
                  ),

                  // Swap Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border.withOpacity(0.3), thickness: 1)),
                        if (_fromLocation != null || _toLocation != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: InkWell(
                              onTap: _swapLocations,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.15), AppColors.secondary.withOpacity(0.08)]),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                                ),
                                child: Icon(Icons.swap_vert_rounded, color: AppColors.secondary, size: 20),
                              ),
                            ),
                          )
                        else
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.arrow_downward_rounded, color: AppColors.textHint, size: 16)),
                        Expanded(child: Divider(color: AppColors.border.withOpacity(0.3), thickness: 1)),
                      ],
                    ),
                  ),

                  // To Location
                  _buildLocationRow(
                    label: 'To',
                    value: _toLocation,
                    icon: Icons.location_on_rounded,
                    iconColor: Colors.red.shade600,
                    onTap: () => _openLocationInput(isFrom: false),
                  ),

                  const SizedBox(height: 16),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _searchTrips,
                      icon: const Icon(Icons.search_rounded, color: Colors.white),
                      label: const Text('Search Trips', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Results Section
            Expanded(child: _buildResultsSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow({required String label, required String? value, required IconData icon, required Color iconColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (value != null && value.isNotEmpty) ? iconColor.withOpacity(0.03) : AppColors.background.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: (value != null && value.isNotEmpty) ? iconColor.withOpacity(0.2) : AppColors.border.withOpacity(0.2), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [iconColor.withOpacity(0.15), iconColor.withOpacity(0.08)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: iconColor.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(
                    value == null || value.isEmpty ? 'Select ${label.toLowerCase()} location' : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: (value != null && value.isNotEmpty) ? AppColors.textPrimary : AppColors.textHint, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.secondary, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLocationInput({required bool isFrom}) async {
    final controller = isFrom ? _fromController : _toController;
    controller.text = isFrom ? (_fromLocation ?? '') : (_toLocation ?? '');
    final iconColor = isFrom ? Colors.green.shade600 : Colors.red.shade600;
    final icon = isFrom ? Icons.my_location_rounded : Icons.location_on_rounded;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            List<String> filtered =
                _sampleLocations.where((e) => controller.text.trim().isEmpty ? true : e.toLowerCase().contains(controller.text.trim().toLowerCase())).take(12).toList();

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.white, AppColors.surface.withOpacity(0.95)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.secondary.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10), spreadRadius: -5),
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [iconColor.withOpacity(0.1), iconColor.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [iconColor.withOpacity(0.2), iconColor.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: iconColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Icon(icon, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFrom ? 'Pickup Location' : 'Drop Location',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 4),
                                Text('Search or select a location', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.background.withOpacity(0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Field
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: iconColor.withOpacity(0.2), width: 2),
                          boxShadow: [BoxShadow(color: iconColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setLocalState(() {}),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              Navigator.pop(context, value.trim());
                            }
                          },
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Type a place, area or city...',
                            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 15, fontWeight: FontWeight.w400),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [iconColor.withOpacity(0.15), iconColor.withOpacity(0.08)]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.search_rounded, color: iconColor, size: 20),
                            ),
                            suffixIcon:
                                controller.text.isNotEmpty
                                    ? IconButton(
                                      icon: Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 20),
                                      onPressed: () {
                                        controller.clear();
                                        setLocalState(() {});
                                      },
                                    )
                                    : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                    ),

                    // Suggestions List
                    if (filtered.isNotEmpty)
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(color: AppColors.background.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_city_rounded, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Text('SUGGESTED LOCATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2)),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 280),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(bottom: 8),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final item = filtered[index];
                                      return InkWell(
                                        onTap: () => Navigator.pop(context, item),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.border.withOpacity(0.1)),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(colors: [iconColor.withOpacity(0.15), iconColor.withOpacity(0.05)]),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(Icons.place_rounded, color: iconColor, size: 18),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  item,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                                ),
                                              ),
                                              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (controller.text.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text('No locations found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: AppColors.background.withOpacity(0.5),
                              ),
                              child: Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                final text = controller.text.trim();
                                if (text.isNotEmpty) {
                                  Navigator.pop(context, text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: iconColor,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                shadowColor: iconColor.withOpacity(0.4),
                              ),
                              child: const Text('Confirm', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        if (isFrom) {
          _fromLocation = result;
        } else {
          _toLocation = result;
        }
      });
    }
  }

  void _swapLocations() {
    if ((_fromLocation ?? '').isEmpty && (_toLocation ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing to swap'), duration: Duration(seconds: 1)));
      return;
    }
    setState(() {
      final temp = _fromLocation;
      _fromLocation = _toLocation;
      _toLocation = temp;
    });
  }

  void _searchTrips() {
    // Fetch posts with location filters
    context.read<PostsBloc>().add(FetchAllPosts(
      pickupLocation: _fromLocation,
      dropoffLocation: _toLocation,
      page: 1,
      limit: 20,
    ));
  }

  Widget _buildResultsSection() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary), strokeWidth: 3),
            const SizedBox(height: 16),
            Text('Searching trips...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.withOpacity(0.2))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              ),
              const SizedBox(height: 16),
              Text('Oops! Something went wrong', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(_errorMessage!, style: TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _searchTrips,
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
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
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
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.15), AppColors.secondary.withOpacity(0.05)]), shape: BoxShape.circle),
                child: Icon(Icons.search_off_rounded, color: AppColors.secondary, size: 56),
              ),
              const SizedBox(height: 20),
              Text('No Trips Found', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Try searching with different locations', style: TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: AnimatedOpacity(opacity: 1.0, duration: Duration(milliseconds: 300 + (index * 50)), child: PostCard(post: _posts[index])),
        );
      },
    );
  }
}
