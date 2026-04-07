import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jonssony/controller/support_controller.dart';
import 'package:jonssony/widets/Custom_BackgroundDesign.dart';
import 'package:jonssony/widets/custom_appbar.dart';
import 'package:jonssony/utils/app_text.dart';

class SupportRequestScreen extends StatefulWidget {
  const SupportRequestScreen({super.key});

  @override
  State<SupportRequestScreen> createState() => _SupportRequestScreenState();
}

class _SupportRequestScreenState extends State<SupportRequestScreen> {
  final SupportController _controller = Get.put(SupportController());
  
  final TextEditingController _messageController = TextEditingController();
  String _selectedCategory = "Technical Issue";
  String _selectedPriority = "medium";

  final List<String> _categories = [
    "Technical Issue",
    "General Inquiry",
    "Billing",
    "App Bug",
    "Feedback"
  ];

  final List<Map<String, String>> _priorities = [
    {"label": "Low", "value": "low"},
    {"label": "Medium", "value": "medium"},
    {"label": "High", "value": "high"},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_messageController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a message.");
      return;
    }

    final success = await _controller.submitTicket(
      category: _selectedCategory,
      message: _messageController.text.trim(),
      priority: _selectedPriority,
    );

    if (success) {
      _messageController.clear();
      setState(() {
        _selectedCategory = "Technical Issue";
        _selectedPriority = "medium";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Stack(
          children: [
            BackgroundDesign(),
            Column(
              children: [
                Custom_AppBar(context, "Support"),
                const SizedBox(height: 10),
                TabBar(
                  indicatorColor: Color(0xFF4F7957),
                  labelColor: Color(0xFF4F7957),
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(text: "New Ticket"),
                    Tab(text: "My History"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildNewTicketTab(),
                      _buildHistoryTab(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewTicketTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Image.asset('assets/images/splash_log.png', height: 100),
          const SizedBox(height: 15),
          const AppText(
            "If you face any kind of problem with our service feel free to contact us.",
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 25),
          
          // Category Dropdown
          _buildDropdownLabel("Category"),
          _buildGlassDropdown<String>(
            value: _selectedCategory,
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => _selectedCategory = val!),
          ),
          const SizedBox(height: 15),

          // Priority Dropdown
          _buildDropdownLabel("Priority"),
          _buildGlassDropdown<String>(
            value: _selectedPriority,
            items: _priorities.map((p) => DropdownMenuItem(value: p['value'], child: Text(p['label']!))).toList(),
            onChanged: (val) => setState(() => _selectedPriority = val!),
          ),
          const SizedBox(height: 15),

          // Message Field
          _buildDropdownLabel("Message"),
          _buildGlassField(_messageController, "Describe your issue here...", maxLines: 5),
          
          const SizedBox(height: 30),
          Obx(() => SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _controller.isSubmitting.value ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F7957),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _controller.isSubmitting.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const AppText("Email to the Admin", color: Colors.white),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Obx(() {
      if (_controller.isLoadingTickets.value && _controller.userTickets.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF4F7957)));
      }

      if (_controller.userTickets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppText("No support tickets found.", color: Colors.black54),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _controller.fetchMyTickets(),
                child: const Text("Refresh"),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _controller.fetchMyTickets(),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _controller.userTickets.length,
          itemBuilder: (context, index) {
            final ticket = _controller.userTickets[index];
            return _buildTicketCard(ticket);
          },
        ),
      );
    });
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final String category = ticket['category'] ?? 'General';
    final String status = (ticket['status'] ?? 'pending').toString().toUpperCase();
    final String message = ticket['message'] ?? '';
    final String adminResponse = ticket['adminResponse'] ?? '';
    final String createdAt = ticket['createdAt'] != null 
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(ticket['createdAt']))
        : '';

    Color statusColor = Colors.orange;
    if (status == 'RESOLVED' || status == 'CLOSED') statusColor = const Color(0xFF4F7957);
    if (status == 'OPEN') statusColor = Colors.blue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(category, fontWeight: FontWeight.bold, fontSize: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(status, color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                AppText(createdAt, fontSize: 12, color: Colors.black54),
                const Divider(),
                AppText(message, fontSize: 14),
                if (adminResponse.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F7957).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText("Admin Response:", fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4F7957)),
                        const SizedBox(height: 4),
                        AppText(adminResponse, fontSize: 13),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppText(label, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildGlassDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4F7957)),
        ),
      ),
    );
  }

  Widget _buildGlassField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}