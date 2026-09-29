
import 'package:Video_catcher/models/detected_video.dart';
import 'package:Video_catcher/widget/detected_video_tile.dart';
import 'package:flutter/material.dart';

class DetectedVideosSheet extends StatelessWidget {
  final List<DetectedVideo> videos;
  final VoidCallback onClear;
  final void Function(DetectedVideo video) onDownload;

  const DetectedVideosSheet({
    super.key,
    required this.videos,
    required this.onClear,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Videos Detectados (${videos.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: onClear,
                  //{
                  //setState(() => _detectedVideos.clear());
                  //Navigator.pop(context);
                  //},
                  child: const Text('Limpiar'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: videos.isEmpty
                  ? const Center(
                      child: Text('Reproduce un video para capturar su URL.'),
                    )
                  : ListView.builder(
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        return DetectedVideoTile(
                          video: video,
                          onDownload: () => onDownload(video),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
                          return ListTile(
                            leading: Icon(
                              video.type.contains('HLS')
                                  ? Icons.stream
                                  : Icons.movie,
                              color: Colors.indigoAccent,
                            ),

                            //title: Text(
                              //video.url,
                              //maxLines: 2,
                              //overflow: TextOverflow.ellipsis,
                            //),
                            
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
                                */
