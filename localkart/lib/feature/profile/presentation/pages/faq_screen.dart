import 'package:flutter/material.dart';
import 'package:localkart/app/theme/app_colors.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Frequently Asked Questions"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.help_outline_rounded,
                    size: 50,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "How can we help?",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Find answers to the most commonly asked questions.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Search
            TextField(
              decoration: InputDecoration(
                hintText: "Search FAQ...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "General",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            _faqTile(
              "How do I place an order?",
              "Browse products, add them to your cart, then proceed to checkout and confirm your delivery address.",
            ),

            _faqTile(
              "Can I cancel my order?",
              "Yes. You can cancel your order before the vendor starts preparing it.",
            ),

            _faqTile(
              "How do I track my order?",
              "Open My Orders and tap your active order to view its live status.",
            ),

            const SizedBox(height: 20),

            const Text(
              "Payments",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _faqTile(
              "Which payment methods are supported?",
              "LocalKart supports Cash on Delivery, eSewa, Khalti and other digital wallets.",
            ),

            _faqTile(
              "My payment failed. What should I do?",
              "Please check your internet connection or payment balance and try again.",
            ),

            const SizedBox(height: 20),

            const Text(
              "Delivery",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _faqTile(
              "How long does delivery take?",
              "Most deliveries are completed within 30–60 minutes depending on distance and shop availability.",
            ),

            _faqTile(
              "Can I change my delivery address?",
              "Yes, before the vendor dispatches your order you may update the address.",
            ),

            const SizedBox(height: 20),

            const Text(
              "Account",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _faqTile(
              "How do I reset my password?",
              "Go to the Login screen and tap 'Forgot Password' to receive an OTP.",
            ),

            _faqTile(
              "How do I edit my profile?",
              "Open your Profile page and tap Edit Profile to update your details.",
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    color: AppColors.primary,
                    size: 42,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Still need help?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Our support team is available 24/7 to help you.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.divider,
        ),
      ),
      child: ExpansionTile(
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondary,
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}