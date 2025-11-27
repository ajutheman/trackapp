// lib/features/token/screens/wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/core/widgets/loading_skeletons.dart';
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
  List<TokenTransaction> _filteredTransactions = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedType; // 'credit' or 'debit'
  DateTime? _dateFrom;
  DateTime? _dateTo;

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

  void _applyFilters() {
    _filteredTransactions = _transactions.where((txn) {
      // Type filter
      if (_selectedType != null && txn.type != _selectedType) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesReason = txn.reason?.toLowerCase().contains(query) ?? false;
        final matchesReference = txn.reference?.toLowerCase().contains(query) ?? false;
        if (!matchesReason && !matchesReference) {
          return false;
        }
      }
      
      // Date range filter
      if (_dateFrom != null && txn.createdAt != null) {
        if (txn.createdAt!.isBefore(_dateFrom!)) {
          return false;
        }
      }
      if (_dateTo != null && txn.createdAt != null) {
        final endOfDay = DateTime(_dateTo!.year, _dateTo!.month, _dateTo!.day, 23, 59, 59);
        if (txn.createdAt!.isAfter(endOfDay)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  Map<String, dynamic> _calculateStatistics() {
    double totalCredits = 0;
    double totalDebits = 0;
    
    for (var txn in _filteredTransactions) {
      if (txn.type == 'credit') {
        totalCredits += txn.amount;
      } else {
        totalDebits += txn.amount;
      }
    }
    
    return {
      'totalCredits': totalCredits,
      'totalDebits': totalDebits,
      'net': totalCredits - totalDebits,
      'count': _filteredTransactions.length,
    };
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
              _applyFilters();
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
                
                // Statistics
                _buildStatistics(),
                const SizedBox(height: 24),
                
                // Transactions Header with Filters
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
                    IconButton(
                      icon: Icon(Icons.filter_list_rounded, color: AppColors.secondary),
                      onPressed: _showFilterDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Search Bar
                _buildSearchBar(),
                const SizedBox(height: 16),
                
                // Transactions List
                if (_isLoading && _transactions.isEmpty)
                  ListSkeleton(
                    itemCount: 5,
                    itemBuilder: () => const TransactionCardSkeleton(),
                  )
                else if (_filteredTransactions.isEmpty)
                  _buildEmptyState()
                else
                  ..._filteredTransactions.map((txn) => _buildTransactionCard(txn)).toList(),
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
            _transactions.isEmpty
                ? 'Your token transactions will appear here'
                : 'No transactions match your filters',
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

  Widget _buildStatistics() {
    final stats = _calculateStatistics();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Credits',
              stats['totalCredits'].toStringAsFixed(0),
              AppColors.success,
              Icons.trending_up_rounded,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.border.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem(
              'Debits',
              stats['totalDebits'].toStringAsFixed(0),
              AppColors.error,
              Icons.trending_down_rounded,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.border.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem(
              'Net',
              stats['net'].toStringAsFixed(0),
              stats['net'] >= 0 ? AppColors.success : AppColors.error,
              Icons.account_balance_wallet_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applyFilters();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Filter Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Filter
                    const Text(
                      'Transaction Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip(
                          'All',
                          _selectedType == null,
                          () {
                            setDialogState(() {
                              _selectedType = null;
                            });
                          },
                        ),
                        _buildFilterChip(
                          'Credits',
                          _selectedType == 'credit',
                          () {
                            setDialogState(() {
                              _selectedType = 'credit';
                            });
                          },
                        ),
                        _buildFilterChip(
                          'Debits',
                          _selectedType == 'debit',
                          () {
                            setDialogState(() {
                              _selectedType = 'debit';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Date Range
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateFrom ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  _dateFrom = date;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              _dateFrom != null
                                  ? DateFormat('dd MMM yyyy').format(_dateFrom!)
                                  : 'From',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateTo ?? DateTime.now(),
                                firstDate: _dateFrom ?? DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  _dateTo = date;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              _dateTo != null
                                  ? DateFormat('dd MMM yyyy').format(_dateTo!)
                                  : 'To',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_dateFrom != null || _dateTo != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            _dateFrom = null;
                            _dateTo = null;
                          });
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear dates'),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = null;
                      _dateFrom = null;
                      _dateTo = null;
                      _applyFilters();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _applyFilters();
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
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
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.secondary.withOpacity(0.2),
      checkmarkColor: AppColors.secondary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.secondary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

