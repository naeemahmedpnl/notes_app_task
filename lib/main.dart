import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes_app/data/services/firebase_service.dart';
import 'package:notes_app/presentation/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'firebase_options.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/notes_provider.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/notes_repository.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final firebaseService = FirebaseService();
  await firebaseService.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(
        AppConstants.designWidth,
        AppConstants.designHeight,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            Provider<AuthRepository>(create: (_) => AuthRepository()),
            Provider<NotesRepository>(create: (_) => NotesRepository()),
            ChangeNotifierProvider<AuthProvider>(
              create: (context) => AuthProvider(context.read<AuthRepository>()),
            ),
            ChangeNotifierProvider<NotesProvider>(
              create: (context) =>
                  NotesProvider(context.read<NotesRepository>()),
            ),
          ],
          child: MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: ModernAppTheme.lightTheme,
            darkTheme: ModernAppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
