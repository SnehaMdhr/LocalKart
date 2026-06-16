
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:localkart/core/constants/hive_table_constants.dart';
import 'package:localkart/feature/auth/data/models/auth_hive_model.dart';
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
  }
  //Open boxes
  Future<void> openBoxes() async{
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
    await Hive.openBox<ShopHiveModel>(HiveTableConstant.shopTable);
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
}

