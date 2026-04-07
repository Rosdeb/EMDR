import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../utils/app_constant.dart';

enum PaymentResult { success, canceled, failed }

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<PaymentResponse> makePayment({
    required double amount,
    required String currency,
  }) async {
    try {
      if (amount <= 0) {
        print('❌ Amount must be greater than 0');
        return PaymentResponse(PaymentResult.failed);
      }

      final amountInCents = (amount * 100).toInt();
      // Stripe requires lowercase currency codes (e.g. "gbp", "usd")
      final lowerCurrency = currency.toLowerCase();

      print('💳 Creating payment intent: ${amountInCents} $lowerCurrency');

      final paymentIntentData = await _createPaymentIntent(amountInCents, lowerCurrency);

      if (paymentIntentData == null) {
        print('❌ Payment intent creation failed');
        return PaymentResponse(PaymentResult.failed);
      }

      final clientSecret = paymentIntentData['client_secret']!;
      final paymentIntentId = paymentIntentData['id']!;

      print('✅ Payment Intent Created: $paymentIntentId');

      await _initializePaymentSheet(clientSecret);
      final result = await _presentPaymentSheet();

      return PaymentResponse(result, paymentIntentId: paymentIntentId);

    } on StripeException catch (e) {
      print('Stripe Error: ${e.error.localizedMessage}');
      return PaymentResponse(_mapStripeError(e));
    } catch (e) {
      print('Unexpected Error in makePayment: $e');
      return PaymentResponse(PaymentResult.failed);
    }
  }

  Future<Map<String, String>?> _createPaymentIntent(int amount, String currency) async {
    try {
      final secretKey = AppConstants.Secret_key;
      if (secretKey.isEmpty) {
        print('❌ Stripe Secret Key is empty. Check your .env file.');
        return null;
      }

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'payment_method_types[]': 'card',
          'capture_method': 'automatic',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Intent ID: ${data['id']}');
        return {
          'id': data['id'],
          'client_secret': data['client_secret'],
        };
      } else {
        print('❌ Stripe API Error (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error in _createPaymentIntent: $e');
      return null;
    }
  }

  Future<void> _initializePaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'EMDR',
        style: ThemeMode.light,
        allowsDelayedPaymentMethods: false,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: Color(0xFF52734D),
          ),
          shapes: PaymentSheetShape(
            borderRadius: 12,
            borderWidth: 1.0,
          ),
        ),
      ),
    );
  }

  Future<PaymentResult> _presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print('✅ Payment completed successfully!');
      return PaymentResult.success;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        print('Payment canceled by user');
        return PaymentResult.canceled;
      }
      print('Payment sheet error: ${e.error.localizedMessage}');
      return PaymentResult.failed;
    } catch (e) {
      print('Unexpected error presenting payment sheet: $e');
      return PaymentResult.failed;
    }
  }

  PaymentResult _mapStripeError(StripeException e) {
    if (e.error.code == FailureCode.Canceled) {
      return PaymentResult.canceled;
    }
    return PaymentResult.failed;
  }

  Future<bool> confirmPaymentStatus(String paymentIntentId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId'),
        headers: {
          'Authorization': 'Bearer ${AppConstants.Secret_key}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'succeeded';
      }
      return false;
    } catch (e) {
      print('Error confirming payment status: $e');
      return false;
    }
  }
}

class PaymentResponse {
  final PaymentResult result;
  final String? paymentIntentId;

  PaymentResponse(this.result, {this.paymentIntentId});
}
