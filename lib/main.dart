import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/splash_page.dart';
import 'constants/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PickupCoffee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: AppColors.pickupGreen,
          secondary: AppColors.pickupYellow,
          surface: AppColors.pickupWhite,
          error: Colors.red,
          onPrimary: AppColors.pickupWhite,
          onSecondary: AppColors.pickupGrey,
          onSurface: AppColors.pickupGrey,
          onError: AppColors.pickupWhite,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFAFCB86),
        textTheme: GoogleFonts.jostTextTheme(),
        fontFamily: GoogleFonts.jost().fontFamily,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: AppColors.pickupGreyVeryLight,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pickupYellow,
            foregroundColor: AppColors.pickupGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.pickupGreen,
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
