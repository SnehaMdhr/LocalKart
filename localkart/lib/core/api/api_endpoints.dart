import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();
  static const bool isPhysicalDevice = true;
  static const String compIpAddress = "10.193.90.231";
  static String get baseUrl {
    if (isPhysicalDevice) {
      return "http://$compIpAddress:3000/api";
    }
    if (kIsWeb) {
      return "http://localhost:3000/api";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:3000/api";
    } else if (Platform.isIOS) {
      return "http://localhost:3000/api";
    } else {
      return "http://localhost:3000/api";
    }
  }

  static String get mediaServerUrl {
    final uri = Uri.parse(baseUrl);
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    ).toString();
  }
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ User Endpoints ============
  static const String users = '/auth';
  static const String userLogin = '/auth/login';
  static const String userRegister = '/auth/register';
  static String getCurrentUser = '/auth/view-my-profile';
  static String userById(String id) => '/auth/$id';
  static String userPhoto(String id) => '/auth/$id/photo';
  static String updateProfile = "/auth/update-profile";
  static String changePassword = "/auth/change-password";
  static String requestPasswordReset = "/auth/request-password-reset";
  static String resetPassword = "/auth/reset-password";
  static const String googleLogin = "/auth/google-login";

  // ============ Shop Endpoints ============
  static const String registerShop = "/shop/register-shop";
  static const String myShop = "/shop/my-shop";
  static String updateShop = "/shop/update-shop";


  //=============== Product Endpoints ============
  static const String getAllProduct = "/product/";
  static const String getProductById = "/product/:id";

  //=============== Collection Endpoints ============
  static const String getMyCollections = "/collection/my";
  static const String getCollectionById = "/collection/:id";
  static const String createCollection = "/collection/add-collection";
  static const String deleteCollection = "/collection/:id";
  static const String addProductToCollection = "/collection/:id/add-product";
  static const String removeProductFromCollection = "/collection/:id/remove-product";
  static const String updateCollection = "/collection/:id";

  //=============== Cart Endpoints ============
  static const String addToCart = "/cart/add";
  static const String getCart = "/cart/";
  static const String updateCartQuantity = "/cart/update";
  static const String removeFromCart = "/cart/remove/";
  static const String clearCart = "/cart/clear";

  //=============== Address Endpoints ============
  static const String createAddress = "/address/";
  static const String getAddresses = "/address/";
  static const String getAddressById = "/address/";
  static const String updateAddress = "/address/";
  static const String deleteAddress = "/address/";

  //=============== Order Endpoints ============
  static const String createOrder = "/order/";
  static const String getMyOrders = "/order/my-orders";
  static const String getShopOrders = "/order/shop/orders";
  static const String getPendingOrders = "/order/shop/pending";
  static const String getOrderById = "/order/";
  static const String acceptOrder = "/order/";
  static const String rejectOrder = "/order/";
  static const String updateOrderStatus = "/order/";
  static const String deleteOrder = "/order/";
  static const String markOrderPaid = "/order/";
  static const String getOrderEtd = "/order/";
}
