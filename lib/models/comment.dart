import 'package:hive/hive.dart';
part 'comment.g.dart';

@HiveType(typeId: 1)
class Comment extends HiveObject {
  @HiveField(0)
  final String beritaUrl;

  @HiveField(1)
  String text;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final String userName;

  Comment({
    required this.beritaUrl, 
    required this.text, 
    required this.createdAt,
    required this.userName,
  });
} 