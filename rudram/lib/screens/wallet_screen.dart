import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/wallet_provider.dart';
import '../providers/auth_provider.dart';
import '../models/wallet_transaction_model.dart';
import 'wallet/add_money_screen.dart';
import 'wallet/send_to_bank_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Consumer<WalletProvider>(
          builder: (context, wallet, child) {
            if (wallet.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return AnimationLimiter(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildBalanceCard(context, wallet),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                      const SizedBox(height: 32),
                      _buildSectionTitle(context, "My Portfolio", actionText: "See All"),
                      const SizedBox(height: 16),
                      _buildPortfolioList(context, wallet),
                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        context,
                        "Recent Transactions",
                        actionText: "See All",
                      ),
                      const SizedBox(height: 16),
                      _buildTransactionList(context, wallet),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                auth.photoUrl ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(auth.displayName)}&background=F37A20&color=fff&size=200',
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Gold Member",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: Colors.red.shade300,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletProvider wallet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Wallet Balance",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Row(
                children: [
                  Text(
                    "INR",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "₹ ${wallet.walletBalance.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "+3.74%",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "This week",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddMoneyScreen()),
                  );
                },
                icon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  "Top Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            "Add Money",
            Icons.add_circle_outline,
            Colors.green.shade50,
            Colors.green,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMoneyScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            "Send to Bank",
            Icons.account_balance_outlined,
            Colors.blue.shade50,
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SendToBankScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {String? actionText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (actionText != null)
          Text(
            actionText,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildPortfolioList(BuildContext context, WalletProvider wallet) {
    return SizedBox(
      height: 180,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildAssetCard(
            context,
            "Cashback",
            "💰",
            "₹ ${wallet.cashbackBalance.toStringAsFixed(2)}",
            "Available",
            AppColors.primaryOrange,
            Colors.orange.shade50,
          ),
          const SizedBox(width: 16),
          _buildAssetCard(
            context,
            "Reward Points",
            "⭐",
            "${wallet.rewardPoints} pts",
            "≈ ₹${(wallet.rewardPoints / 10).toStringAsFixed(0)}",
            const Color(0xFFFFD700),
            Colors.amber.shade50,
          ),
          const SizedBox(width: 16),
          _buildAssetCard(
            context,
            "Gift Vouchers",
            "🎁",
            "${wallet.activeGiftVouchers} Active",
            "Check validity",
            const Color(0xFF6C63FF),
            Colors.purple.shade50,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(
    BuildContext context,
    String name,
    String symbol,
    String value,
    String statusText,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(
              child: Text(symbol, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            statusText,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, WalletProvider wallet) {
    if (wallet.transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Center(
          child: Text(
            "No recent transactions",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }
    
    return Column(
      children: wallet.transactions.map((tx) {
        String sign = tx.type == TransactionType.credit ? "+" : "-";
        IconData iconData;
        Color color;
        
        switch (tx.category) {
          case TransactionCategory.order:
            iconData = Icons.shopping_bag_outlined;
            color = AppColors.primaryOrange;
            break;
          case TransactionCategory.cashback:
            iconData = Icons.card_giftcard_outlined;
            color = Colors.green;
            break;
          case TransactionCategory.refund:
            iconData = Icons.refresh_outlined;
            color = Colors.blue;
            break;
          case TransactionCategory.topup:
            iconData = Icons.account_balance_wallet_outlined;
            color = Colors.purple;
            break;
          case TransactionCategory.reward:
            iconData = Icons.star_border;
            color = Colors.amber;
            break;
        }

        final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        String formattedDate = "${tx.date.day} ${months[tx.date.month - 1]} ${tx.date.year}";

        return _buildTransactionItem(
          context,
          tx.title,
          formattedDate,
          "$sign ₹ ${tx.amount.toStringAsFixed(2)}",
          iconData,
          color,
        );
      }).toList(),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    String title,
    String date,
    String amount,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: amount.startsWith('+') ? Colors.green : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
