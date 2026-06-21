
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:localkart/core/constants/hive_table_constants.dart';
import 'package:localkart/feature/auth/data/models/auth_hive_model.dart';
import 'package:localkart/feature/collection/data/models/collection_hive_model.dart';
import 'package:localkart/feature/product/data/models/product_hive_model.dart';
import 'package:localkart/feature/vendor_registeration/data/models/shop_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref){
  return HiveService();
});
class HiveService {
  //init
  Future<void> init() async{
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/${HiveTableConstant.dbName}";
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }

  //register adapter
  void _registerAdapter(){
    if(!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)){
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if(!Hive.isAdapterRegistered(HiveTableConstant.shopTypeId)){
      Hive.registerAdapter(ShopHiveModelAdapter());
    }

    if(!Hive.isAdapterRegistered(HiveTableConstant.productTypeId)){
      Hive.registerAdapter(ProductHiveModelAdapter());
    }

    if(!Hive.isAdapterRegistered(HiveTableConstant.collectionTypeId)){
      Hive.registerAdapter(CollectionHiveModelAdapter());
    }
  }
  //Open boxes
  Future<void> openBoxes() async{
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
    await Hive.openBox<ShopHiveModel>(HiveTableConstant.shopTable);
    
    // Handle corrupted product data
    try {
      await Hive.openBox<ProductHiveModel>(HiveTableConstant.productTable);
    } catch (e) {
      await Hive.deleteBoxFromDisk(HiveTableConstant.productTable);
      await Hive.openBox<ProductHiveModel>(HiveTableConstant.productTable);
    }

    try {
      await Hive.openBox<CollectionHiveModel>(HiveTableConstant.collectionTable);
    } catch (e) {
      await Hive.deleteBoxFromDisk(HiveTableConstant.collectionTable);
      await Hive.openBox<CollectionHiveModel>(HiveTableConstant.collectionTable);
    }
  }
  //close boxes
  Future <void> close() async{
    await Hive.close();
  }
  //Queries


  Box<AuthHiveModel> get _authBox {
    if (!Hive.isBoxOpen(HiveTableConstant.userTable)) {
      throw Exception('Hive box ${HiveTableConstant.userTable} is not open');
    }
    return Hive.box<AuthHiveModel>(HiveTableConstant.userTable);
  }

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async{
    await _authBox.put(model.userId, model);
    return model;

  }

  Future<AuthHiveModel?> loginUser(String email, String password)async{
    final users = _authBox.values.where(
          (user) => user.email == email && user.password == password,
    );
    if(users.isNotEmpty){
      return users.first;
    }
    return null;
  }

  bool isEmailExists(String email){
    final users = _authBox.values.where((user)=> user.email == email);
    return users.isNotEmpty;
  }

  // ============ Shop Queries ============

  Box<ShopHiveModel> get _shopBox {
    if (!Hive.isBoxOpen(HiveTableConstant.shopTable)) {
      throw Exception('Hive box ${HiveTableConstant.shopTable} is not open');
    }
    return Hive.box<ShopHiveModel>(HiveTableConstant.shopTable);
  }

  Future<ShopHiveModel> registerShop(ShopHiveModel model) async {
    await _shopBox.put(model.shopId, model);
    return model;
  }


  // ======== Collection Queries ===============
  Box<CollectionHiveModel> get _collectionBox {
    if (!Hive.isBoxOpen(HiveTableConstant.collectionTable)) {
      throw Exception(
          'Hive box ${HiveTableConstant.collectionTable} is not open');
    }
    return Hive.box<CollectionHiveModel>(HiveTableConstant.collectionTable);
  }

  Future<List<CollectionHiveModel>> getAllCollections() async {
    return _collectionBox.values.toList();
  }

  Future<CollectionHiveModel?> getCollectionById(String collectionId) async {
    return _collectionBox.get(collectionId);
  }

  Future<void> cacheCollections(List<CollectionHiveModel> collections) async {
    await _collectionBox.clear();
    for (var collection in collections) {
      await _collectionBox.put(collection.collectionId, collection);
    }
  }

  // ======== Product Queries ===============
  Box<ProductHiveModel> get _productBox{
    if(!Hive.isBoxOpen(HiveTableConstant.productTable)){
      throw Exception("Hive box ${HiveTableConstant.productTable} is not open");
    }
    return Hive.box<ProductHiveModel>(HiveTableConstant.productTable);
  }

  Future<List<ProductHiveModel>> getAllProducts() async {
    return _productBox.values.toList();
  }

  Future<ProductHiveModel?> getProductById(String productId) async {
    return _productBox.get(productId);
  }
   Future<void> cacheProducts(List<ProductHiveModel> products) async {
    await _productBox.clear();

    for (var product in products) {
      await _productBox.put(product.productId, product);
    }
  }
}

