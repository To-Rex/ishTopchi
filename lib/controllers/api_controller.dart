import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../config/routes/app_routes.dart';
import '../core/models/post_model.dart';
import '../core/models/user_me.dart';
import '../modules/login/views/otp_verification_screen.dart';
import 'funcController.dart';


class ApiController extends GetxController {
  static const String _baseUrl = 'https://ishtopchi.uz/api';
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)));

  final FuncController funcController = Get.put(FuncController()); // ✅ DI orqali chaqiramiz

  Future<void> sendGoogleIdToken(String idToken, String platform) async {
    print('ID Token: $idToken');
    print('Platform: $platform');

    try {
      final response = await _dio.post('$_baseUrl/oauth/google', options: Options(headers: {'accept': '*/*', 'Content-Type': 'application/json'}), data: {'idToken': idToken, 'platform': platform},);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('API javobi: ${response.data}');
        final accessToken = response.data['data']['token']['access_token'];
        await funcController.saveToken(accessToken);

        print('Access token saqlandi: $accessToken');
        Get.offNamed(AppRoutes.main);
        getMe();
      } else {
        print('${response.data}');
        throw Exception('API xatosi: ${response.statusCode} - ${response.data}');
      }
    } catch (error) {
      print('API so‘rovi xatosi: $error');
      throw Exception('API so‘rovi xatosi: $error');
    }
  }

  Future<UserMe?> getMe() async {
    try {
      final token = funcController.getToken();
      print('Token: $token');
      if (token == null) {
        throw Exception('Token mavjud emas');
      }

      final response = await _dio.get('$_baseUrl/user/me', options: Options(headers: {'accept': 'application/json', 'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200) {
        final data = response.data;
        print('User ME: $data');
        fetchPosts();
        fetchWishlist();
        funcController.setUserMe(UserMe.fromJson(data));
        return UserMe.fromJson(data);
      } else {
        print('Xatolik: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      print('getMe xatosi: $e');
      return null;
    }
  }

  Future generateOtp(String phoneNumber) async {
    print('Phone number: $phoneNumber');
    try {
      final response = await _dio.post(
        '$_baseUrl/otp-based-auth/generate-otp',
        data: {'phoneNumber': '+998$phoneNumber'},
        options: Options(headers: {
          'accept': '*/*',
          'Content-Type': 'application/json'})
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('API javobi: ${response.data}');
        final encryptedOtp = response.data['data'];
        print('OTP yuborildi. Encrypted OTP: $encryptedOtp');
        //funcController.setOtpToken(encryptedOtp, phoneNumber);
        funcController.setOtpTokenOnly(encryptedOtp);
        funcController.setOtpPhone(phoneNumber);
        Get.to(() => OtpVerificationScreen(phone: phoneNumber.trim()), transition: Transition.fadeIn);
      } else {
        print('OTP yuborishda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      print('generateOtp xatolik: $e');
    }
  }

  Future<void> loginWithOtp({required String otp}) async {
    final fingerprint = await funcController.getOtpToken(); // JWT fingerprint
    final phone = await funcController.getOtpPhone();

    try {
      final response = await _dio.post('$_baseUrl/otp-based-auth/login',
        data: json.encode({"phone_number": "$phone", "otp": otp, "fingerprint": "$fingerprint"}),
        options: Options(headers: {'accept': '*/*', 'Content-Type': 'application/json', 'Authorization': 'Bearer $fingerprint'})
      );

      print('✅ Javob: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final accessToken = response.data['data']['token']['access_token'];
        await funcController.saveToken(accessToken);
        Get.offNamed(AppRoutes.main);
        getMe();
        print('✅ Login muvaffaqiyatli. Access Token: $accessToken');
      } else {
        print('❌ Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ loginWithOtp xatolik: $e');
    }
  }

  Future<bool> completeRegistration({required String firstName, required String lastName, required int districtId, required String birthDate, required String token}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/otp-based-auth/complete-registration',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'district_id': districtId,
          'birth_date': birthDate,
        },
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Ro‘yxatdan o‘tish yakunlandi.');
        return true;
      } else {
        print('completeRegistration xatolik: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('completeRegistration xatolik: $e');
      return false;
    }
  }





  // Posts
  Future<void> fetchPosts({int page = 1, int limit = 10, String? search}) async {
    try {
      funcController.isLoading.value = true;

      final token = funcController.getToken();
      if (token == null) {
        throw Exception('Token mavjud emas');
      }

      if (page == 1) {
        funcController.hasMore.value = true;
      }

      String url = '$_baseUrl/posts?page=$page&limit=$limit';
      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }

      final response = await _dio.get(
        url,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        }),
      );

      print('API javobi posts (page $page): ${response.data}');
      print('Status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        if (data.isEmpty) {
          print('Ma’lumotlar tugadi');
          funcController.hasMore.value = false;
          return;
        }

        final newPosts = data.map((json) => Post.fromJson(json)).toList();

        if (page == 1) {
          funcController.posts.value = newPosts;
        } else {
          funcController.posts.addAll(newPosts);
        }
      } else {
        throw Exception('Postlarni olishda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchPosts xatolik (page $page): $e');
    } finally {
      funcController.isLoading.value = false;
    }
  }

  // Wishlistni olish
  Future<void> fetchWishlist() async {
    try {
      final token = funcController.getToken();
      if (token == null) {
        throw Exception('Token mavjud emas');
      }
      final response = await _dio.get(
        '$_baseUrl/wishlist',
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        }),
      );
      print('API javobi wishlist: ${response.data}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        funcController.wishList.value = data.map((json) => Post.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        funcController.clearWishList();
      } else {
        print('Wishlistni olishda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      funcController.clearWishList();
      print('fetchWishlist xatolik: $e');
    }
  }

  // Yoqtirish (wishlist'ga qo'shish)
  Future<void> addToWishlist(int postId) async {
    try {
      final token = funcController.getToken();
      if (token == null) {
        throw Exception('Token mavjud emas');
      }

      final response = await _dio.post(
        '$_baseUrl/wishlist',
        data: {'post_id': postId},
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Post wishlistga qo‘shildi: $postId');
        fetchWishlist(); // Wishlistni yangilash
      } else {
        throw Exception('Wishlistga qo‘shishda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      print('addToWishlist xatolik: $e');
    }
  }

  Future<void> removeFromWishlist(int wishlistId) async {
    print('wishlistId: $wishlistId');
    try {
      final token = funcController.getToken();
      if (token == null) {
        throw Exception('Token mavjud emas');
      }

      final response = await _dio.delete(
        '$_baseUrl/wishlist/$wishlistId',
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 201) {
        fetchWishlist(); // Wishlistni yangilash
      } else {
        throw Exception('Wishlistdan o‘chirishda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      print('removeFromWishlist xatolik: $e');
    }
  }




  // Viloyatlarni olish
  Future<List<Map<String, dynamic>>> fetchRegions() async {
    try {
      final token = funcController.getToken();
      if (token == null) throw Exception('Token mavjud emas');

      final response = await _dio.get(
        '$_baseUrl/regions',
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['items'] as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Viloyatlarni olishda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchRegions xatolik: $e');
      return [];
    }
  }


  // Tumanlarni olish (region_id bo‘yicha)
  Future<List<Map<String, dynamic>>> fetchDistricts(int regionId) async {
    try {
      final token = funcController.getToken();
      if (token == null) throw Exception('Token mavjud emas');

      final response = await _dio.get(
        '$_baseUrl/districts?region_id=$regionId&page=1&limit=100',
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['items'] as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Tumanlarni olishda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchDistricts xatolik: $e');
      return [];
    }
  }

}