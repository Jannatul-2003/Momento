import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/bloc_provider.dart';
import 'package:momento/screens/about_us_page.dart';
import 'package:momento/screens/auth/forgot_password/forgot_password.dart';
import 'package:momento/screens/auth/login/jwt_token.dart';
import 'package:momento/screens/auth/login/login.dart';
import 'package:momento/screens/auth/signup/signup.dart';
import 'package:momento/screens/contact_us.dart';
import 'package:momento/screens/events/create_event.dart';
import 'package:momento/screens/events/event_home.dart';
import 'package:momento/screens/events/notifications/event_notification.dart';
import 'package:momento/screens/home.dart';
import 'package:momento/screens/home_structure.dart';
import 'package:momento/screens/onboarding/onboarding_screens.dart';
import 'package:momento/screens/profile/create_profile.dart';
import 'package:momento/screens/profile/page_selector.dart';
import 'package:momento/screens/profile/settings.dart';
import 'package:momento/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

late SharedPreferences prefs;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  print('Message Data: ${message.data}');
}

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Supabase.initialize(
    url: 'https://nlbwkaysyyfkqxyvftjs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5sYndrYXlzeXlma3F4eXZmdGpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU2MTgyMzcsImV4cCI6MjA1MTE5NDIzN30.BN3HO_6NVR1JQVtEd52b2VAoWc8UHdGXqy3-Dg390Rk',
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Title: ${message.notification?.title}');
  //   print('Body: ${message.notification?.body}');
  //   print('Data: ${message.data}');
  //   print('Android: ${message.notification?.android}');
  //   print('Apple: ${message.notification?.apple}');
  // });
  _initializeApp();
}

Future<void> _initializeApp() async {
  final prefs = await SharedPreferences.getInstance();
  final isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;
  final tokenValidator = TokenValidator();
  bool isValid = await tokenValidator.isTokenValid();
  final isLoggedIn = isValid;

  final notificationService = NotificationService(
    supabase: Supabase.instance.client,
    messaging: FirebaseMessaging.instance,
  );

  final String userId = prefs.getString('userId') ?? '';

  // Initialize when user logs in
  await notificationService.initialize(userId);

  FlutterNativeSplash.remove();
  runApp(MomentoApp(
      initialRoute: isOnboardingCompleted
          ? (isLoggedIn ? 'home_structure' : 'login')
          : 'onboarding'));
}

class MomentoApp extends StatelessWidget {
  final String initialRoute;

  const MomentoApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProviders.allBlocProviders,
      child: ScreenUtilInit(
        builder: (context, child) => MaterialApp(
          title: 'Momento',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          routes: {
            // 'entry': (context) => const EntryScreen(),
            'onboarding': (context) => const OnboardingScreen(),
            'login': (context) => const LoginScreen(),
            'signup': (context) => const SignUpScreen(),
            // 'signup_otp': (context) => const SignUpOtpVerification(),
            'forgot_password': (context) => const ForgotPassword(),
            'home': (context) => const HomeScreen(),
            'create_event': (context) => const CreateEventScreen(),
            'event_home': (context) => const EventHome(),
            // 'ticket_scanner': (context) => const QRScannerPage(),
            // 'guest_list': (context) => const GuestList(),
            // 'event_schedule': (context) => const EventSchedule(),
            'event_notification': (context) => const EventNotification(),
            'create_profile': (context) => const CreateProfilePage(),
            'home_structure': (context) => const HomeStructure(),
            'page_selector': (context) => const PageSelector(),
            'settingspage': (context) => const SettingsScreen(),
            'feedbackpage': (context) => const FeedbackPage(),
            //'todo_page': (context) => const ToDoPage(),
            'aboutuspage': (context) => AboutUsPage(),
          },
          initialRoute: initialRoute,
          //initialRoute: 'event_home',
        ),
      ),
    );
  }
}
