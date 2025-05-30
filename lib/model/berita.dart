class NewsItem {
  final String title;
  final String link;
  final String contentSnippet;
  final DateTime isoDate;
  final NewsImage image;

  NewsItem({
    required this.title,
    required this.link,
    required this.contentSnippet,
    required this.isoDate,
    required this.image,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      contentSnippet: json['contentSnippet'] ?? '',
      isoDate: DateTime.tryParse(json['isoDate'] ?? '') ?? DateTime.now(),
      image: json['image'] != null
          ? NewsImage.fromJson(json['image'])
          : NewsImage(small: '', large: ''),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'contentSnippet': contentSnippet,
      'isoDate': isoDate.toIso8601String(),
      'image': {
        'small': image.small,
        'large': image.large,
      },
    };
  }
}

class NewsImage {
  final String small;
  final String large;

  NewsImage({
    required this.small,
    required this.large,
  });

  factory NewsImage.fromJson(Map<String, dynamic> json) {
    return NewsImage(
      small: json['small'] ?? '',
      large: json['large'] ?? '',
    );
  }
}
