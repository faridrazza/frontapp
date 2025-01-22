class Video {
  final String id;
  final String videoLink;
  final String? thumbnail;
  final String? title;

  Video({
    required this.id,
    required this.videoLink,
    this.thumbnail,
    this.title,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'].toString(),
      videoLink: json['videoLink'],
      thumbnail: json['thumbnail'],
      title: json['title'],
    );
  }
} 