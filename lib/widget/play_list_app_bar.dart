import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netease_cloud_music/widget/music_list_header.dart';

import 'flexible_detail_bar.dart';

/// 播放列表的头部
class PlayListAppBarWidget extends StatelessWidget {
  // 扩展高度
  final double expandedHeight;
  // Appbar的中间内容部分
  final Widget content;
  // 背景图片
  final String backgroundImg;
  // 文字标题
  final String title;
  // 模糊度
  final double sigma;
  // 是否显示标题部分
  final bool showTitle;
  // 圆角头部内容
  final Widget listHeader;
  // 播放点击回调
  final VoidCallback playOnTap;
  // 歌曲数目
  final int count;

  PlayListAppBarWidget({
    @required this.expandedHeight,
    @required this.content,
    @required this.title,
    @required this.backgroundImg,
    this.sigma = 5,
    this.listHeader,
    this.showTitle = true,
    this.playOnTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      expandedHeight: expandedHeight,
      pinned: true,
      elevation: 0,
      brightness: Brightness.dark,
      iconTheme: IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      bottom: MusicListHeader(
        onTap: playOnTap,
        content: listHeader,
        count: count,
      ),
      flexibleSpace: FlexibleDetailBar(
        content: content,
        titleBackground: Container(
          color: Colors.black87,
        ),
        background: Stack(
          children: <Widget>[
            backgroundImg.startsWith('http')
                ? CachedNetworkImage(
              imageUrl: '$backgroundImg?param=200y200',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
                : Image.asset(
              backgroundImg,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaY: sigma,
                sigmaX: sigma,
              ),
              child: Container(
                color: Colors.black38,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          ],
        ),
      ),
    );
  }
}
