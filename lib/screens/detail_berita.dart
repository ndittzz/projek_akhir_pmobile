import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
//import 'package:shared_preferences/shared_preferences.dart';
import '../bookmark_service.dart';
import '../session_manager.dart';
import '../model/berita.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/comment.dart';
import '../models/boxes.dart';

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
  String? _currentUser;

  // Komentar
  final TextEditingController _commentController = TextEditingController();
  late Box<Comment> commentBox;
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _fetchNewsDetail();
    _checkBookmarkStatus();
    commentBox = Hive.box<Comment>(HiveBoxes.comment);
    _loadComments();
    SessionManager.getCurrentUser().then((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  void _loadComments() {
    setState(() {
      _comments = commentBox.values
          .where((c) => c.beritaUrl == widget.url)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  void _addComment(String text) async {
    final userName = await SessionManager.getCurrentUser() ?? 'Anonim';
    final comment = Comment(
      beritaUrl: widget.url,
      text: text,
      createdAt: DateTime.now(),
      userName: userName,
    );
    commentBox.add(comment);
    _commentController.clear();
    _loadComments();
  }

  void _deleteComment(int index) {
    final comment = _comments[index];
    commentBox.delete(comment.key);
    _loadComments();
  }

  void _editComment(int index, String oldText) async {
    final controller = TextEditingController(text: oldText);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Komentar'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Edit komentar...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final comment = _comments[index];
      comment.text = result;
      comment.save();
      _loadComments();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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

        // Tambahkan ini untuk debug
        print('Judul: $_title');
        print('Tanggal: $_date');
        print('Gambar: $_imageUrl');
        print('Isi: $_content');
        print('URL: ${widget.url}');
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
                      const SizedBox(height: 24),
                      const Text('Komentar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      _comments.isEmpty
                          ? const Text('Belum ada komentar.')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                final isOwner = _currentUser != null && comment.userName == _currentUser;
                                return ListTile(
                                  title: Text(comment.text),
                                  subtitle: Text(
                                    '${comment.userName} • ${comment.createdAt.toString().substring(0, 19)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  trailing: isOwner
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 20),
                                              onPressed: () => _editComment(index, comment.text),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 20),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Hapus Komentar'),
                                                    content: const Text('Yakin ingin menghapus komentar ini?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, false),
                                                        child: const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, true),
                                                        child: const Text('Hapus'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  _deleteComment(index);
                                                }
                                              },
                                            ),
                                          ],
                                        )
                                      : null,
                                );
                              },
                            ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(hintText: 'Tulis komentar...'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              if (_commentController.text.trim().isNotEmpty) {
                                _addComment(_commentController.text.trim());
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
