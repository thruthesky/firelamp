import 'package:dio/dio.dart';
import 'package:firelamp/widgets/spinner.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class AppVideoViewer extends StatefulWidget {
  AppVideoViewer(this.files, {this.initialIndex});

  final List<ApiFile> files;
  final int initialIndex;

  @override
  _AppVideoViewerState createState() => _AppVideoViewerState();
}

class _AppVideoViewerState extends State<AppVideoViewer> {
  PageController _controller;
  int currentIndex;
  GlobalKey globalKey = GlobalKey();
  bool isLoding = false;

  VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex ?? 0;
    _controller = PageController(initialPage: currentIndex);
    initializePlayer();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    print('widget.files[$currentIndex].url: ${widget.files[currentIndex].url}');
    videoPlayerController = VideoPlayerController.network(widget.files[currentIndex].url);
    videoPlayerController.setLooping(true);

    await Future.wait([
      videoPlayerController.initialize(),
    ]);
    setState(() {
      isLoding = true;
    });
  }

  requestPermission() async {
    await [
      Permission.storage,
    ].request();
  }

  toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }

  saveVideo(String url) async {
    print(url);
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/temp.mp4";
    String fileUrl = url;
    await Dio().download(
      fileUrl,
      savePath,
      onReceiveProgress: (count, total) {
        print((count / total * 100).toStringAsFixed(0) + "%");
      },
    );
    final result = await ImageGallerySaver.saveFile(
      savePath,
    );
    print(result);
    toastInfo("동영상이 다운로드되었습니다.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoding
          ? Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.close_rounded, color: Colors.yellow, size: Space.xl),
                          onPressed: () => Get.back()),
                      Spacer(),
                      IconButton(
                          icon: Icon(Icons.download_rounded, color: Colors.yellow, size: Space.xl),
                          onPressed: () {
                            requestPermission();
                            saveVideo(widget.files[currentIndex].url);
                          }),
                    ],
                  ),
                ),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: videoPlayerController.value.aspectRatio,
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            VideoPlayer(videoPlayerController),
                            VideoProgressIndicator(videoPlayerController,
                                allowScrubbing: true,
                                colors: VideoProgressColors(playedColor: Colors.yellow)),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          videoPlayerController.value.isPlaying
                              ? Icons.pause
                              : Icons.play_circle_outline,
                          color:
                              videoPlayerController.value.isPlaying ? Colors.white30 : Colors.white,
                          size: 80,
                        ),
                        onTap: () {
                          setState(() {
                            videoPlayerController.value.isPlaying
                                ? videoPlayerController.pause()
                                : videoPlayerController.play();
                          });
                        }),
                    if (currentIndex != 0)
                      Positioned(
                        bottom: (MediaQuery.of(context).size.height / 2) - Space.xl,
                        // left: Space.md,
                        child: IconButton(
                          icon:
                              Icon(Icons.arrow_left_rounded, color: Colors.white, size: Space.xxl),
                          onPressed: () => _controller.previousPage(
                              duration: Duration(milliseconds: 500), curve: Curves.ease),
                        ),
                      ),
                    if (currentIndex != widget.files.length - 1)
                      Positioned(
                        bottom: (MediaQuery.of(context).size.height / 2) - Space.xl,
                        right: Space.md,
                        child: IconButton(
                          icon:
                              Icon(Icons.arrow_right_rounded, color: Colors.white, size: Space.xxl),
                          onPressed: () => _controller.nextPage(
                              duration: Duration(milliseconds: 500), curve: Curves.ease),
                        ),
                      ),
                  ],
                ),
              ],
            )
          : Spinner(),
    );
  }
}
