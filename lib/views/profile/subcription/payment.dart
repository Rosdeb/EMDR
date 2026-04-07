import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/subscription_controller.dart';
import 'package:jonssony/views/home/my_homework.dart';

class CompletePaymentSheet extends StatefulWidget {
  const CompletePaymentSheet({super.key});

  @override
  State<CompletePaymentSheet> createState() => _CompletePaymentSheetState();
}

class _CompletePaymentSheetState extends State<CompletePaymentSheet> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  final _cardNumberFocus = FocusNode();
  final _expiryFocus = FocusNode();
  final _cvcFocus = FocusNode();

  bool _isLoading = false;
  bool _isSuccess = false;

  String? _cardError;
  String? _expiryError;
  String? _cvcError;

  static const Color _green = Color(0xFF4F7C5A);
  static const Color _lightBlue = Color(0xFFE8F4FD);
  static const Color _hintColor = Color(0xFF8A99AB);

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardNumberFocus.dispose();
    _expiryFocus.dispose();
    _cvcFocus.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  String _formatExpiry(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 3) {
      return '${digits.substring(0, 2)} / ${digits.substring(2, digits.length.clamp(0, 4))}';
    }
    return digits;
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      final raw = _cardNumberController.text.replaceAll(' ', '');
      if (raw.length != 16) {
        _cardError = 'Enter a valid 16-digit card number';
        valid = false;
      } else {
        _cardError = null;
      }

      final parts = _expiryController.text.split(' / ');
      if (parts.length != 2 ||
          parts[0].length != 2 ||
          parts[1].length != 2 ||
          int.tryParse(parts[0]) == null ||
          int.parse(parts[0]) < 1 ||
          int.parse(parts[0]) > 12) {
        _expiryError = 'Enter valid MM / YY';
        valid = false;
      } else {
        _expiryError = null;
      }

      if (_cvcController.text.length < 3) {
        _cvcError = 'Enter valid CVC';
        valid = false;
      } else {
        _cvcError = null;
      }
    });
    return valid;
  }

  Future<void> _handlePay() async {
    if (!_validate()) return;
    
    setState(() => _isLoading = true);
    
    final controller = Get.find<SubscriptionController>();
    final plan = controller.selectedPlanForCheckout.value;

    if (plan != null) {
      final success = await controller.subscribe(plan);
      if (success) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      // Fallback
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  void _reset() {
    setState(() {
      _isSuccess = false;
      _cardNumberController.clear();
      _expiryController.clear();
      _cvcController.clear();
      _cardError = null;
      _expiryError = null;
      _cvcError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _isSuccess ? _buildSuccess() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    final controller = Get.find<SubscriptionController>();
    final plan = controller.selectedPlanForCheckout.value;
    final planName = plan?['name'] ?? "Subscription Plan";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: _green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'Payment Successful!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Thank you for subscribing to $planName',
          style: const TextStyle(fontSize: 14, color: _hintColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MyHomeworkPri()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildForm() {
    final controller = Get.find<SubscriptionController>();
    final plan = controller.selectedPlanForCheckout.value;
    final planName = plan?['name'] ?? "Subscription Plan";
    final planPrice = plan != null ? "${plan['currency'] ?? '£'}${plan['price']}" : "£0";

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Complete Payment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5,
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 26, color: Colors.black87),
            ),
          ],
        ),

        const Divider(height: 32),

        /// Plan Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: _lightBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Billed monthly',
                    style: TextStyle(
                      fontSize: 14,
                      color: _hintColor,
                    ),
                  ),
                ],
              ),
              Text(
                '$planPrice/mo',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Card Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        /// Card Number
        _buildInputField(
          controller: _cardNumberController,
          focusNode: _cardNumberFocus,
          hint: 'Card number',
          prefixIcon: Icons.credit_card_outlined,
          errorText: _cardError,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
          ],
          onChanged: (_) => setState(() => _cardError = null),
        ),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInputField(
                controller: _expiryController,
                focusNode: _expiryFocus,
                hint: 'MM / YY',
                errorText: _expiryError,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ExpiryFormatter(),
                ],
                onChanged: (_) => setState(() => _expiryError = null),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInputField(
                controller: _cvcController,
                focusNode: _cvcFocus,
                hint: 'CVC',
                errorText: _cvcError,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (_) => setState(() => _cvcError = null),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        /// Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  disabledBackgroundColor: _green.withOpacity(0.6),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  'Pay $planPrice',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// Secure Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock_outline, size: 14, color: _hintColor),
            SizedBox(width: 6),
            Text(
              'Secured payment · SSL encrypted',
              style: TextStyle(fontSize: 12, color: _hintColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    IconData? prefixIcon,
    String? errorText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Focus(
      focusNode: focusNode,
      child: Builder(builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        return TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            errorText: errorText,
            errorStyle: const TextStyle(fontSize: 12),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey.shade500, size: 20)
                : null,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _green, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFFE74C3C), width: 2),
            ),
          ),
        );
      }),
    );
  }
}

/// Card Number Formatter: XXXX XXXX XXXX XXXX
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Expiry Formatter: MM / YY
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String text;
    if (digits.length >= 3) {
      text =
      '${digits.substring(0, 2)} / ${digits.substring(2, digits.length.clamp(0, 4))}';
    } else {
      text = digits;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}