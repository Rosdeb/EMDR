import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/my_tests_controller.dart';
import 'package:jonssony/utils/app_text.dart';

class CategoryItemsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryItemsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final MyTestsController _controller = Get.find<MyTestsController>();

  @override
  void initState() {
    super.initState();
    _controller.fetchItemsByCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 150,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),
          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg_progress.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      if (_controller.isLoading.value && _controller.items.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (_controller.items.isEmpty) {
                        return const Center(child: AppText("No items found in this category"));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
                        itemCount: _controller.items.length,
                        itemBuilder: (context, index) {
                          final item = _controller.items[index];
                          return _itemCard(item);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: const Color(0xFF537E5D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 5,
        right: 15,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2E3E32), size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: AppText(
              widget.categoryName,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E3E32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  item['itemName'] ?? 'No Name',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                if (item['day'] != null)
                  AppText(
                    item['day'],
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                if (item['description'] != null && item['description'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item['description'],
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: item['isActive'] ?? true,
            onChanged: (val) {
              // Not implemented in backend patch yet or just local toggle
            },
            activeColor: const Color(0xFF537E5D),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final dayController = TextEditingController();
    final descController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const AppText("Add New Item", fontSize: 18, fontWeight: FontWeight.bold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Item Name")),
            TextField(controller: dayController, decoration: const InputDecoration(labelText: "Day (e.g. Wednesday)")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              await _controller.createItem(
                widget.categoryId,
                nameController.text,
                dayController.text,
                descController.text,
              );
              Get.back();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
