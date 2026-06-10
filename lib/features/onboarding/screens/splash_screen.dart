import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait 3 seconds, then move to next screen (we'll add navigation later)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Checks if screen is still active
        Navigator.pushReplacement(
          context,  
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen, // Deep green background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Icon(
              Icons.account_balance, // Temporary government icon
              size: AppSizes.iconXL + 24, // Extra large
              color: AppColors.primaryOrange, // Orange icon
            ),

            const SizedBox(
              height: AppSizes.paddingM,
            ), // Space between icon and text
            // App Name
            Text(
              AppStrings.appName, // 'Yojana Mitra'
              style: const TextStyle(
                fontSize: AppSizes.fontHeading,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),

            const SizedBox(height: AppSizes.paddingS), // Small space
            // Tagline
            Text(
              AppStrings.appTagline, // 'Aapka Saathi Sarkari Yojanaon Mein'
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color: AppColors.textWhite.withOpacity(
                  0.8,
                ), // Slightly faded white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
