
import 'package:firelamp/widgets/spinner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageNetwork extends StatefulWidget {
  ImageNetwork(
    this.url, {
    this.width,
    this.height,
    @required this.onImageRenderComplete,
  }) : assert(url != null);

  final String url;
  final double width;
  final double height;
  final Function onImageRenderComplete;

  @override
  _ImageNetworkState createState() => _ImageNetworkState();
}

class _ImageNetworkState extends State<ImageNetwork> {
  bool _loading = true;
  Image _image;
  bool error = false;
  ImageStreamListener listener;

  @override
  void initState() {
    super.initState();
    _image = new Image.network(
      widget.url,
    );

    final ImageStream stream = _image.image.resolve(ImageConfiguration());
    listener = ImageStreamListener((ImageInfo info, bool syncCall) {
      setState(() {
        _loading = false;
        if (widget.onImageRenderComplete != null) {
          // print('completed!');
          widget.onImageRenderComplete();
          stream.removeListener(listener);
        }
      });
    }, onError: (_, __) {
      error = true;
    });
    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (error) return errorIcon();
    return _loading ? Spinner() : _image;
  }

  Widget errorIcon() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Icon(
        Icons.error,
        size: 64,
      ),
    );
  }
}
