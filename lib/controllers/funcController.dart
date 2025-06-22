import 'package:get_storage/get_storage.dart';

class FuncController {
  final GetStorage storage = GetStorage();

  // Tokenni saqlash
  Future<void> saveToken(String token) async {
    await storage.write('token', token);
  }

  // Tokenni o'qish
  String? getToken() {
    return storage.read('token');
  }

  Future<void> deleteToken() async {
    await storage.remove('token');
  }

  get tokenBearer => storage.read('token') ?? '';
}