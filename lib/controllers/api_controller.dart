import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:ishtopchi/core/services/show_toast.dart';
import '../config/routes/app_routes.dart';
import '../core/models/post_model.dart';
import '../core/models/user_me.dart' hide Data;
import '../core/models/wish_list.dart';
import '../modules/login/views/otp_verification_screen.dart';
import 'funcController.dart';

class ApiController extends GetxController {
  static const String _baseUrl = 'https://ishtopchi.uz/api';
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)));

  final FuncController funcController = Get.put(FuncController());

  Future<String?> uploadImage(File image, String? token) async {
    print('uploadImage: ${image.path}');
    print('Token: $token');
    try {
      if (token == null) throw Exception('Token mavjud emas');

      final String fileName = image.path.split('/').last;
      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(image.path, filename: fileName)});

      final response = await _dio.post(
        '$_baseUrl/upload/image',
        data: formData,
        options: Options(headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data'
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String url = response.data['data']['url'];
        print('✅ Rasm serverga yuklandi: $url');
        return url;
      } else {
        ShowToast.show('Xatolik', 'Rasm serverga yuklashda xatolik yuz berdi', 3, 1);
        print('❌ uploadImage xatolik: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      ShowToast.show('Xatolik', 'Exxx nimadir xato ketdi', 3, 1);
      print('❌ uploadImage exception: $e');
      return null;
    }
  }

  // Viloyatlarni olish
  Future<List<Map<String, dynamic>>> fetchRegions() async {
    try {
      final response = await _dio.get('$_baseUrl/regions');
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
      final response = await _dio.get('$_baseUrl/districts?region_id=$regionId&page=1&limit=1000');
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

  Future<void> sendGoogleIdToken(String idToken, String platform) async {
    print('ID Token: $idToken');
    print('Platform: $platform');
    try {
      final response = await _dio.post(
        '$_baseUrl/oauth/google',
        options: Options(headers: {'accept': '*/*', 'Content-Type': 'application/json'}),
        data: {'idToken': idToken, 'platform': platform},
      );

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

      final response = await _dio.get(
        '$_baseUrl/user/me',
        options: Options(headers: {'accept': 'application/json', 'Authorization': 'Bearer $token'}),
      );

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
        options: Options(headers: {'accept': '*/*', 'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('API javobi: ${response.data}');
        final encryptedOtp = response.data['data'];
        print('OTP yuborildi. Encrypted OTP: $encryptedOtp');
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
    final fingerprint = await funcController.getOtpToken();
    final phone = await funcController.getOtpPhone();

    try {
      final response = await _dio.post(
        '$_baseUrl/otp-based-auth/login',
        data: json.encode({"phone_number": "$phone", "otp": otp, "fingerprint": "$fingerprint"}),
        options: Options(headers: {'accept': '*/*', 'Content-Type': 'application/json', 'Authorization': 'Bearer $fingerprint'}),
      );

      print('✅ Javob: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['meta']['is_first_login'] == true) {
          final token = response.data['data']['token']['access_token'];
          await funcController.saveToken(token);
          Get.toNamed(AppRoutes.register);
          print('✅ Login muvaffaqiyatli. Access Token: $token');
        } else {
          final token = response.data['data']['token']['access_token'];
          await funcController.saveToken(token);
          Get.offNamed(AppRoutes.main);
          getMe();
          print('✅ Login muvaffaqiyatli. Access Token: $token');
        }
      } else {
        print('❌ Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ loginWithOtp xatolik: $e');
    }
  }

  Future completeRegistration({required String firstName, required String lastName, required int districtId, required String birthDate, required String gender, required File? image}) async {
    try {
      String? imageUrl;
      if (image != null) {
        imageUrl = await uploadImage(image, funcController.getToken());
        if (imageUrl == null) {
          print('❌ Rasm yuklashda muammo bo‘ldi');
          return;
        }
      }
      final Map<String, dynamic> data = {
        'first_name': firstName,
        'last_name': lastName,
        'district_id': districtId,
        'birth_date': birthDate,
        'gender': gender == '1' ? 'MALE' : 'FEMALE',
      };
      if (imageUrl != null) {
        data['profile_picture'] = imageUrl;
      }
      print('➡️ Registration body: $data');
      final response = await _dio.post(
        '$_baseUrl/otp-based-auth/complete-registration',
        data: data,
        options: Options(headers: {'accept': '*/*', 'Authorization': 'Bearer ${funcController.getToken()}', 'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Ro‘yxatdan o‘tish yakunlandi.');
        Get.offNamed(AppRoutes.main);
      } else {
        print('❌ completeRegistration xatolik: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('❌ completeRegistration exception: $e');
    }
  }



  // Profilni yangilash
  Future<bool> updateProfile({required String firstName, required String lastName, required int districtId, required String birthDate, required String gender, File? image}) async {
    try {
      final token = funcController.getToken();
      if (token == null) throw Exception('Token mavjud emas');

      String? imageUrl;
      if (image != null) {
        imageUrl = await uploadImage(image, token);
        if (imageUrl == null) {
          print('❌ Rasm yuklashda muammo bo‘ldi');
          return false;
        }
      }

      final Map<String, dynamic> data = {
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate,
        'gender': gender,
        'district_id': districtId,
      };
      if (imageUrl != null) {
        data['profile_picture'] = imageUrl;
      }

      final userId = funcController.userMe.value?.data?.id ?? 0; // Foydalanuvchi ID sini olish
      final response = await _dio.patch(
        '$_baseUrl/user/$userId',
        data: json.encode(data),
        options: Options(headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Profil yangilandi: ${response.data}');
        // Yangilangan ma'lumotlarni yuklash
        await getMe();
        return true;
      } else {
        print('❌ updateProfile xatolik: ${response.statusCode} - ${response.data}');
        return false;
      }
    } catch (e) {
      print('❌ updateProfile exception: $e');
      return false;
    }
  }



  // Kategoriyalarni olish
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final token = funcController.getToken();
      if (token == null) throw Exception('Token mavjud emas');

      final response = await _dio.get('$_baseUrl/category?page=1&limit=1000', options: Options(headers: {'accept': '*/*', 'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Kategoriyalarni olishda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchCategories xatolik: $e');
      return [];
    }
  }


  // Posts
  Future<void> fetchPosts({int page = 1, int limit = 10, String? search}) async {
    try {
      funcController.isLoading.value = true;
      final token = funcController.getToken();
      if (token == null) {throw Exception('Token mavjud emas');}
      if (page == 1) {funcController.hasMore.value = true;}
      String url = '$_baseUrl/posts?page=$page&limit=$limit';
      if (search != null && search.isNotEmpty) {url += '&search=$search';}
      final response = await _dio.get(url, options: Options(headers: {'accept': '*/*', 'Authorization': 'Bearer $token'}));
      print('API javobi posts (page $page): ${response.data}');
      print('Status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final meta = Meta.fromJson(response.data['meta']);
        funcController.totalPosts.value = meta.total ?? 0;
        funcController.totalPages.value = meta.totalPages ?? 1;

        if (data.isEmpty) {
          print('Ma’lumotlar tugadi');
          funcController.hasMore.value = false;
          return;
        }

        final newPosts = data.map((json) => Data.fromJson(json)).toList();

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

  Future<void> createPost(Map<String, dynamic> postData, String token) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/posts',
        data: json.encode(postData),
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Post muvaffaqiyatli yaratildi: ${response.data}');
      } else {
        print('❌ createPost xatolik: ${response.statusCode} - ${response.data}');
        ShowToast.show('Xatolik', 'Post yuborishda xatolik yuz berdi', 3, 1);
      }
    } catch (e) {
      print('❌ createPost exception: $e');
      ShowToast.show('Xatolik', 'Post yuborishda xato: $e', 3, 1);
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
        funcController.wishList.value = data
            .where((json) => json != null)
            .map((json) => WishList.fromJson(json as Map<String, dynamic>))
            .toList();
        print('WishList uzunligi: ${funcController.wishList.length}');
      } else if (response.statusCode == 404) {
        funcController.clearWishList();
        print('Wishlist bo‘sh');
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
    print(postId);
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
          'Authorization': 'Bearer $token'
        })
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
}