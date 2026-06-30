import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/department_filter_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'utils/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'services/auth_service.dart';
import 'services/event_service.dart';
import 'screens/event_details_screen.dart';


// void main() {
//   runApp(const MyApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

if (!kIsWeb) {
  await NotificationService().init();
}

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (_) => EventService(),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'Campus Events',

        theme: ThemeData(
          useMaterial3: true,

          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
          ),

          textTheme: GoogleFonts.poppinsTextTheme(),

          scaffoldBackgroundColor: AppColors.background,

          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
        ),

        // START SCREEN
        home: const LoginScreen(),

        // ROUTES
routes: {
  '/home': (context) => const HomeScreen(),
  '/register': (context) => const RegisterScreen(),
  '/calendar': (context) => const CalendarScreen(),
  '/department-filter': (context) => const DepartmentFilterScreen(),
  '/profile': (context) => const ProfileScreen(),

  '/event-details': (context) {
    final eventData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return EventDetailsScreen(eventData: eventData);
  },
},
      ),
    );
  }
}