import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
//import 'package:shared_preferences/shared_preferences.dart';
import '../bookmark_service.dart';
import '../session_manager.dart';
import '../model/berita.dart';

// jika mau pakai icon svg rumah

class DetailBeritaScrapePage extends StatefulWidget {
  final String url;

  const DetailBeritaScrapePage({super.key, required this.url});

  @override
  State<DetailBeritaScrapePage> createState() => _DetailBeritaScrapePageState();
}

class _DetailBeritaScrapePageState extends State<DetailBeritaScrapePage> {
  String _title = '';
  String _content = '';
  String _imageUrl = '';
  String _date = '';
  //String _author = '';
  bool _isLoading = true;
  String? _error;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _fetchNewsDetail();
    _checkBookmarkStatus();
  }

  Future<void> _fetchNewsDetail() async {
    try {
      final response = await http.get(Uri.parse(widget.url));

      if (response.statusCode == 200) {
        dom.Document document = htmlParser.parse(response.body);

        // Ambil title dari meta tag og:title
        final titleMeta = document.querySelector('meta[property="og:title"]');
        // Ambil isi artikel per paragraf
        final contentElements =
            document.querySelectorAll('div.detail-text > p');
        // Ambil gambar utama dari meta og:image
        final imageMeta = document.querySelector('meta[property="og:image"]');
        // Ambil tanggal berita
        final dateElement = document.querySelector(
          'div.text-cnn_grey.text-sm.mb-4, div.text-cnn_grey.text-sm.mb-6',
        );

        // Ambil penulis jika ada
        //final authorElement = document.querySelector('div.author > a');
        // Ambil kategori (misal dari meta tag atau bisa kamu sesuaikan selector-nya)

        setState(() {
          _title = titleMeta?.attributes['content'] ?? 'Tidak ada judul';
          _content = contentElements.map((e) => e.text.trim()).join('\n\n');
          _imageUrl = imageMeta?.attributes['content'] ?? '';
          _date = dateElement?.text.trim() ?? '';
          //_author = authorElement?.text.trim() ?? 'CNN Indonesia';
          _isLoading = false;
        });
      } else {
        throw Exception(
            "Gagal mengambil data (Status code: ${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkBookmarkStatus() async {
    final username = await SessionManager.getCurrentUser();
    if (username != null) {
      final isBookmarked = await BookmarkService.isBookmarked(widget.url, username);
      setState(() {
        _isBookmarked = isBookmarked;
      });
    }
  }

  void _toggleBookmark() async {
    final username = await SessionManager.getCurrentUser();
    if (username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    if (_isBookmarked) {
      await BookmarkService.removeBookmark(widget.url, username);
    } else {
      final newsItem = NewsItem(
        title: _title,
        link: widget.url,
        contentSnippet: _content.length > 100
            ? _content.substring(0, 100) + '...'
            : _content,
        isoDate: DateTime.now(),
        image: NewsImage(
          small: _imageUrl,
          large: _imageUrl,
        ),
      );
      await BookmarkService.saveBookmark(newsItem, username);
    }

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked
            ? 'Berita ditambahkan ke bookmark'
            : 'Berita dihapus dari bookmark'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00569F),
        centerTitle: true,
        titleSpacing: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Colors.white), // panah putih
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'BeritaKu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white, // judul putih
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white, // bookmark putih
            ),
            tooltip: 'Bookmark',
            onPressed: _toggleBookmark,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(_imageUrl),
                        ),
                      const SizedBox(height: 12),

                      // Baris kategori dengan icon rumah kecil
                      // Row(
                      //   children: [
                      //     const Icon(Icons.home,
                      //         size: 20, color: Colors.blueGrey),
                      //     const SizedBox(width: 6),
                      //     // Text(
                      //     //   _category.isNotEmpty
                      //     //       ? _category
                      //     //       : '', // kosongkan kalau kategori kosong
                      //     //   style: const TextStyle(
                      //     //     fontSize: 14,
                      //     //     color: Colors.blueGrey,
                      //     //     fontWeight: FontWeight.w600,
                      //     //   ),
                      //     // ),
                      //   ],
                      // ),

                      const SizedBox(height: 12),

                      Text(
                        _title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_date',
                        style: const TextStyle(
                            fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _content,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
    );
  }
}
