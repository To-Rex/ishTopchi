import 'package:get/get.dart';
import 'package:ishtopchi/modules/login/views/register_screen.dart';
import 'package:ishtopchi/modules/main/bindings/notifications_binding.dart';
import 'package:ishtopchi/modules/splash/bindings/splash_binding.dart';
import 'package:ishtopchi/modules/splash/splash_screen.dart';
import '../../modules/ad_posting/bindings/ad_posting_binding.dart';
import '../../modules/ad_posting/views/ad_posting_screen.dart';
import '../../modules/favorites/bindings/favorites_binding.dart';
import '../../modules/favorites/views/favorites_screen.dart';
import '../../modules/login/bindings/login_binding.dart';
import '../../modules/login/bindings/register_binding.dart';
import '../../modules/login/views/login_screen.dart';
import '../../modules/main/bindings/main_binding.dart';
import '../../modules/main/views/main_screen.dart';
import '../../modules/main/views/notifications_screen.dart';
import '../../modules/messages/bindings/messages_binding.dart';
import '../../modules/messages/views/message_detail_screen.dart';
import '../../modules/messages/views/messages_screen.dart';
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/views/onboarding_screen.dart';
import '../../modules/profile/bindings/my_posts_binding.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/profile/views/my_posts_screen.dart';
import '../../modules/profile/views/profile_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400)
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => OnboardingScreen(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400)
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400)
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterScreen(),
      binding: RegisterBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400)
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => MainScreen(),
      binding: MainBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400)
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => FavoritesScreen(),
      binding: FavoritesBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400)
    ),
    GetPage(
      name: AppRoutes.adPosting,
      page: () => AdPostingScreen(),
      binding: AdPostingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400)
    ),
    GetPage(
      name: AppRoutes.messages,
      page: () => MessagesScreen(),
      binding: MessagesBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400)
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400)
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => NotificationsScreen(),
      binding: NotificationsBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400)
    ),
    GetPage(
      name: AppRoutes.messagesDetail,
      page: () => MessageDetailScreen(),
      binding: MessagesBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400)
    ),
    GetPage(
        name: AppRoutes.myPosts,
        page: () => MyPostsScreen(),
        binding: MyPostsBinding(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 400)
    ),
  ];
}