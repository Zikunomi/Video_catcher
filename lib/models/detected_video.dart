class DetectedVideo {
  final String url;
  final String type;
  final Map<String, String> headers;

  DetectedVideo({required this.url, required this.type, required this.headers});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectedVideo &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}
