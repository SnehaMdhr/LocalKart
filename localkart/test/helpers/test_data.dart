import 'package:localkart/feature/auth/domain/entities/auth_entity.dart';
import 'package:localkart/feature/auth/data/models/auth_api_model.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';
import 'package:localkart/feature/product/data/models/product_api_model.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/cart/data/models/cart_api_model.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/data/models/order_api_model.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';
import 'package:localkart/feature/address/data/models/address_api_model.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/data/models/collection_api_model.dart';
import 'package:localkart/feature/notification/domain/entities/notification_entity.dart';
import 'package:localkart/feature/notification/data/models/notification_api_model.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';
import 'package:localkart/feature/rating/data/models/rating_api_model.dart';
import 'package:localkart/feature/vendor_registeration/domain/entities/shop_entity.dart';
import 'package:localkart/feature/vendor_registeration/data/models/shop_api_model.dart';

// ═══════════════════════════════════════════════════
// AUTH
// ═══════════════════════════════════════════════════
AuthEntity createTestAuthEntity({
  String? userId,
  String name = 'John Doe',
  String email = 'john@test.com',
  String? phone = '9876543210',
  String? role = 'Customer',
}) {
  return AuthEntity(
    userId: userId ?? 'user-1',
    name: name,
    email: email,
    phone: phone,
    role: role,
  );
}

AuthApiModel createTestAuthApiModel({
  String? id,
  String name = 'John Doe',
  String email = 'john@test.com',
  String? phone = '9876543210',
  String? role = 'Customer',
}) {
  return AuthApiModel(
    id: id ?? 'user-1',
    name: name,
    email: email,
    phone: phone,
    role: role,
  );
}

Map<String, dynamic> createTestAuthJson({
  String? id,
  String name = 'John Doe',
  String email = 'john@test.com',
  String? phone = '9876543210',
}) {
  return {
    '_id': id ?? 'user-1',
    'name': name,
    'email': email,
    'phone': phone,
    'role': 'Customer',
  };
}

// ═══════════════════════════════════════════════════
// PRODUCT
// ═══════════════════════════════════════════════════
ProductEntity createTestProductEntity({
  String? productId,
  String productName = 'Apple',
  String categoryName = 'Fruits',
  int price = 100,
  String unit = 'kg',
}) {
  return ProductEntity(
    productId: productId ?? 'prod-1',
    productName: productName,
    categoryName: categoryName,
    price: price,
    unit: unit,
    description: 'Fresh apple',
    imageUrl: 'https://example.com/apple.jpg',
  );
}

ProductApiModel createTestProductApiModel({
  String? productId,
  String productName = 'Apple',
  String categoryName = 'Fruits',
  int price = 100,
  String unit = 'kg',
}) {
  return ProductApiModel(
    productId: productId ?? 'prod-1',
    productName: productName,
    categoryName: categoryName,
    price: price,
    unit: unit,
    description: 'Fresh apple',
    imageUrl: 'https://example.com/apple.jpg',
  );
}

Map<String, dynamic> createTestProductJson() {
  return {
    '_id': 'prod-1',
    'productName': 'Apple',
    'description': 'Fresh apple',
    'categoryName': 'Fruits',
    'unit': 'kg',
    'price': 100,
    'imageUrl': 'https://example.com/apple.jpg',
  };
}

// ═══════════════════════════════════════════════════
// CART
// ═══════════════════════════════════════════════════
CartItemEntity createTestCartItemEntity({
  String productId = 'prod-1',
  String? productName = 'Apple',
  int? price = 100,
  int quantity = 2,
}) {
  return CartItemEntity(
    productId: productId,
    productName: productName,
    price: price,
    quantity: quantity,
  );
}

CartEntity createTestCartEntity({
  String? cartId = 'cart-1',
  String userId = 'user-1',
  List<CartItemEntity>? items,
}) {
  return CartEntity(
    cartId: cartId,
    userId: userId,
    items: items ?? [createTestCartItemEntity()],
  );
}

CartItemApiModel createTestCartItemApiModel({
  String productId = 'prod-1',
  int quantity = 2,
}) {
  return CartItemApiModel(
    productId: productId,
    productName: 'Apple',
    price: 100,
    quantity: quantity,
  );
}

Map<String, dynamic> createTestCartItemJson() {
  return {
    'productId': 'prod-1',
    'quantity': 2,
  };
}

Map<String, dynamic> createTestCartJson() {
  return {
    '_id': 'cart-1',
    'userId': 'user-1',
    'items': [createTestCartItemJson()],
  };
}

// ═══════════════════════════════════════════════════
// ORDER
// ═══════════════════════════════════════════════════
OrderItemEntity createTestOrderItemEntity({
  String productId = 'prod-1',
  int quantity = 2,
}) {
  return OrderItemEntity(
    productId: productId,
    productName: 'Apple',
    price: 100,
    quantity: quantity,
  );
}

OrderEntity createTestOrderEntity({String? orderId}) {
  return OrderEntity(
    orderId: orderId ?? 'order-1',
    customerId: 'user-1',
    shopId: 'shop-1',
    orderNumber: 'ORD-001',
    items: [createTestOrderItemEntity()],
    totalAmount: 200,
    deliveryAddress: 'KTM, Nepal',
    paymentMethod: 'Cash on Delivery',
    status: 'Pending',
  );
}

OrderApiModel createTestOrderApiModel({String? orderId}) {
  return OrderApiModel(
    orderId: orderId ?? 'order-1',
    customerId: 'user-1',
    shopId: 'shop-1',
    orderNumber: 'ORD-001',
    items: [
      OrderItemApiModel(productId: 'prod-1', quantity: 2),
    ],
    totalAmount: 200,
    deliveryAddress: 'KTM, Nepal',
    status: 'Pending',
  );
}

Map<String, dynamic> createTestOrderJson() {
  return {
    '_id': 'order-1',
    'customerId': 'user-1',
    'shopId': 'shop-1',
    'orderNumber': 'ORD-001',
    'items': [
      {'productId': 'prod-1', 'quantity': 2},
    ],
    'totalAmount': 200,
    'deliveryAddress': 'KTM, Nepal',
    'paymentMethod': 'Cash on Delivery',
    'status': 'Pending',
    'paymentStatus': 'Pending',
  };
}

// ═══════════════════════════════════════════════════
// ADDRESS
// ═══════════════════════════════════════════════════
AddressEntity createTestAddressEntity({String? addressId}) {
  return AddressEntity(
    addressId: addressId ?? 'addr-1',
    userId: 'user-1',
    label: 'Home',
    fullAddress: 'Kathmandu, Nepal',
    latitude: 27.7172,
    longitude: 85.3240,
  );
}

AddressApiModel createTestAddressApiModel({String? addressId}) {
  return AddressApiModel(
    addressId: addressId ?? 'addr-1',
    userId: 'user-1',
    label: 'Home',
    fullAddress: 'Kathmandu, Nepal',
    latitude: 27.7172,
    longitude: 85.3240,
  );
}

Map<String, dynamic> createTestAddressJson() {
  return {
    '_id': 'addr-1',
    'userId': 'user-1',
    'label': 'Home',
    'fullAddress': 'Kathmandu, Nepal',
    'latitude': 27.7172,
    'longitude': 85.3240,
  };
}

// ═══════════════════════════════════════════════════
// COLLECTION
// ═══════════════════════════════════════════════════
CollectionEntity createTestCollectionEntity({String? collectionId}) {
  return CollectionEntity(
    collectionId: collectionId ?? 'coll-1',
    userId: 'user-1',
    collectionName: 'My Favorites',
    productIds: ['prod-1', 'prod-2'],
  );
}

CollectionApiModel createTestCollectionApiModel({String? collectionId}) {
  return CollectionApiModel(
    collectionId: collectionId ?? 'coll-1',
    userId: 'user-1',
    collectionName: 'My Favorites',
    productIds: ['prod-1', 'prod-2'],
  );
}

Map<String, dynamic> createTestCollectionJson() {
  return {
    '_id': 'coll-1',
    'userId': 'user-1',
    'collectionName': 'My Favorites',
    'productIds': ['prod-1', 'prod-2'],
  };
}

// ═══════════════════════════════════════════════════
// NOTIFICATION
// ═══════════════════════════════════════════════════
NotificationEntity createTestNotificationEntity({String? notificationId}) {
  return NotificationEntity(
    notificationId: notificationId ?? 'notif-1',
    receiverId: 'user-1',
    receiverRole: 'Customer',
    title: 'Order Update',
    message: 'Your order has been accepted',
    type: 'ORDER',
    orderId: 'order-1',
    isRead: false,
  );
}

NotificationApiModel createTestNotificationApiModel({String? notificationId}) {
  return NotificationApiModel(
    notificationId: notificationId ?? 'notif-1',
    receiverId: 'user-1',
    receiverRole: 'Customer',
    title: 'Order Update',
    message: 'Your order has been accepted',
    type: 'ORDER',
    orderId: 'order-1',
    isRead: false,
  );
}

Map<String, dynamic> createTestNotificationJson() {
  return {
    '_id': 'notif-1',
    'receiverId': 'user-1',
    'receiverRole': 'Customer',
    'title': 'Order Update',
    'message': 'Your order has been accepted',
    'type': 'ORDER',
    'orderId': 'order-1',
    'isRead': false,
  };
}

// ═══════════════════════════════════════════════════
// RATING
// ═══════════════════════════════════════════════════
RatingEntity createTestRatingEntity({String? ratingId}) {
  return RatingEntity(
    ratingId: ratingId ?? 'rating-1',
    orderId: 'order-1',
    customerId: 'user-1',
    vendorId: 'vendor-1',
    shopId: 'shop-1',
    rating: 5,
    comment: 'Great service!',
  );
}

RatingApiModel createTestRatingApiModel({String? ratingId}) {
  return RatingApiModel(
    ratingId: ratingId ?? 'rating-1',
    orderId: 'order-1',
    customerId: 'user-1',
    vendorId: 'vendor-1',
    shopId: 'shop-1',
    rating: 5,
    comment: 'Great service!',
  );
}

Map<String, dynamic> createTestRatingJson() {
  return {
    '_id': 'rating-1',
    'orderId': 'order-1',
    'customerId': 'user-1',
    'vendorId': 'vendor-1',
    'shopId': 'shop-1',
    'rating': 5,
    'comment': 'Great service!',
  };
}

// ═══════════════════════════════════════════════════
// SHOP
// ═══════════════════════════════════════════════════
ShopEntity createTestShopEntity({String? shopId}) {
  return ShopEntity(
    shopId: shopId ?? 'shop-1',
    userId: 'vendor-1',
    shopName: 'My Store',
    address: 'Kathmandu',
    description: 'A local grocery store',
    categories: ['Vegetables', 'Fruits'],
    status: 'Approved',
    latitude: 27.7172,
    longitude: 85.3240,
  );
}

ShopApiModel createTestShopApiModel({String? id}) {
  return ShopApiModel(
    id: id ?? 'shop-1',
    userId: 'vendor-1',
    shopName: 'My Store',
    address: 'Kathmandu',
    description: 'A local grocery store',
    categories: ['Vegetables', 'Fruits'],
    status: 'Approved',
    latitude: 27.7172,
    longitude: 85.3240,
  );
}

Map<String, dynamic> createTestShopJson() {
  return {
    '_id': 'shop-1',
    'userId': 'vendor-1',
    'shopName': 'My Store',
    'address': 'Kathmandu',
    'description': 'A local grocery store',
    'categories': ['Vegetables', 'Fruits'],
    'status': 'Approved',
    'latitude': 27.7172,
    'longitude': 85.3240,
  };
}
