import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' hide Data;
import '../core/models/me_post_model.dart';
import '../core/models/post_model.dart';
import '../core/models/user_me.dart' hide Data;
import '../core/models/wish_list.dart';
import '../modules/ad_posting/controllers/ad_posting_controller.dart';

class FuncController {
  final GetStorage storage = GetStorage();

  final RxString otpToken = ''.obs;
  final RxString otpPhone = ''.obs;
  final RxList<Data> posts = <Data>[].obs;
  final RxList<MeData> mePosts = <MeData>[].obs;
  final RxList<WishList> wishList = <WishList>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxInt totalPosts = 0.obs;
  final RxInt totalMePosts = 0.obs;
  final userMe = Rxn<UserMe>();

  final RxList<Map<String, dynamic>> regions = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> districts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxnInt selectedRegion = RxnInt(); // null boshlang‘ich qiymat
  final RxnInt selectedDistrict = RxnInt(); // null boshlang‘ich qiymat
  final RxnInt selectedCategory = RxnInt(); // null boshlang‘ich qiymat
  final RxnString jobType = RxnString(); // null boshlang‘ich qiymat
  final RxnString employmentType = RxnString(); // null boshlang‘ich qiymat
  final RxnString sortPrice = RxnString(); // null boshlang‘ich qiymat
  final RxBool isGridView = true.obs;
  final RxBool isLoadingDistricts = false.obs;

  final RxnString minPrice = RxnString(); // Yangi: Narxdan
  final RxnString maxPrice = RxnString(); // Yangi: Narxgacha

  String getProfileUrl(String? url) {
    const base = 'https://ishtopchi.uz';
    if (url == null || url.trim().isEmpty) {
      return 'https://help.tithe.ly/hc/article_attachments/18804144460951';
    }
    url = url.trim();
    return url.startsWith('http') ? url : '$base/${url.replaceAll(RegExp(r'^(file://)?/+'), '')}';
  }

  void clearWishList() {
    wishList.clear();
  }

  void setUserMe(UserMe userModel) {
    userMe.value = userModel;
  }

  void setOtpToken(String token, String phone) {
    otpToken.value = token;
    otpPhone.value = phone;
  }

  void setOtpPhone(String phone) {
    otpPhone.value = phone;
  }

  void setOtpTokenOnly(String token) {
    otpToken.value = token;
  }

  void clearOtp() {
    otpToken.value = '';
    otpPhone.value = '';
  }

  String getOtpToken() => otpToken.value;

  String getOtpPhone() => '+998${otpPhone.value}';

  Future<void> saveToken(String token) async {
    await storage.write('token', token);
  }

  String? getToken() {
    return storage.read('token');
  }

  Future<void> deleteToken() async {
    await storage.remove('token');
  }

  String get tokenBearer => storage.read('token') ?? '';

  void clearFilters() {
    selectedRegion.value = null;
    selectedDistrict.value = null;
    selectedCategory.value = null;
    employmentType.value = null;
    sortPrice.value = null;
    minPrice.value = null;
    maxPrice.value = null;
    jobType.value = null;
    districts.clear();
  }

}