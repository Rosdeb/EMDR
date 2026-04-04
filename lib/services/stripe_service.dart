// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
//
//
//
// enum PaymentResult { success, canceled, failed }
//
// class StripeService {
//   StripeService._();
//   static final StripeService instance = StripeService._();
//
//   final String id='';
//
//   Future<PaymentResponse> makePayment({
//     required double amount,
//     required String currency,
//   }) async {
//     try {
//       if (amount <= 0) throw ArgumentError('Amount must be greater than 0');
//
//       final amountInCents = (amount * 100).toInt();
//       final paymentIntentData = await _createPaymentIntent(amountInCents, currency);
//
//       if (paymentIntentData == null) return PaymentResponse(PaymentResult.failed);
//
//       final clientSecret = paymentIntentData['client_secret']!;
//       final paymentIntentId = paymentIntentData['id']!; // ✅ Stripe ID
//
//       print("🎯 Stripe PaymentIntent ID: $paymentIntentId");
//
//       await _initializePaymentSheet(clientSecret);
//
//       final result = await _processPayment();
//
//       return PaymentResponse(result, paymentIntentId: paymentIntentId);
//     } on StripeException catch (e) {
//       print("Stripe Error in makePayment: ${e.error.localizedMessage}");
//       return PaymentResponse(_handleStripeError(e));
//     } catch (e) {
//       print("Unexpected Error in makePayment: $e");
//       return PaymentResponse(PaymentResult.failed);
//     }
//   }
//
//
//   Future<void> _initializePaymentSheet(String clientSecret) async {
//     await Stripe.instance.initPaymentSheet(
//       paymentSheetParameters: SetupPaymentSheetParameters(
//         paymentIntentClientSecret: clientSecret,
//         merchantDisplayName: "EMDR",
//         googlePay: const PaymentSheetGooglePay(
//           merchantCountryCode: 'US',
//           testEnv: true,
//         ),
//         style: ThemeMode.light,
//         allowsDelayedPaymentMethods: true,
//         customFlow: false,
//         appearance: const PaymentSheetAppearance(
//           colors: PaymentSheetAppearanceColors(
//             primary: Colors.blue,
//           ),
//           shapes: PaymentSheetShape(
//             borderWidth: 1.0,
//             shadow: PaymentSheetShadowParams(color: Colors.transparent),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<PaymentResult> _processPayment() async {
//     try {
//       await Stripe.instance.presentPaymentSheet();
//       print('Payment completed successfully!');
//       return PaymentResult.success;
//     } on StripeException catch (e) {
//       final error = e.error;
//       // Corrected: Use the actual FailureCode enum values
//       if (error.code == FailureCode.Canceled) {
//         print('Payment was canceled by user');
//         return PaymentResult.canceled;
//       } else {
//         print('Payment failed: ${error.localizedMessage}');
//         return PaymentResult.failed;
//       }
//     } catch (e) {
//       print('Unexpected error during payment: $e');
//       return PaymentResult.failed;
//     }
//   }
//
//   Future<Map<String, String>?> _createPaymentIntent(int amount, String currency) async {
//     try {
//       final url = Uri.parse("https://api.stripe.com/v1/payment_intents");
//
//       final body = {
//         "amount": amount.toString(),
//         "currency": currency,
//         "payment_method_types[]": "card",
//         "capture_method": "automatic",
//         "metadata[app_name]": "EMDR",
//         "metadata[timestamp]": DateTime.now().millisecondsSinceEpoch.toString(),
//       };
//
//       final response = await http.post(
//         url,
//         headers: {
//           "Authorization": "Bearer ${AppConstants.Secret_key}",
//           "Content-Type": "application/x-www-form-urlencoded",
//         },
//         body: body,
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print("✅ Payment Intent Created Successfully");
//         print("🆔 ID: ${data['id']}");
//         print("💰 Amount: ${data['amount']}");
//         print("🔑 Client Secret: ${data['client_secret']}");
//
//         return {
//           "id": data['id'],
//           "client_secret": data['client_secret'],
//         };
//       } else {
//         print("❌ Failed to create payment intent: ${response.statusCode} - ${response.body}");
//         return null;
//       }
//     } catch (e) {
//       print("Error in _createPaymentIntent: $e");
//       return null;
//     }
//   }
//
//   PaymentResult _handleStripeError(StripeException e) {
//     final code = e.error.code ?? '';
//     final message = e.error.localizedMessage?.toLowerCase() ?? '';
//
//     // Check for cancel conditions - using proper FailureCode
//     if (code == FailureCode.Canceled ||
//         message.contains('cancel') ||
//         message.contains('cancelled')) {
//       return PaymentResult.canceled;
//     }
//
//     // All other errors are treated as failed
//     return PaymentResult.failed;
//   }
//
//   Future<bool> confirmPaymentStatus(String paymentIntentId) async {
//     try {
//       final url = Uri.parse("https://api.stripe.com/v1/payment_intents/$paymentIntentId");
//
//       final response = await http.get(
//         url,
//         headers: {
//           "Authorization": "Bearer ${AppConstants.Secret_key}",
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['status'] == 'succeeded';
//       }
//       return false;
//     } catch (e) {
//       print("Error confirming payment status: $e");
//       return false;
//     }
//   }
//
//   // Add method to debug available payment methods
//   Future<void> debugPaymentMethods(String clientSecret) async {
//     try {
//       // Initialize payment sheet first
//       await _initializePaymentSheet(clientSecret);
//
//       // Check available payment methods
//       final paymentMethods = await Stripe.instance.presentPaymentSheet();
//       print("🎯 Available Payment Methods in UI: $paymentMethods");
//
//     } catch (e) {
//       print("Error debugging payment methods: $e");
//     }
//   }
//
//   // Check Amazon Pay availability
//   Future<bool> isAmazonPayAvailable(String currency) async {
//     try {
//       // Amazon Pay availability by currency and region
//       final supportedCurrencies = {'USD', 'EUR', 'GBP', 'JPY'};
//       final isCurrencySupported = supportedCurrencies.contains(currency.toUpperCase());
//
//       print("💰 Amazon Pay available for currency $currency: $isCurrencySupported");
//       return isCurrencySupported;
//     } catch (e) {
//       print("Error checking Amazon Pay availability: $e");
//       return false;
//     }
//   }
// }
//
// class PaymentResponse {
//   final PaymentResult result;
//   final String? paymentIntentId;
//
//   PaymentResponse(this.result, {this.paymentIntentId});
// }
