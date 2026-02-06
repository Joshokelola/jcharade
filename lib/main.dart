import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/home/home_screen.dart';
import 'screens/unsupported/unsupported_device_app.dart';
import 'utils/device_support.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final isMobile = DeviceSupport.isMobileOrTablet;
  runApp(
    ProviderScope(
      child: isMobile ? const MyApp() : const UnsupportedDeviceApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 mini as design base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'J-Headsup',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF008751), // Nigerian green
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            fontFamily: 'System',
          ),
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
