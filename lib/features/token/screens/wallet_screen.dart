// lib/features/token/screens/wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/token/bloc/token_bloc.dart';
import 'package:truck_app/features/token/model/token.dart';
import 'package:truck_app/features/token/widgets/token_balance_widget.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<TokenTransaction> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check current state and only fetch if needed
    final currentState = context.read<TokenBloc>().state;
    
    // Only fetch balance if not already loaded
    if (currentState is! TokenBalanceLoaded) {
      context.read<TokenBloc>().add(FetchTokenBalance());
    }
    
    // Only fetch transactions if not already loaded
    if (currentState is TokenTransactionsLoaded) {
      // Use existing transactions
      setState(() {
        _transactions = currentState.transactions;
        _isLoading = false;
      });
    } else {
      context.read<TokenBloc>().add(const FetchTokenTransactions(page: 1, limit: 50));
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Token Wallet',
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
              context.read<TokenBloc>().add(RefreshTokenBalance());
              context.read<TokenBloc>().add(const FetchTokenTransactions(page: 1, limit: 50));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<TokenBloc, TokenState>(
        listenWhen: (previous, current) {
          // Only listen to transaction-related states, not balance loading
          return current is TokenTransactionsLoaded ||
              (current is TokenLoading && previous is! TokenBalanceLoaded) ||
              current is TokenError;
        },
        listener: (context, state) {
          if (state is TokenTransactionsLoaded) {
            setState(() {
              _transactions = state.transactions;
              _isLoading = false;
            });
          } else if (state is TokenLoading) {
            // Only set loading if we don't have transactions yet
            if (_transactions.isEmpty) {
              setState(() {
                _isLoading = true;
              });
            }
          } else if (state is TokenError) {
            setState(() {
              _isLoading = false;
            });
            _showSnackBar(state.message, isSuccess: false);
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TokenBloc>().add(RefreshTokenBalance());
            context.read<TokenBloc>().add(const FetchTokenTransactions(page: 1, limit: 50));
            await Future.delayed(const Duration(seconds: 1));
          },
          color: AppColors.secondary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Widget
                TokenBalanceWidget(showLabel: true, compact: false),
                const SizedBox(height: 24),
                // Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_transactions.isNotEmpty)
                      Text(
                        '${_transactions.length} transactions',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Transactions List
                if (_isLoading && _transactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      ),
                    ),
                  )
                else if (_transactions.isEmpty)
                  _buildEmptyState()
                else
                  ..._transactions.map((txn) => _buildTransactionCard(txn)).toList(),
              ],
            ),
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
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your token transactions will appear here',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TokenTransaction txn) {
    final isCredit = txn.type == 'credit';
    final color = isCredit ? AppColors.success : AppColors.error;
    final icon = isCredit ? Icons.add_circle_rounded : Icons.remove_circle_rounded;
    final sign = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.reason ?? (isCredit ? 'Token Credit' : 'Token Debit'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (txn.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy • HH:mm').format(txn.createdAt!),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${txn.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'tokens',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

