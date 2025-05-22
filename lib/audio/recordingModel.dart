// audio/recording_model.dart

class Recording {
  final String id;
  final String audioUrl;
  final String transcript;
  final String filename;
  final DateTime createdAt;

  Recording({
    required this.id,
    required this.audioUrl,
    required this.transcript,
    required this.filename,
    required this.createdAt,
  });

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      transcript: json['transcript'] ?? '',
      filename: json['filename'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audio_url': audioUrl,
      'transcript': transcript,
      'filename': filename,
      'created_at': createdAt.toIso8601String(),
    };
  }
}