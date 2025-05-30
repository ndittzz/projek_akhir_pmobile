import 'package:flutter/material.dart';
import '../base_network.dart';
import '../model/berita.dart';
import 'detail_berita.dart';
import 'notifikasi_page.dart';
import '../notification_manager.dart';
import 'package:provider/provider.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _selectedCategoryIndex = 0;
  late Future<List<NewsItem>> _newsFuture;

  // List kategori untuk endpoint API (lowercase, sesuai backend)
  final List<String> categories = [
    "semua",
    "nasional",
    "internasional",
    "ekonomi",
    "olahraga",
    "teknologi",
    "hiburan",
    "gaya-hidup"
  ];

  // List nama kategori untuk tampil di UI dengan kapital di depan
  final List<String> categoryNames = [
    "Semua",
    "Nasional",
    "Internasional",
    "Ekonomi",
    "Olahraga",
    "Teknologi",
    "Hiburan",
    "Gaya Hidup"
  ];

  @override
  void initState() {
    super.initState();
    _newsFuture = _getNews();
    _showNewsUpdateNotification();
  }

// Di bagian yang menampilkan notifikasi baru, ganti dengan:
  void _showNewsUpdateNotification() {
    final notificationManager = context.read<NotificationManager>();
    if (notificationManager.notificationsEnabled) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          notificationManager.newNotification();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Berita baru telah tersedia!'),
              action: SnackBarAction(
                label: 'Lihat',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsPage()),
                  );
                },
              ),
            ),
          );
        }
      });
    }
  }

  Future<List<NewsItem>> _getNews() async {
    if (_selectedCategoryIndex == 0) {
      final rawList = await BaseNetwork.getAll();
      return rawList.map((e) => NewsItem.fromJson(e)).toList();
    } else {
      final category = categories[_selectedCategoryIndex];
      final rawList = await BaseNetwork.getByCategory(category);
      return rawList.map((e) => NewsItem.fromJson(e)).toList();
    }
  }

  void _refreshNews() {
    setState(() {
      _newsFuture = _getNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Tabs
          Container(
            color: const Color(0xFF00569F),
            padding: const EdgeInsets.only(left: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(categories.length, (index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                        _refreshNews();
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Text(
                            categoryNames[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          width: 60,
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
                  );
                }),
              ),
            ),
          ),
          const Divider(height: 1),

          // Main Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshNews();
              },
              child: FutureBuilder<List<NewsItem>>(
                future: _newsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final newsList = snapshot.data!;
                  if (newsList.isEmpty) {
                    return const Center(
                        child: Text("Tidak ada berita tersedia"));
                  }

                  // Ambil berita terbaru (diasumsikan urutan dari API sudah terurut dari yang terbaru)
                  final latestNews = newsList.first;
                  final otherNews = newsList.length > 1
                      ? newsList.sublist(
                          1, newsList.length > 3 ? 4 : newsList.length)
                      : [];
                  final moreNews =
                      newsList.length > 4 ? newsList.sublist(4) : [];

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Featured News (Latest)
                        _buildFeaturedNews(latestNews),

                        // Other News List
                        if (otherNews.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: otherNews
                                  .map((news) => _buildNewsItem(news))
                                  .toList(),
                            ),
                          ),

                        // More News Grid
                        if (moreNews.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Berita Lainnya",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  children: moreNews
                                      .map((news) => _buildGridNewsItem(news))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedNews(NewsItem news) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBeritaScrapePage(url: news.link),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.image.large.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  news.image.large,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "BERITA TERBARU",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    news.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.contentSnippet,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(NewsItem news) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBeritaScrapePage(url: news.link),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.image.small.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: Image.network(
                  news.image.small,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      news.contentSnippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridNewsItem(NewsItem news) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBeritaScrapePage(url: news.link),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.image.small.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  news.image.small,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news.contentSnippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
