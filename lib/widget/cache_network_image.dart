import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

List<Color> bgColors = [
  Color(0xffF5F5F5),
  Color(0xffFFFAFA),
  Color(0xffFFE4E1),
  Color(0xffFFF5EE),
  Color(0xffFFFFF0),
  Color(0xffF0FFF0),
  Color(0xffF0FFFF),
  Color(0xffFFF0F5),
  Color(0xffF8F8FF),
  Color(0xffF0F8FF),
  Color(0xffF0FFFF),
];
int imgCount = 0;

/// CachedNetworkImage 简单封装。顺序的浅背景色、错误图片、圆角图片、圆形图片
class CustomCacheNetworkImage extends StatelessWidget {
  final String imageUrl;
  final PlaceholderWidgetBuilder placeholder;
  final double width;
  final double height;
  final BoxFit fit;
  // 圆形
  final bool isCircle;
  // 圆角
  final BorderRadius borderRadius;

  CustomCacheNetworkImage({
    this.imageUrl,
    this.placeholder,
    this.width,
    this.height,
    this.fit,
    this.isCircle = false,
    this.borderRadius
  });

  @override
  Widget build(BuildContext context) {
    imgCount++;
    Widget cacheImage = CachedNetworkImage(
      imageUrl: imageUrl,
//      color: bgColors[imgCount % bgColors.length],
      errorWidget: (context, url, error) => Image.asset('images/image_error.png'),
      placeholder: placeholder ?? (context, url) => Container(color: bgColors[imgCount % bgColors.length]),
      width: width,
      height: height,
      fit: fit,
    );
    if (isCircle) {
      return ClipOval(
        child: cacheImage,
      );
    }
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: cacheImage,
      );
    }
    return cacheImage;
  }
}
