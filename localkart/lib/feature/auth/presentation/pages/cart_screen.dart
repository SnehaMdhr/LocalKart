import 'package:flutter/material.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/feature/cart/presentation/pages/cart_detail_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const List<Map<String, dynamic>> bundles = [
    {
      "title": "Breakfast Kit",
      "desc": "Milk, Eggs, Bread & Jam for a perfect start.",
      "price": "NPR 450",
      "icon": Icons.breakfast_dining,
    },
    {
      "title": "Weekly Veggies",
      "desc": "Fresh vegetables for the whole week.",
      "price": "NPR 820",
      "icon": Icons.eco,
    },
    {
      "title": "Fruit Basket",
      "desc": "Seasonal fruits picked fresh.",
      "price": "NPR 650",
      "icon": Icons.apple,
    },
  ];

  static const List<Map<String, String>> orders = [
    {
      "date": "10 Oct, 2023 • 06:20 PM",
      "id": "#LK-8412",
      "price": "Rs 180",
    },
    {
      "date": "15 Oct, 2023 • 01:45 PM",
      "id": "#LK-8421",
      "price": "Rs 560",
    },
    {
      "date": "22 Oct, 2023 • 09:10 AM",
      "id": "#LK-8450",
      "price": "Rs 990",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _cartSummary(context),

            const SizedBox(height: 28),

            _sectionHeader("Saved Bundles", "See All"),

            const SizedBox(height: 14),

            SizedBox(
              height: 185,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: bundles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, index) {
                  final bundle = bundles[index];
                  return _bundleCard(bundle);
                },
              ),
            ),

            const SizedBox(height: 30),

            _sectionHeader("Previous Orders", "History"),

            const SizedBox(height: 14),

            ...orders.map((order) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _orderCard(order),
                )),
          ],
        ),
      ),
    );
  }

  Widget _cartSummary(BuildContext context) {
  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CartDetailScreen(),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: AppColors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Cart",
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "3 Items • NPR 765",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.white,
            size: 18,
          ),
        ],
      ),
    ),
  );
}
  Widget _sectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            action,
            style: const TextStyle(
              color: AppColors.primary,
            ),
          ),
        )
      ],
    );
  }

  Widget _bundleCard(Map<String, dynamic> bundle) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                bundle["icon"],
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bundle["title"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            bundle["desc"],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Text(
                bundle["price"],
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryExtraLight,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(80, 42),
                  elevation: 0,
                ),
                child: const Text("Add"),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _orderCard(Map<String, String> order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order["date"]!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Completed",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Text(
                  "Order ${order["id"]}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Text(
                order["price"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Reorder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryExtraLight,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  minimumSize: const Size(120, 44),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}