// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:jonssony/utils/AppIcons/app_icons.dart';
//
// Widget _buildFloatingBottomNav(Color primaryColor) {
//   return Positioned(
//     bottom: 25,
//     left: 20,
//     right: 20,
//     child: Row(
//       children: [
//         Expanded(
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(40),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//               child: Container(
//                 height: 70,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(40),
//                   border: Border.all(color: Colors.white.withOpacity(0.2)),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _navItem(AppIcons.home, "Home", true, primaryColor),
//                     _navItem(AppIcons.library, "", false, primaryColor),
//                     _navItem(AppIcons.progress_nav, "", false, primaryColor),
//                     _navItem(AppIcons.profile, "", false, primaryColor),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Container(
//           height: 65,
//           width: 65,
//           decoration: BoxDecoration(
//               color: primaryColor,
//               shape: BoxShape.circle,
//               boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
//           ),
//           child: const Icon(Icons.add, color: Colors.white, size: 32),
//         ),
//       ],
//     ),
//   );
// }
//
// Widget _navItem(String iconPath, String label, bool isActive, Color activeColor) {
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//     decoration: isActive ? BoxDecoration(
//       color: activeColor.withOpacity(0.2),
//       borderRadius: BorderRadius.circular(25),
//     ) : null,
//     child: Row(
//       children: [
//         SvgPicture.asset(
//           iconPath,
//           height: 24,
//           colorFilter: ColorFilter.mode(isActive ? activeColor : Colors.black45, BlendMode.srcIn),
//         ),
//         if (isActive) const SizedBox(width: 6),
//         if (isActive) Text(label, style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 13)),
//       ],
//     ),
//   );
// }