import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_menu_page.dart';
import 'profil_page.dart';
import 'saran_page.dart';
import 'search_page.dart';
import 'notifikasi_page.dart';
import '../notification_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MainMenuPage(),
    ProfilPage(),
    SaranPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final NotificationManager notificationManager =
        context.watch<NotificationManager>();
    bool isMainMenu = _currentIndex == 0;

    return Scaffold(
      appBar: isMainMenu
          ? AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 12,
              backgroundColor: const Color(0xFF00569F),
              elevation: 1,
              title: const Text(
                "BeritaKu",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsPage()),
                        );
                      },
                    ),
                    if (notificationManager.hasUnreadNotifications)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchPage()),
                    );
                  },
                ),
              ],
            )
          : AppBar(
              title: Text(
                _currentIndex == 1 ? "Profil" : "Saran",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: Color(0xFF00569F),
            ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.white,
        backgroundColor: const Color(0xFF00569F),
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Saran'),
        ],
      ),
    );
  }
}
