// audio/audioUploader.dart

import 'dart:io';
import 'package:http/http.dart' as http;

class AudioUploader {
  static Future<String?> uploadAudioFile({
    required File audioFile,
    required String transcript,
    required String serverUrl,
  }) async {
    final formData = http.MultipartRequest(
      'POST',
      Uri.parse(serverUrl),
    );

    formData.files.add(http.MultipartFile.fromBytes(
      'file',
      await audioFile.readAsBytes(),
      filename: audioFile.path.split('/').last,
    ));

    formData.fields['transcript'] = transcript;

    try {
      final response = await formData.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        print('✅ 업로드 성공: ${responseBody.body}');
        return responseBody.body; // ✅ 서버 응답 반환
      } else {
        print('❌ 업로드 실패 [${response.statusCode}]: ${responseBody.body}');
        return null;
      }
    } catch (e) {
      print('❌ 업로드 중 예외 발생: $e');
      return null;
    }
  }
}
