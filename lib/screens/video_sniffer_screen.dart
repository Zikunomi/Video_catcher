import 'package:Video_catcher/services/web_viewer_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/detected_video.dart';
import '../services/video_detector_service.dart';
import '../utils/https_util.dart';
import '../widget/detected_videos_sheet.dart';
import '../scripts/video_sniffer_script.dart';

class VideoSnifferScreen extends StatefulWidget{
  final String initialUrl;

  final Function(
    String url,
    String title,
    Map<String, String> headers,
  ) onDownloadTriggered;

  const VideoSnifferScreen({
    super.key,
    required this.initialUrl,
    required this.onDownloadTriggered
  });

  @override
  State<VideoSnifferScreen> createState() =>
    _VideoSnifferScreenState();
}


class _VideoSnifferScreenState extends State<VideoSnifferScreen>{
  late WebViewerService _webViewerService;
  final TextEditingController _addressController = TextEditingController();
  final VideoDetectorService _videoDetectorService = VideoDetectorService();

  final Set<DetectedVideo> _detectedVideos = {};

  @override
  void initState(){
    super.initState();

    _addressController.text = widget.initialUrl;

    _webViewerService = WebViewerService(
      initialUrl: widget.initialUrl,
      snifferScript: VideoSnifferScript.snifferScript,
      onUrlChanged: (url){
        _addressController.text = url;
      }, 
      onDetectedVideo: (message) {
        _onVideoDetected(message);
      }
      );
  }

  void _onVideoDetected(String url) {
    if (!mounted) return;

    final video = _videoDetectorService.processUrl(url);

    setState(() {
      _detectedVideos.add(video!);
    });

  }

  void _loadUrl(String value) {
    print('LOAD URL INPUT: $value');
    final url = HttpsUtil.normalize(value);
    print('LOAD URL NORMALIZED: $url');
    _webViewerService.loadUrl(url);
  }

  void _showDetectedVideos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DetectedVideosSheet(
          videos: _detectedVideos.toList(),

          onClear: () {
            setState(() {
              _detectedVideos.clear();
            });

            Navigator.pop(context);
          },

          onDownload: (video) {
            Navigator.pop(context);

            widget.onDownloadTriggered(
              video.url,
              'Video_Capturado_${DateTime.now().millisecondsSinceEpoch}',
              video.headers,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            hintText: 'Buscar o ingresar URL...',
            border: InputBorder.none,
          ),
          onSubmitted: _loadUrl,
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewerService.reload();
            },
          ),

          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.download_for_offline,
                ),
                onPressed: _showDetectedVideos,
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
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: WebViewWidget(
        controller: _webViewerService.webViewController,
      ),
    );
  }
}