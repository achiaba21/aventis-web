enum FileType {
  image,
  document,
  video,
  audio,
  other;

  static FileType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'image':
        return FileType.image;
      case 'document':
        return FileType.document;
      case 'video':
        return FileType.video;
      case 'audio':
        return FileType.audio;
      default:
        return FileType.other;
    }
  }

  String toJson() => name;

  static FileType fromJson(String json) => FileType.fromString(json);
}