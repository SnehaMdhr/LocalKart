import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/services/hive/hive.service.dart';
import 'package:localkart/core/services/storage/user_session_service.dart';
import '../../models/auth_hive_model.dart';
import '../auth_datasource.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref){
  final hiveService = ref.watch(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService, userSessionService: userSessionService);
});

class AuthLocalDatasource implements IAuthLocalDatasource{
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({required HiveService hiveService, required UserSessionService userSessionService,})
      : _hiveService =hiveService,
      _userSessionService = userSessionService;

  @override
  Future<bool> isEmailExists(String email) {
    try{
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    }catch(e){
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password)async {
    try{
      final user = await _hiveService.loginUser(email, password);
      return Future.value(user);
    }catch(e){
      return Future.value(null);
    }
  }

  @override
  Future<bool> register(AuthHiveModel model) async{
    try{
      await _hiveService.registerUser(model);
      return Future.value(true);
    }catch(e){
      return Future.value(false);
    }
  }
  
  @override
  Future<bool> logout() async{
     try {
      await _userSessionService.clearSession();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<AuthHiveModel?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

}