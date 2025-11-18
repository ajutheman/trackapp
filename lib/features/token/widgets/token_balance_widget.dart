// lib/features/token/widgets/token_balance_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/token/bloc/token_bloc.dart';
import 'package:truck_app/features/token/screens/token_screen.dart';

class TokenBalanceWidget extends StatefulWidget {
  final bool showLabel;
  final bool compact;
  final VoidCallback? onTap;

  const TokenBalanceWidget({
    super.key,
    this.showLabel = true,
    this.compact = false,
    this.onTap,
  });

  @override
  State<TokenBalanceWidget> createState() => _TokenBalanceWidgetState();
}

class _TokenBalanceWidgetState extends State<TokenBalanceWidget> {
  double? _cachedBalance;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TokenBloc, TokenState>(
      buildWhen: (previous, current) {
        // Rebuild when balance is loaded or error occurs
        // Don't rebuild when transactions are loading (preserve cached balance)
        return current is TokenBalanceLoaded ||
            (current is TokenError && previous is! TokenBalanceLoaded) ||
            (current is TokenLoading && _cachedBalance == null);
      },
      builder: (context, state) {
        if (state is TokenBalanceLoaded) {
          _cachedBalance = state.wallet.balance;
          return _buildBalanceDisplay(context, state.wallet.balance);
        } else if (state is TokenError && _cachedBalance == null) {
          return _buildErrorDisplay(context);
        } else if (_cachedBalance != null) {
          // Show cached balance when transactions are loading
          return _buildBalanceDisplay(context, _cachedBalance!);
        } else {
          return _buildLoadingDisplay(context);
        }
      },
    );
  }

  Widget _buildBalanceDisplay(BuildContext context, double balance) {
    if (widget.compact) {
      final balanceContainer = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withOpacity(0.15),
              AppColors.secondary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 16,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              balance.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      );
      
      if (widget.onTap != null) {
        return GestureDetector(
          onTap: widget.onTap ?? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TokenScreen())),
          child: balanceContainer,
        );
      }
      return balanceContainer;
    }

    final balanceContainer = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.2),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 24,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showLabel)
                  Text(
                    'Token Balance',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (widget.showLabel) const SizedBox(height: 4),
                Text(
                  balance.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'tokens',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<TokenBloc>().add(RefreshTokenBalance());
            },
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
    
    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: balanceContainer,
      );
    }
    return balanceContainer;
  }

  Widget _buildLoadingDisplay(BuildContext context) {
    if (widget.compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorDisplay(BuildContext context) {
    if (widget.compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Icon(
          Icons.error_outline_rounded,
          size: 16,
          color: AppColors.error,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load balance',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

