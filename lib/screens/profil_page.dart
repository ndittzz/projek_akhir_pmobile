import 'package:flutter/material.dart';
import 'package:projek_akhir_mobile_adit/screens/komen_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bookmark_page.dart';
import 'tentang_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _selectedTabIndex = 0;

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka link')),
      );
    }
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: 3,
              width: 150,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 36, 186, 171)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title diklik')),
              );
            },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String imagePath,
    required String name,
    required String email,
    required String instagramUrl,
    required String linkedInUrl,
    required String whatsappUrl,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(imagePath),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          email,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Instagram'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _launchURL(instagramUrl);
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.work),
            title: const Text('LinkedIn'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _launchURL(linkedInUrl);
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('WhatsApp'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _launchURL(whatsappUrl);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab Menu
          Container(
            color: const Color(0xFF00569F),
            child: Row(
              children: [
                Expanded(child: _buildTabItem('Profil Pengguna', 0)),
                Expanded(child: _buildTabItem('Tools', 1)),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          // Konten Tab
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                // Tab 1: Profil Pengguna (2 anggota)
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildProfileCard(
                          imagePath: 'assets/images/anggota2.jpg',
                          name: 'Mohamad Risqi Aditiya',
                          email: 'mohamadrisqiaditiya@gmail.com',
                          instagramUrl: 'https://instagram.com/risqi.adt',
                          linkedInUrl:
                              'https://www.linkedin.com/in/mohamadrisqi',
                          whatsappUrl: 'https://wa.me/6289620877988',
                        ),
                        const SizedBox(height: 32),
                        _buildProfileCard(
                          imagePath: 'assets/images/Arif.jpg',
                          name: 'Arif Fathurrahman',
                          email: 'ariffathurrahman0@gmail.com',
                          instagramUrl: 'https://instagram.com/arif.fathur_',
                          linkedInUrl: 'https://www.linkedin.com/in/arif-fathurrahman/',
                          whatsappUrl: 'https://wa.me/6285601036974',
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab 2: Tools
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fitur Aplikasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildToolCard(
                              icon: Icons.bookmark,
                              title: 'Bookmark',
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const BookmarkPage()),
                                );
                              },
                            ),
                            _buildToolCard(
                              icon: Icons.edit,
                              title: 'Buat Berita',
                              color: Colors.green,
                            ),
                            _buildToolCard(
                              icon: Icons.article,
                              title: 'Lihat Komenku',
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const KomenPage()),
                                );
                              },
                            ),
                            _buildToolCard(
                              icon: Icons.info,
                              title: 'Tentang',
                              color: Colors.purple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const TentangPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
