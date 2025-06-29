import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/models/post_model.dart';
import '../core/models/user_me.dart';
import '../core/models/wish_list.dart';

class FuncController {
  final GetStorage storage = GetStorage();

  RxString otpToken = ''.obs;
  RxString otpPhone = ''.obs;

  final RxList<Post> posts = <Post>[].obs;
  final RxList<WishList> wishList = <WishList>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final userMe = Rxn<UserMe>();

  void setUserMe(UserMe userModel) {
    userMe.value = userModel;
  }

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