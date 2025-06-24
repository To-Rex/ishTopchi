import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FuncController {
  final GetStorage storage = GetStorage();

  RxString otpToken = ''.obs;
  RxString otpPhone = ''.obs;

  setOtpToken(String token, String phone) {
    otpToken.value = token;
    otpPhone.value = phone;
  }

  setOtpPhone(String phone) {
    otpPhone.value = phone;
  }

  setOtpTokenOnly(String token) {
    otpToken.value = token;
  }

  clearOtp() {
    otpToken.value = '';
    otpPhone.value = '';
  }

  getOtpToken() => otpToken.value;

  getOtpPhone() => '+998${otpPhone.value}';

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