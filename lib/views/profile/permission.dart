import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_text.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  bool isLocationEnabled = false;
  bool isNotificationEnabled = false;
  bool isCameraEnabled = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissions();
    }
  }


  Future<void> _checkAllPermissions() async {
    final locationStatus = await Permission.location.isGranted;
    final notificationStatus = await Permission.notification.isGranted;
    final cameraStatus = await Permission.camera.isGranted;

    setState(() {
      isLocationEnabled = locationStatus;
      isNotificationEnabled = notificationStatus;
      isCameraEnabled = cameraStatus;
    });
  }

  Future<void> _handlePermissionRequest(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted) {
      await openAppSettings();
    } else {

      final requestStatus = await permission.request();
      if (requestStatus.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
    _checkAllPermissions();
  }

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 170;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: appBarImageHeight,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),

          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                    image: DecorationImage(
                      image: AssetImage('assets/images/bg_profile.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Column(
                      children: [
                        _permissionTile(
                            Icons.location_on_outlined, "Location Access",
                            isLocationEnabled, () => _handlePermissionRequest(Permission.location)
                        ),
                        const SizedBox(height: 20),
                        _permissionTile(
                            Icons.notifications_none_outlined, "Allow Notifications",
                            isNotificationEnabled, () => _handlePermissionRequest(Permission.notification)
                        ),
                        const SizedBox(height: 20),
                        _permissionTile(
                            Icons.camera_alt_outlined, "Camera Access",
                            isCameraEnabled, () => _handlePermissionRequest(Permission.camera)
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 10, bottom: 10),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
          const AppText("Permission", fontSize: 20, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _permissionTile(IconData icon, String title, bool value, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2E3E32), size: 28),
              const SizedBox(width: 15),
              Expanded(child: AppText(title, fontSize: 16, fontWeight: FontWeight.w500)),
              Switch(
                value: value,
                onChanged: (val) => onTap(),
                activeColor: const Color(0xFF4F7957),
              ),
            ],
          ),
        ),
      ),
    );
  }
}