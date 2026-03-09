import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:pj1/config/app_config.dart';
import '../breathingButton.dart';
import 'resultScreen.dart'; // ✅ 변경된 경로

class RecogAudio extends StatefulWidget {
  const RecogAudio({super.key});

  @override
  State<RecogAudio> createState() => _RecogAudioState();
}

class _RecogAudioState extends State<RecogAudio> {
  final AudioRecorder _recorder = AudioRecorder();
  WebSocketChannel? _channel;
  StreamSubscription<Uint8List>? _recordSub;
  List<int> pcmBytes = [];
  String? audioPath;
  bool isRecording = false;

  String tempText = '';
  String allText = '';
  Timer? finalTextTimer;

  String feedbackText = '';
  Color feedbackColor = const Color(0xFF1E0E62);

  final List<double> _recentVolumes = [];
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleRecording() async {
    if (!isRecording) {
      await _startRecording();
    } else {
      await _stopRecording();
    }
  }

  Future<void> _startRecording() async {
    print("🎙 STT + PCM 수집 시작");
    if (!await _recorder.hasPermission()) return;

    pcmBytes.clear();
    final dir = await getApplicationDocumentsDirectory();
    audioPath = '${dir.path}/my_recorded_audio.wav';

    _channel = WebSocketChannel.connect(AppConfig.websocketUri('/ws/stt'));
    print("🔌 WebSocket 연결됨");

    _channel!.stream.listen(
      (message) {
        print("📥 STT 응답: $message");
        setState(() => tempText = message);
        finalTextTimer?.cancel();
        finalTextTimer = Timer(const Duration(seconds: 1), () {
          setState(() {
            allText += '$tempText ';
            tempText = '';
          });
        });
      },
      onError: (error) => print("❌ WebSocket 오류: $error"),
      onDone: () => print("⚠️ WebSocket 종료됨"),
    );

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 32000,
      ),
    );

    _recordSub = stream.listen((data) {
      _channel?.sink.add(base64Encode(data));
      pcmBytes.addAll(data);
      _scheduleAnalyzeVolume(data);
    });

    setState(() => isRecording = true);
  }

  Future<void> _stopRecording() async {
    print("🛑 녹음 종료 및 WAV 파일 생성");
    await _recordSub?.cancel();
    await _recorder.stop();
    _channel?.sink.close();
    finalTextTimer?.cancel();

    final file = File(audioPath!);
    final wavBytes = _buildWavFile(pcmBytes, 16000, 1);
    await file.writeAsBytes(wavBytes);
    print("✅ WAV 파일 저장 완료: ${file.path} (${wavBytes.length} bytes)");

    setState(() {
      isRecording = false;
      feedbackColor = const Color(0xffCE2C31);
    });

    _navigateToNextScreen(); // ✅ 바로 ResultScreen으로 이동
  }

  void _scheduleAnalyzeVolume(Uint8List data) {
    if (_feedbackTimer?.isActive ?? false) return;
    _feedbackTimer = Timer(const Duration(milliseconds: 200), () {
      _analyzeVolume(data);
    });
  }

  void _analyzeVolume(Uint8List data) {
    final buffer = ByteData.sublistView(data);
    double sum = 0;
    for (int i = 0; i < buffer.lengthInBytes; i += 2) {
      final sample = buffer.getInt16(i, Endian.little);
      sum += sample * sample;
    }

    final rms = sqrt(sum / (buffer.lengthInBytes / 2));
    _recentVolumes.add(rms);
    if (_recentVolumes.length > 10) _recentVolumes.removeAt(0);

    final avgRms =
        _recentVolumes.reduce((a, b) => a + b) / _recentVolumes.length;

    setState(() {
      if (avgRms < 500) {
        feedbackText = '목소리가 너무 작아요 😪';
        feedbackColor = Colors.red;
      } else if (avgRms > 6000) {
        feedbackText = '목소리가 너무 커요 😲';
        feedbackColor = Colors.purple;
      } else {
        feedbackText = 'Good! 잘 하고 있어요! 😄👍';
        feedbackColor = Colors.green;
      }
    });
  }

  List<int> _buildWavFile(List<int> pcmData, int sampleRate, int numChannels) {
    const int byteRate = 16000 * 2 * 1;
    final int dataLength = pcmData.length;
    final header = BytesBuilder()
      ..add(ascii.encode('RIFF'))
      ..add(_intToBytes(44 + dataLength - 8, 4))
      ..add(ascii.encode('WAVE'))
      ..add(ascii.encode('fmt '))
      ..add(_intToBytes(16, 4))
      ..add(_intToBytes(1, 2))
      ..add(_intToBytes(numChannels, 2))
      ..add(_intToBytes(sampleRate, 4))
      ..add(_intToBytes(byteRate, 4))
      ..add(_intToBytes(2 * numChannels, 2))
      ..add(_intToBytes(16, 2))
      ..add(ascii.encode('data'))
      ..add(_intToBytes(dataLength, 4));
    return [...header.toBytes(), ...pcmData];
  }

  List<int> _intToBytes(int value, int byteCount) {
    final bytes = <int>[];
    for (int i = 0; i < byteCount; i++) {
      bytes.add((value >> (8 * i)) & 0xFF);
    }
    return bytes;
  }

  void _navigateToNextScreen() {
    if (audioPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            audioPath: audioPath!,
            transcript: allText.trim(),
            score: 0, // 아직 채점 전이므로 0
            feedback: '', // 아직 채점 전
          ),
        ),
      );
    }
  }

  Future<bool> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('음성 인식을 종료하시겠습니까?'),
        content: const Text('변경 사항이 저장되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('아니요'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('예'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  void dispose() {
    _recorder.dispose();
    _channel?.sink.close();
    _recordSub?.cancel();
    _feedbackTimer?.cancel();
    finalTextTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('음성 인식'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (await _showExitDialog()) {
              await _recordSub?.cancel();
              await _recorder.stop();
              _channel?.sink.close();
              finalTextTimer?.cancel();
              _feedbackTimer?.cancel();
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            feedbackText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Center(
              child: BreathingButton(
                onPressed: _toggleRecording,
                borderColor: feedbackColor,
                size: 180.0,
              ),
            ),
          ),
          if ((allText + tempText).trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  (allText + tempText).trim(),
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.start,
                  softWrap: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
