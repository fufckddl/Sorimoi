// ✅ audioRecognition.dart - 실시간 STT + 직접 WAV 저장 (B안)
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../breathingButton.dart';
import 'resultScreen.dart';
import 'analyzingAudioScreen.dart';

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
  Color borderColor = const Color(0xFF1E0E62);

  String tempText = '';
  String allText = '';
  Timer? finalTextTimer;

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

    _channel = WebSocketChannel.connect(Uri.parse('ws://43.200.24.193:5000/ws/stt'));
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
      borderColor = const Color(0xffCE2C31);
    });

    _navigateToNextScreen();
  }

  List<int> _buildWavFile(List<int> pcmData, int sampleRate, int numChannels) {
    const int byteRate = 16000 * 2 * 1; // sampleRate * bytesPerSample * channels
    final int dataLength = pcmData.length;
    final int totalLength = 44 + dataLength;

    final header = BytesBuilder();
    header.add(ascii.encode('RIFF'));
    header.add(_intToBytes(totalLength - 8, 4));
    header.add(ascii.encode('WAVE'));
    header.add(ascii.encode('fmt '));
    header.add(_intToBytes(16, 4));
    header.add(_intToBytes(1, 2)); // PCM format
    header.add(_intToBytes(numChannels, 2));
    header.add(_intToBytes(sampleRate, 4));
    header.add(_intToBytes(byteRate, 4));
    header.add(_intToBytes(2 * numChannels, 2)); // block align
    header.add(_intToBytes(16, 2)); // bits per sample
    header.add(ascii.encode('data'));
    header.add(_intToBytes(dataLength, 4));

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
          builder: (_) => AnalyzingFeedbackScreen(
            audioPath: audioPath!,
            transcript: allText.trim(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    _channel?.sink.close();
    _recordSub?.cancel();
    finalTextTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        SizedBox(
          height: 200,
          child: Center(
            child: BreathingButton(
              onPressed: _toggleRecording,
              borderColor: borderColor,
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
    );
  }
}