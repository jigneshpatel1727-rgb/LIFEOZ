import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YansiVoiceMemoryEntry {
  final String id;
  final DateTime createdAt;
  final String transcript;
  final String? audioPath;
  final String source;

  const YansiVoiceMemoryEntry({
    required this.id,
    required this.createdAt,
    required this.transcript,
    this.audioPath,
    this.source = 'voice',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'transcript': transcript,
        'audioPath': audioPath,
        'source': source,
      };

  factory YansiVoiceMemoryEntry.fromMap(Map<String, dynamic> map) =>
      YansiVoiceMemoryEntry(
        id: '${map['id'] ?? ''}',
        createdAt: DateTime.tryParse('${map['createdAt'] ?? ''}') ?? DateTime.now(),
        transcript: '${map['transcript'] ?? ''}',
        audioPath: map['audioPath']?.toString(),
        source: '${map['source'] ?? 'voice'}',
      );
}

/// Persistent bridge between Yansi's speech-to-text layer and the original
/// voice recording. Audio stays on-device in this layer; no upload is done.
class YansiVoiceMemory {
  static const _key = 'yansi_voice_memory_v1';
  final SharedPreferences prefs;
  final AudioRecorder _recorder;

  YansiVoiceMemory(this.prefs) : _recorder = AudioRecorder();

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> startRecording() async {
    if (!await _recorder.hasPermission()) {
      throw StateError('Microphone permission is required to record voice.');
    }
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/yansi_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
  }

  Future<String?> stopRecording() => _recorder.stop();

  Future<bool> get isRecording => _recorder.isRecording();

  Future<YansiVoiceMemoryEntry> saveTranscript({
    required String transcript,
    String? audioPath,
  }) async {
    final entry = YansiVoiceMemoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      transcript: transcript.trim(),
      audioPath: audioPath,
    );
    final entries = load();
    entries.insert(0, entry);
    final trimmed = entries.take(200).map((e) => e.toMap()).toList();
    await prefs.setString(_key, jsonEncode(trimmed));
    return entry;
  }

  List<YansiVoiceMemoryEntry> load() {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => YansiVoiceMemoryEntry.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> dispose() => _recorder.dispose();
}
