import 'package:shared_preferences/shared_preferences.dart';
import 'model/berita.dart';
import 'dart:convert'; // INI YANG KURANG!

class BookmarkService {
  static const String _bookmarksKey = 'saved_bookmarks';

  // Menyimpan bookmark
  static Future<void> saveBookmark(NewsItem news) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();

    // Cek apakah sudah ada di bookmark
    if (!bookmarks.any((item) => item.link == news.link)) {
      bookmarks.add(news);
      await prefs.setString(_bookmarksKey, _encodeBookmarks(bookmarks));
    }
  }

  // Menghapus bookmark
  static Future<void> removeBookmark(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();

    bookmarks.removeWhere((item) => item.link == url);
    await prefs.setString(_bookmarksKey, _encodeBookmarks(bookmarks));
  }

  // Mendapatkan semua bookmark
  static Future<List<NewsItem>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_bookmarksKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final json = jsonDecode(jsonString) as List;
      return json.map((item) => NewsItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Mengecek status bookmark
  static Future<bool> isBookmarked(String url) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((item) => item.link == url);
  }

  // Helper untuk encode data
  static String _encodeBookmarks(List<NewsItem> bookmarks) {
    final jsonList = bookmarks.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }
}
