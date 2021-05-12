import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';

import './spinner.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  CachedImage(
    this.url, {
    this.width,
    this.height,
    this.onLoadComplete,
    this.fit = BoxFit.cover,
  });
  final String url;
  final double width;
  final double height;
  final Function onLoadComplete;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    // print('---> src: $url');
    if (url == null) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Icon(
          Icons.error,
          size: 64,
        ),
      );
    }
    return CachedNetworkImage(
      imageBuilder: (context, provider) {
        // execute your onLoad code here
        // print("Image has been loaded!");
        if (onLoadComplete != null) Timer(Duration(milliseconds: 100), () => onLoadComplete());
        // Return the image that has built by hand.
        return Image(image: provider, fit: fit);
      },
      imageUrl: url,
      placeholder: (context, url) => Spinner(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      width: width,
      height: height,
    );
  }
}
