import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(
            color: Colors.white, // Ubah warna teks menjadi putih
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00569F),
        iconTheme: const IconThemeData(color: Colors.white), // untuk icon back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/logos/bg-putih.png', // Ganti dengan path logo Anda
              height: 170,
              width: 170,
            ),
            //const SizedBox(height: 5),
            // const Text(
            //   'BeritaKu',
            //   style: TextStyle(
            //     fontSize: 28,
            //     fontWeight: FontWeight.bold,
            //     color: Color(0xFF00569F),
            //   ),
            // ),
            const SizedBox(height: 5),
            const Text(
              'Versi 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Aplikasi berita terkini yang menyajikan informasi aktual dari berbagai kategori berita terpercaya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // _buildInfoCard(
            //   icon: Icons.code,
            //   title: 'Dikembangkan oleh',
            //   subtitle: 'Mohamad Risqi Aditiya',
            // ),
            // const SizedBox(height: 20),
            // _buildInfoCard(
            //   icon: Icons.email,
            //   title: 'Email',
            //   subtitle: 'mohamadrisqiaditiya@gmail.com',
            //   onTap: () => _launchEmail(),
            // ),
            // const SizedBox(height: 20),
            // _buildInfoCard(
            //   icon: Icons.link,
            //   title: 'Website',
            //   subtitle: 'https://github.com/risqiadt',
            //   onTap: () => _launchURL('https://github.com/risqiadt'),
            // ),
            const SizedBox(height: 30),
            const Text(
              '© 2023 BeritaKu. All rights reserved.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: const Color(0xFF00569F)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:mohamadrisqiaditiya@gmail.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch email';
    }
  }
}
