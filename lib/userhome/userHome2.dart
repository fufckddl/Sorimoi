import 'package:flutter/material.dart';

class RecordingHomeScreen extends StatefulWidget {
  const RecordingHomeScreen({super.key});

  @override
  State<RecordingHomeScreen> createState() => _RecordingHomeScreenState();
}

class _RecordingHomeScreenState extends State<RecordingHomeScreen> {
  int _selectedIndex = 1;

  List<String> categories = ['SSAFY 면접 준비', '졸업프로젝트 발표 대본'];

  Map<String, List<Map<String, String>>> scriptData = {
    'SSAFY 면접 준비': [
      {'name': '스크립트 1', 'score': '80.2'},
      {'name': '스크립트 2', 'score': '87.8'},
    ],
    '졸업프로젝트 발표 대본': [
      {'name': '스크립트 1', 'score': '68.7'},
      {'name': '스크립트 2', 'score': '71.9'},
    ],
  };

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
                  const Text('오늘의 소리를 녹음해보세요!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('카테고리를 선택하여 시작하세요',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCategorySelectorDialog(context),
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
                children: categories.map((category) {
                  return _fileCard(
                    title: category,
                    date: '2024-10-25',
                    scripts: scriptData[category] ?? [],
                    onDeleteCategory: () => _confirmDeleteCategory(category),
                    onDeleteScript: (scriptName) {
                      setState(() {
                        scriptData[category]?.removeWhere((s) => s['name'] == scriptName);
                      });
                    },
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

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 카테고리 이름 입력'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  categories.add(name);
                  scriptData[name] = [];
                });
                Navigator.pop(context);
                _showScriptTitleDialog(context, name);
              }
            },
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }

  void _showCategorySelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리를 선택하세요'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...categories.map((category) => ListTile(
                title: Text(category),
                onTap: () {
                  Navigator.pop(context);
                  _showFileTitleDialog(context, '', category);
                },
              )),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('새 카테고리 생성'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddCategoryDialog(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showScriptTitleDialog(BuildContext context, String category) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('스크립트 제목을 입력해주세요.'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              final scriptTitle = controller.text.trim();
              if (scriptTitle.isNotEmpty) {
                Navigator.pop(context);
                _showFileTitleDialog(context, scriptTitle, category);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showFileTitleDialog(BuildContext context, String scriptTitle, String category) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('파일 제목을 입력해주세요.'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              final fileTitle = controller.text.trim();
              if (fileTitle.isNotEmpty) {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/voiceRecognition',
                  arguments: {
                    'file': fileTitle,
                    'script': scriptTitle,
                    'category': category,
                  },
                );
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('카테고리 "$category"를 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              setState(() {
                categories.remove(category);
                scriptData.remove(category);
              });
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Widget _fileCard({
    required String title,
    required String date,
    required List<Map<String, String>> scripts,
    required VoidCallback onDeleteCategory,
    required void Function(String scriptName) onDeleteScript,
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
              GestureDetector(
                onTap: onDeleteCategory,
                child: const Icon(Icons.delete_outline, size: 18),
              ),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: double.parse(script['score']!) >= 80
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${script['score']}점',
                    style: TextStyle(
                      color: double.parse(script['score']!) >= 80
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => onDeleteScript(script['name']!),
                  tooltip: '스크립트 삭제',
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
//