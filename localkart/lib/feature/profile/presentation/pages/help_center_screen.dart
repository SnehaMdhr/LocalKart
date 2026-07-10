import 'package:flutter/material.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/widgets/custom_button.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Help Center",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Need Assistance?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "We're here to make your LocalKart experience smooth and hassle-free. Browse our help topics or contact our support team anytime.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const _SectionTitle("Help Categories"),

            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: const [

                _HelpCategoryCard(
                  icon: Icons.shopping_bag_outlined,
                  title: "Orders",
                  subtitle: "Track & manage orders",
                ),

                _HelpCategoryCard(
                  icon: Icons.local_shipping_outlined,
                  title: "Delivery",
                  subtitle: "Shipping & ETD",
                ),

                _HelpCategoryCard(
                  icon: Icons.payments_outlined,
                  title: "Payments",
                  subtitle: "Payments & refunds",
                ),

                _HelpCategoryCard(
                  icon: Icons.person_outline,
                  title: "Account",
                  subtitle: "Profile & password",
                ),

                _HelpCategoryCard(
                  icon: Icons.storefront_outlined,
                  title: "Vendor",
                  subtitle: "Seller registration",
                ),

                _HelpCategoryCard(
                  icon: Icons.assignment_return_outlined,
                  title: "Returns",
                  subtitle: "Missing or damaged",
                ),
              ],
            ),

            const SizedBox(height: 30),

            const _SectionTitle("Popular Help Articles"),

            const SizedBox(height: 12),

            const _ArticleTile(
              icon: Icons.shopping_cart_checkout,
              title: "How do I place an order?",
              subtitle:
                  "Browse products, add them to your cart and complete checkout.",
            ),

            const _ArticleTile(
              icon: Icons.location_on_outlined,
              title: "How can I track my order?",
              subtitle:
                  "Track your grocery order in real-time from the Orders page.",
            ),

            const _ArticleTile(
              icon: Icons.currency_exchange,
              title: "How do refunds work?",
              subtitle:
                  "Learn about refunds for cancelled or unavailable products.",
            ),

            const _ArticleTile(
              icon: Icons.store,
              title: "How do I become a vendor?",
              subtitle:
                  "Register your grocery shop and start receiving orders.",
            ),

            const _ArticleTile(
              icon: Icons.home_outlined,
              title: "How can I change my address?",
              subtitle:
                  "Update your saved delivery addresses anytime.",
            ),

            const SizedBox(height: 30),

            const _SectionTitle("Support Availability"),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.divider,
                ),
              ),
              child: const Column(
                children: [

                  _InfoRow(
                    icon: Icons.schedule,
                    title: "Support Hours",
                    value: "8:00 AM – 10:00 PM",
                  ),

                  Divider(),

                  _InfoRow(
                    icon: Icons.timer_outlined,
                    title: "Average Response",
                    value: "Under 15 minutes",
                  ),

                  Divider(),

                  _InfoRow(
                    icon: Icons.language,
                    title: "Languages",
                    value: "English • Nepali",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
                        const _SectionTitle("Contact Support"),

            const SizedBox(height: 14),

            const _ContactTile(
              icon: Icons.phone_outlined,
              title: "Call Support",
              subtitle: "+977 9800000000",
              description: "Speak directly with our customer support team.",
            ),

            const SizedBox(height: 12),

            const _ContactTile(
              icon: Icons.email_outlined,
              title: "Email Support",
              subtitle: "support@localkart.com",
              description: "Usually responds within 24 hours.",
            ),

            const SizedBox(height: 12),

            const _ContactTile(
              icon: Icons.chat_bubble_outline,
              title: "Live Chat",
              subtitle: "Available during support hours",
              description: "Quick assistance for order related issues.",
            ),

            const SizedBox(height: 30),

          

          

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.storefront,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "LocalKart Support",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Serving local communities with fast, reliable and convenient grocery delivery.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _HelpCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HelpCategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryExtraLight,
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ArticleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryExtraLight,
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle)
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryExtraLight,
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}