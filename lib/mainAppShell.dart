import 'package:Video_catcher/downloadDispatcher.dart';
import 'package:Video_catcher/sniffer.dart';
import 'package:flutter/material.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState(); 
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;
  final List<DownloadTask> _downloadTasks = [];
  final TextEditingController _urlController = TextEditingController();

  void _addNewTask (String url, String title, Map<String, String> headers) {
    final type = DownloadDispatcher.detectType(url);
    final task = DownloadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      url: url,
      type: type,
    );

    setState(() {
      _downloadTasks.add(task);
      _currentIndex = 2; // Switch to the download list tab
    });

    DownloadDispatcher.startDownload(
      task: task,
      headers: headers,
      onUpdate: (progress, status) {
        setState(() {
          task.progress = progress;
          task.status = status;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          //TAB 1: Sniffer Web
          VideoSnifferScreen(
      initialUrl: 'https://google.com',
      onDownloadTriggered: (url, title, headers) {
        _addNewTask(url, title, headers);
      }),
          //TAB 2: Quick Download
          _buildQuickDownload(),

          //TAB 3: Download List
          _buildDownloadList(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() =>_currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.language),
            label: 'Navegador',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.link),
            label: 'Pegar link',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Descargas',
          ),
      
        ],
      ),
    );
  }

  Widget _buildQuickDownload() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            groupId: Icon(Icons.video_library, size: 64, color: Colors.blue)),
            const SizedBox(height: 16),
            const Text('Pegar link de video', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'https://...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.content_paste),
              ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Iniciar descarga'),
                onPressed: () {
                  if (_urlController.text.isNotEmpty) {
                    _addNewTask(_urlController.text, 'Video ${_downloadTasks.length + 1}', {});
                    _urlController.clear();
                  }
                },
              )
        ],
      ),
    );
  }

  Widget _buildDownloadList() {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de descargas')),
      body: _downloadTasks.isEmpty
          ? const Center(child: Text('No hay descargas activas'))
          : ListView.builder(
              itemCount: _downloadTasks.length,
              itemBuilder: (context, index) {
                final task = _downloadTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical:6),
                  child: ListTile(
                    leading: Icon(_getIconForType(task.type)),
                    title: Text(task.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        LinearProgressIndicator(value: task.progress),
                        const SizedBox(height: 4),
                        Text('${task.status} (${(task.progress * 100).toStringAsFixed(0)}%)'),
                      ],
                    ),
                    trailing: task.progress == 1.0
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.pause),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIconForType(DownloadType type) {
    switch (type) {
      case DownloadType.youtube:
        return Icons.play_circle_fill;
      case DownloadType.directMP4:
        return Icons.stream;
      case DownloadType.hls:
        return Icons.movie;
    }
  }
}
