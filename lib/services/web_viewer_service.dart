import 'package:webview_flutter/webview_flutter.dart';

class WebViewerService {
  final WebViewController webViewController;
  //final TextEditingController _addressController = TextEditingController();
  //final VideoDetectorService _videoDetectorService = VideoDetectorService();

  WebViewerService({
    required String initialUrl,
    required String snifferScript,
    required void Function(String url) onUrlChanged,
    required void Function(String message) onDetectedVideo,
  }) : webViewController = WebViewController() {
    webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'VideoSniffer',
        onMessageReceived: (message) {
          onDetectedVideo(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            print('NAVIGATION REQUEST: ${request.url}');

            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            print('PAGE_STARTED: $url');
            onUrlChanged;
          },
          onPageFinished: (url) {
            print('PAGE_FINISHED: $url');
            webViewController.runJavaScript(snifferScript);
            //print('PAGE_FINISHED: $url');
          },
          onWebResourceError: (error) {
            print(
              'WEBVIEW ERROR: '
              '${error.errorCode} '
              '${error.description} '
              '${error.url}',
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));
  }

  Future<void> loadUrl(String url) {
    print('WEBVIEW LOAD REQUEST: $url');
    return webViewController.loadRequest(Uri.parse(url));
  }

  Future<void> reload() {
    return webViewController.reload();
  }

  Future<void> injectScript(String script) {
    return webViewController.runJavaScript(script);
  }
}
//onPageFinished: (url) {
//
//..loadRequest(Uri.parse(widget.initialUrl));

// Variable para almacenar la URL del video detectado sin ducplicados
//final Set<DetectedVideo> _detectedVideos = {};

//@override
//void initState() {
//super.initState();
//_addressController.text = widget.initialUrl;

//_webViewController = WebViewController()
