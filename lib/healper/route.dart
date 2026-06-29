import 'package:get/get.dart';
import 'package:jonssony/views/auth/forgot/Forget_Password.dart';
import 'package:jonssony/views/auth/sendverification/SendVerifyCodeScreen.dart';
import 'package:jonssony/views/auth/change_password/ChangePasswordScreen.dart';
import 'package:jonssony/views/auth/signup_verification/SignUp_Verification.dart';
import 'package:jonssony/views/home/home_screen.dart';
import 'package:jonssony/views/main_screen.dart';
import 'package:jonssony/views/offline/offline_page.dart';
import '../views/splash_screen.dart';
import '../views/auth/welcome/welcome_screen.dart';
import '../views/auth/login/login_screen.dart';
import '../views/auth/signup/signup_screen.dart';
import '../views/Library/library_page.dart';
import '../views/progress/progress_page.dart';
import '../views/profile/profile_page.dart';
import '../views/home/Notification/Notification.dart';


class RouteHelper {
  static const String splash = '/';
  static const String authWelcome = '/auth-welcome';
  static const String login = '/login';
  static const String forget = '/Forget_Password';
  static const String verify = '/SendVerifyCodeScreen';
  static const String signup = '/signup';
  static const String singup_verification = "/SignUp_Verification";
  static const String home = '/home_screen';
  static const String library = '/library';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String changePassword = '/change_password';
  static const String main = '/main';
  static const String notifications = '/notifications';
  static const String offline = '/offline';


  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: authWelcome, page: () => const AuthWelcomeScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () =>  SignUpScreen()),
    GetPage(name: forget, page: () => const ForgetScreen()),
    GetPage(name: verify, page: () => Verification()),
    GetPage(name: changePassword, page: () =>  ChangePasswordScreen()),
    GetPage(name: singup_verification, page: () => SignUpVerification()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: library, page: () => const LibraryPage()),
    GetPage(name: progress, page: () => const ProgressPage()),
    GetPage(name: profile, page: () => const ProfilePage()),
    GetPage(name: main, page: () => const MainScreen()),
    GetPage(name: notifications, page: () => const NotificationScreen()),
    GetPage(name: offline, page: () => const OfflinePage()),
  ];

}