// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class SocialLoginButton extends StatelessWidget {
//   final String icon;
//   final String label;
//   final VoidCallback onPressed;

//   const SocialLoginButton({
//     Key? key,
//     required this.icon,
//     required this.label,
//     required this.onPressed,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white.withOpacity(0.1),
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         elevation: 0,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Image.asset(icon, height: 24, width: 24),
//           const SizedBox(width: 8),
//           Text(
//             label,
//             style: GoogleFonts.inter(
//               color: Colors.white,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// } 