import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/comment.dart';
import '../models/boxes.dart';
import '../session_manager.dart';
import '../screens/detail_berita.dart';

class KomenPage extends StatefulWidget {
  const KomenPage({super.key});

  @override
  State<KomenPage> createState() => _KomenPageState();
}

class _KomenPageState extends State<KomenPage> {
  List<Comment> _userComments = [];
  String? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserComments();
  }

  Future<void> _loadUserComments() async {
    final user = await SessionManager.getCurrentUser();
    if (user != null) {
      final box = Hive.box<Comment>(HiveBoxes.comment);
      final comments = box.values.where((c) => c.userName == user).toList();
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _currentUser = user;
        _userComments = comments;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Komentar Saya',
          style: TextStyle(
            color: Colors.white, // Ubah warna teks menjadi putih
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00569F),
        iconTheme: const IconThemeData(color: Colors.white), // untuk icon back
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userComments.isEmpty
              ? const Center(child: Text('Belum ada komentar yang kamu buat.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _userComments.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final comment = _userComments[index];
                    return ListTile(
                      title: Text(comment.text),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.createdAt.toString().substring(0, 19),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailBeritaScrapePage(url: comment.beritaUrl),
                                ),
                              );
                            },
                            child: Text(
                              'Lihat berita',
                              style: const TextStyle(
                                color: Color(0xFF00569F),
                                decoration: TextDecoration.underline,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
} 