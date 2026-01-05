import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/app_state.dart';
import 'screens/dashboard_screen.dart';
import 'theme/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Focus Lab',
            debugShowCheckedModeBanner: false,
            themeAnimationDuration: const Duration(milliseconds: 500),
            themeAnimationCurve: Curves.easeInOut,
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primaryGreen,
                primary: AppColors.primaryGreen,
                secondary: AppColors.accentStart,
                surface: Colors.white,
                background: AppColors.background,
              ),
              textTheme:
                  GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primaryGreen,
                brightness: Brightness.dark,
                primary: AppColors.primaryGreen,
                surface: const Color(0xFF1E1E1E),
                background: const Color(0xFF121212),
              ),
              textTheme:
                  GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
              ),
            ),
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
