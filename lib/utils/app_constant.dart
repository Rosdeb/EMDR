import 'package:flutter_dotenv/flutter_dotenv.dart';
class AppConstants{
  static String get Publishable_key => dotenv.env['STRIPE_PUBLIC_KEY'] ?? '';
  static String get Secret_key => dotenv.env['STRIPE_SECRET_KEY'] ?? '';
  static String get Bennar_ad_Id=> dotenv.env['BANNER_ADS_ID'] ?? '';
}