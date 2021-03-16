import 'package:firelamp/widgets/spinner.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
// ...

class AppPhotoViewer extends StatefulWidget {
  AppPhotoViewer(this.files, {this.initialIndex});

  final List<ApiFile> files;
  final int initialIndex;

  @override
  _AppPhotoViewerState createState() => _AppPhotoViewerState();
}

class _AppPhotoViewerState extends State<AppPhotoViewer> {
  PageController _controller;
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex ?? 0;
    _controller = PageController(initialPage: widget.initialIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            child: PhotoViewGallery.builder(
              itemCount: widget.files.length,
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int i) {
                return PhotoViewGalleryPageOptions(
                  minScale: .3,
                  imageProvider: NetworkImage(widget.files[i].url),
                  initialScale: PhotoViewComputedScale.contained * 1,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.files[i].idx),
                );
              },
              loadingBuilder: (context, event) => Center(
                child: Spinner(valueColor: Colors.white),
              ),
              pageController: _controller,
              onPageChanged: (i) => setState(() => currentIndex = i),
            ),
          ),
          Container(
            child: IconButton(
                icon: Icon(Icons.close_rounded, color: Colors.redAccent, size: Space.xl),
                onPressed: () => Get.back()),
          ),
          if (currentIndex != 0)
            Positioned(
              bottom: (MediaQuery.of(context).size.height / 2) - Space.xl,
              // left: Space.md,
              child: IconButton(
                icon: Icon(Icons.arrow_left_rounded, color: Colors.white, size: Space.xxl),
                onPressed: () => _controller.previousPage(
                    duration: Duration(milliseconds: 500), curve: Curves.ease),
              ),
            ),
          if (currentIndex != widget.files.length - 1)
            Positioned(
              bottom: (MediaQuery.of(context).size.height / 2) - Space.xl,
              right: Space.md,
              child: IconButton(
                icon: Icon(Icons.arrow_right_rounded, color: Colors.white, size: Space.xxl),
                onPressed: () =>
                    _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease),
              ),
            ),
        ],
      ),
    );
  }
}
