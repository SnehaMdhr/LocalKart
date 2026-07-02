import 'package:flutter/material.dart';
import 'package:localkart/app/theme/app_colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Terms of Service",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Legal Agreement",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Welcome to LocalKart. These Terms govern your use of our platform and services. By accessing or using the app, you agree to comply with these terms.",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Last Updated: July 2025",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _section(
                    "1. User Accounts",
                    [
                      "You are responsible for maintaining your account credentials.",
                      "Provide accurate information during registration.",
                      "Do not share your password with anyone.",
                      "We reserve the right to suspend accounts violating these terms.",
                    ],
                  ),

                  _section(
                    "2. Ordering & Delivery",
                    [
                      "Orders are subject to vendor availability.",
                      "Estimated delivery times are approximate.",
                      "Delivery areas are limited to supported locations.",
                      "Order cancellations may be restricted once preparation begins.",
                    ],
                  ),

                  _section(
                    "3. Payment Terms",
                    [
                      "Payments can be made using supported digital wallets or Cash on Delivery.",
                      "Refunds are processed according to our refund policy.",
                      "Prices shown include applicable taxes unless stated otherwise.",
                    ],
                  ),

                  _section(
                    "4. Governing Law",
                    [
                      "These Terms are governed by the laws of Nepal.",
                      "Disputes shall be settled in accordance with applicable regulations.",
                      "LocalKart reserves the right to modify these Terms at any time.",
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.help_outline,
                          color: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            "Have questions about our Terms? Contact our support team for assistance.",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<String> points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...points.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}