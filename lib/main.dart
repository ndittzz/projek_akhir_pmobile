import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Pastikan ini ada
import 'screens/welcome_page.dart';
import 'screens/home_page.dart';
import 'session_manager.dart';
import 'notification_manager.dart'; // <-- Pastikan file ini di-import

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotificationManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialPage() async {
    bool isLoggedIn = await SessionManager.isLoggedIn();
    return isLoggedIn ? const HomePage() : const WelcomePage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Berita',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Terjadi kesalahan: ${snapshot.error}')),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
