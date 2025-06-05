import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class RecordingHomeScreen extends StatefulWidget {
  const RecordingHomeScreen({super.key});

  @override
  State<RecordingHomeScreen> createState() => _RecordingHomeScreenState();
}

class _RecordingHomeScreenState extends State<RecordingHomeScreen> {
  int _selectedIndex = 1;

  List<Map<String, dynamic>> categoryList = [];
  Map<String, List<Map<String, dynamic>>> scriptData = {};
  Map<String, String> categoryDate = {};

  @override
  void initState() {
    super.initState();
    _fetchCategoryList();
  }

  Future<void> _fetchCategoryList() async {
    final response = await http.get(Uri.parse('http://43.200.24.193:5000/category'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        categoryList = List<Map<String, dynamic>>.from(data);
      });
      _fetchAudioList();
    }
  }

  Future<void> _fetchAudioList() async {
    final response = await http.get(Uri.parse('http://43.200.24.193:5000/audio'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      Map<String, List<Map<String, dynamic>>> newScriptData = {};
      Map<String, String> newCategoryDate = {};

      for (var audio in data) {
        final categoryId = audio['categoryId'];
        final category = categoryList.firstWhere(
              (c) => c['id'] == categoryId,
          orElse: () => {},
        );
        if (category.isNotEmpty) {
          final categoryName = category['categoryName'];
          final createdAt = audio['createdAt'] ?? '';
          String formattedDate = '';
          try {
            formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(createdAt));
          } catch (_) {}

          newCategoryDate[categoryName] = formattedDate;
          newScriptData[categoryName] = (newScriptData[categoryName] ?? [])..add({
            'id': audio['id'],
            'categoryId': audio['categoryId'],
            'name': audio['audioTitle']?.toString() ?? '',
            'score': audio['score'] is double ? audio['score'] : double.tryParse(audio['score'].toString()) ?? 0.0,
            'star': audio['star'] == true || audio['star'] == 1,
          });
        }
      }

      setState(() {
        scriptData = newScriptData;
        categoryDate = newCategoryDate;
      });
    }
  }

  Future<void> _toggleStar(int categoryId, int scriptId, String categoryName) async {
    final List<Map<String, dynamic>> scripts = scriptData[categoryName] ?? [];
    final int index = scripts.indexWhere((s) => s['id'] == scriptId);
    if (index == -1) return;

    final currentStar = scripts[index]['star'];
    final newStar = !currentStar;

    setState(() {
      scripts[index]['star'] = newStar;
      scriptData[categoryName] = List.from(scripts);
    });

    try {
      await http.put(
        Uri.parse('http://43.200.24.193:5000/audio/star/$scriptId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'star': newStar}),
      );
    } catch (e) {
      // 실패 시 롤백 가능 (선택)
      setState(() {
        scripts[index]['star'] = currentStar;
        scriptData[categoryName] = List.from(scripts);
      });
    }
  }

  Future<int?> _saveCategoryToServer(String name) async {
    try {
      final response = await http.post(
        Uri.parse('http://43.200.24.193:5000/category'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'categoryName': name,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _fetchCategoryList();
        return data['id'];
      }
    } catch (e) {
      print('카테고리 저장 실패: $e');
    }
    return null;
  }

  Future<bool> _saveAudioToServer(int categoryId, String fileTitle, String categoryName) async {
    try {
      final response = await http.post(
        Uri.parse('http://43.200.24.193:5000/audio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'categoryId': categoryId,
          'audioTitle': fileTitle,
          'content': '',
          'url': '',
          'score': 0.0,
          'createdAt': DateTime.now().toIso8601String(),
          'star': false,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchAudioList();
        Navigator.pushNamed(
          context,
          '/audioRecognition',
          arguments: {
            'file': fileTitle,
            'script': '',
            'category': categoryName,
          },
        );
        return true;
      }
    } catch (e) {
      print('audio 저장 실패: $e');
    }
    return false;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/voice');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profileHome');
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리를 선택하세요'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ 기존 카테고리 목록
                ...categoryList.map((category) => ListTile(
                  title: Text(category['categoryName']),
                  onTap: () {
                    Navigator.pop(context); // 닫고
                    _showFileTitleDialog(context, category['categoryName'], category['id']);
                  },
                )),
                const Divider(),

                // ✅ 새 카테고리 만들기 버튼
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('새 카테고리 만들기'),
                  onTap: () {
                    Navigator.pop(context); // 닫고
                    _showCreateNewCategoryDialog(context); // 새 카테고리 입력창 띄움
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateNewCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 카테고리 이름 입력'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final categoryId = await _saveCategoryToServer(name);
                if (categoryId != null) {
                  Navigator.pop(context); // 새 카테고리 창 닫고
                  _showFileTitleDialog(context, name, categoryId); // 파일 제목 입력
                }
              }
            },
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }

  void _showFileTitleDialog(BuildContext context, String category, int categoryId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('파일 제목을 입력해주세요.'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              final fileTitle = controller.text.trim();
              if (fileTitle.isNotEmpty) {
                Navigator.pop(context);
                await _saveAudioToServer(categoryId, fileTitle, category);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Widget _fileCard({
    required String title,
    required String date,
    required List<Map<String, dynamic>> scripts,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          ...scripts.map((script) => Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 6),
            child: Row(
              children: [
                const Text('•'),
                const SizedBox(width: 4),
                Expanded(child: Text(script['name'] ?? '')),
                IconButton(
                  icon: Icon(
                    script['star'] ? Icons.star : Icons.star_border,
                    color: script['star'] ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () {
                    final categoryId = script['categoryId'];
                    final audioId = script['id'];

                    if (categoryId is int && audioId is int) {
                      _toggleStar(categoryId, audioId, title);
                    } else {
                      print('❌ 오류: categoryId 또는 id가 null입니다.');
                    }
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: script['score'] >= 80
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${script['score']}점',
                    style: TextStyle(
                      color: script['score'] >= 80
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 40,
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => _showAddCategoryDialog(context),
            tooltip: '카테고리 생성',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  const Text('오늘의 소리를 녹음해보세요!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('카테고리를 선택하여 시작하세요', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('시작하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: scriptData.entries.map((entry) {
                  return _fileCard(
                    title: entry.key,
                    date: categoryDate[entry.key] ?? '',
                    scripts: entry.value,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.record_voice_over), label: '연습하기'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}
