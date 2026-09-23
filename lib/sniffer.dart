import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoSnifferScreen extends StatefulWidget {
  final String initialUrl;
  final Function(String url, String title, Map<String, String> headers)
  onDownloadTriggered;

  const VideoSnifferScreen({
    super.key,
    required this.initialUrl,
    required this.onDownloadTriggered,
  });

  @override
  State<VideoSnifferScreen> createState() => _VideoSnifferScreenState();
}

class _VideoSnifferScreenState extends State<VideoSnifferScreen> {
  late final WebViewController _webViewController;
  final TextEditingController _addressController = TextEditingController();

  // Variable para almacenar la URL del video detectado sin ducplicados
  final Set<DetectedVideo> _detectedVideos = {};

  static const String _snifferScript = r'''
    (function(){
    if (window.__videoSnifferInstalled) return;
    window.__videoSnifferInstalled = true;

    
    const videoRegex = /\.(m3u8|mp4|webm|mpd|flv|avi|mov|wmv|mkv)(\?.*)?$/i;
    function report(url) {
      if (videoRegex.text(url) && !url.includes('.ts')){
        VideoSniffer.postMessage(url);
      }
    }

    const originalFetch = window.fetch;
    window.fetch = function(...args){
      try{ report(args[0].toString()); } catch (e){}
      return originalFetch.apply(this, args);
    };
    
    const originalOpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function(method, url){
      try { report(url.toString()); } catch (e) {}
      return originalOpen.apply(this, arguments)
    };

    function scanNode(node) {
      if (node.tagName === 'VIDEO' || node.tagName === 'SOURCE'){
        if (node.src) report(node.src);      
      }
      if (node.querySelectorAll) {
        node.querySelectorAll('video, source').forEach(el => {
          if (el.src) report (el.src);        
        });
      }
    }

    scanNode(document.documentElement);

    const observer = new MutationObserver(mutations => {
      mutations.forEach(m =>{
        m.addedNodes.forEach(node => {
          if (node.nodeType === 1) scanNode (node);
        });
      });
    });
    
    observer.observe(document.documentElement, { childList: true, subtree: true});
  })();
  ''';

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.initialUrl;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'VideoSniffer',
        onMessageReceived: (JavaScriptMessage message) {
          _checkAndAddUrl(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _addressController.text = url;
          },
          onPageFinished: (url) {
            _webViewController.runJavaScript(_snifferScript);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _checkAndAddUrl(String url) {
    if (!mounted) return;

    String type = 'MP4';
    if (url.contains('.m3u8')) type = 'HLS (.m3u8)';
    if (url.contains('.mpd')) type = 'DASH (.mpd)';

    setState(() {
      // Nota: sin headers reales (Referer, Auth...), ya que la detección
      // ahora es desde JS y no a nivel de red nativa.
      _detectedVideos.add(
        DetectedVideo(url: url, type: type, headers: const {}),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            hintText: 'Buscar o ingresar Url...',
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            String url = value.trim();
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              url = 'https://www.google.com/search?q=$url';
            }
            _webViewController.loadRequest(Uri.parse(url));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _webViewController.reload(),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.download_for_offline),
                onPressed: () => _showDetectedVideosModal(context),
              ),
              if (_detectedVideos.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${_detectedVideos.length}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: WebViewWidget(controller: _webViewController),
    );
  }

  void _showDetectedVideosModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Videos Detectados ($_detectedVideos.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _detectedVideos.clear());
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _detectedVideos.isEmpty
                    ? const Center(
                        child: Text('Reproduce un video para capturar su URL.'),
                      )
                    : ListView.builder(
                        itemCount: _detectedVideos.length,
                        itemBuilder: (context, index) {
                          final video = _detectedVideos.elementAt(index);
                          return ListTile(
                            leading: Icon(
                              video.type.contains('HLS')
                                  ? Icons.stream
                                  : Icons.movie,
                              color: Colors.indigoAccent,
                            ),
                            title: Text(
                              video.url,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.download),
                              color: Colors.green,
                              onPressed: () {
                                Navigator.pop(context);
                                print('Descargando video: ${video.url}');
                                widget.onDownloadTriggered(
                                  video.url,
                                  'Video_Capturado_${DateTime.now().millisecondsSinceEpoch}',
                                  video.headers,
                                );

                                // Cerrar el modal antes de iniciar la descarga
                                // Aquí puedes implementar la lógica para descargar el video
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
