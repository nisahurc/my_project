import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_project/screens/Welcome/welcome_screen.dart';
import 'package:my_project/screens/friends_list_screen.dart';
import 'package:my_project/screens/home_screen.dart';
import 'package:my_project/screens/settings_screen.dart';
import 'package:my_project/screens/add_friend_screen.dart';
import 'package:my_project/screens/chart_screen.dart';  // ChartScreen importu
import 'constants.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('mybox'); // Hive kutusunu açıyoruz

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box('mybox');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        bool isDarkMode = box.get('isDarkMode', defaultValue: false);
        return MaterialApp(

          debugShowCheckedModeBanner: false,
          title: "Flutter App",
          theme: ThemeData.light(), // Light tema
          darkTheme: ThemeData.dark(), // Dark tema
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/welcome',
          routes: {
            '/': (context) => HomeScreen(),
            '/add_friend': (context) => AddFriendScreen(),
            '/settings': (context) => SettingsScreen(),
            '/welcome': (context) => WelcomeScreen(),
            '/friends_list': (context) => const FriendsListScreen(),
          },
        );
      },
    );
  }
}


