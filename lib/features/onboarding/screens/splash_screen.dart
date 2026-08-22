import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:yojana_mitra/core/constants/app_colors.dart';
import 'package:yojana_mitra/core/constants/app_sizes.dart';
import 'package:yojana_mitra/core/constants/app_strings.dart';

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
            Image.asset(
              'assets/images/app_logo.png',
              width: AppSizes.iconXL + 24,
              height: AppSizes.iconXL + 24,
              fit: BoxFit.contain,
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
                color: AppColors.textWhite.withValues(alpha: 
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