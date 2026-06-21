import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();
  static const bool isPhysicalDevice = false;
  static const String compIpAddress = "192.168.32.231";
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
}
