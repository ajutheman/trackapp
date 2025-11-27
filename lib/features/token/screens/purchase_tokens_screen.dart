import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_display.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../bloc/token_bloc.dart';
import '../model/token.dart';
import '../widgets/token_plan_card.dart';
import '../widgets/token_balance_widget.dart';

class PurchaseTokensScreen extends StatefulWidget {
  const PurchaseTokensScreen({super.key});

  @override
  State<PurchaseTokensScreen> createState() => _PurchaseTokensScreenState();
}

class _PurchaseTokensScreenState extends State<PurchaseTokensScreen> {
  List<TokenPlan> _plans = [];
  bool _isLoading = false;
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    context.read<TokenBloc>().add(const FetchTokenPlans());
  }

  void _handlePurchase(String planId) {
    setState(() {
      _selectedPlanId = planId;
    });
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final plan = _plans.firstWhere((p) => p.id == planId);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shopping_cart_rounded, color: AppColors.secondary, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Confirm Purchase',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Purchase ${plan.tokensAmount} tokens for ${plan.getFormattedPrice()}?',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tokens will be credited to your wallet immediately after purchase.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TokenBloc>().add(PurchaseTokenPlan(planId: planId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        title: const Text(
          'Purchase Tokens',
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
      ),
      body: BlocListener<TokenBloc, TokenState>(
        listener: (context, state) {
          if (state is TokenPlansLoaded) {
            setState(() {
              _plans = state.plans;
              _isLoading = false;
            });
          } else if (state is TokenLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is TokenPurchaseSuccess) {
            setState(() {
              _selectedPlanId = null;
            });
            showSuccessSnackBar(
              context,
              'Successfully purchased ${state.tokensCredited} tokens! New balance: ${state.newBalance.toStringAsFixed(0)}',
            );
            // Refresh balance
            context.read<TokenBloc>().add(const FetchTokenBalance());
          } else if (state is TokenError) {
            setState(() {
              _selectedPlanId = null;
            });
            showErrorSnackBar(context, state.message);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Balance
              TokenBalanceWidget(showLabel: true, compact: false),
              const SizedBox(height: 24),
              
              // Header
              const Text(
                'Available Plans',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a plan that suits your needs',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Plans List
              if (_isLoading && _plans.isEmpty)
                ListSkeleton(
                  itemCount: 3,
                  itemBuilder: () => const TokenPlanCardSkeleton(),
                )
              else if (_plans.isEmpty)
                _buildEmptyState()
              else
                ..._plans.map((plan) => TokenPlanCard(
                      plan: plan,
                      onPurchase: () => _handlePurchase(plan.id!),
                      isLoading: _selectedPlanId == plan.id,
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
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
              Icons.shopping_bag_outlined,
              size: 60,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Plans Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Token purchase plans are currently unavailable.\nPlease check back later.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

