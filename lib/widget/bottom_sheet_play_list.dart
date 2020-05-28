import 'dart:async';

import 'package:flutter/material.dart';
import 'package:netease_cloud_music/application.dart';
import 'package:netease_cloud_music/models/play_list_detail.dart';
import 'package:netease_cloud_music/models/song.dart';
import 'package:netease_cloud_music/provider/play_songs_provider.dart';
import 'package:netease_cloud_music/widget/custom_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import 'dart:math' as math;

enum _PlayListType {
  /// 历史播放歌单
  history,
  /// 上次播放歌单
  lastTime,
  /// 当前播放歌单
  current
}

class BottomSheetPlayList extends StatefulWidget {
  @override
  _BottomSheetPlayListState createState() => _BottomSheetPlayListState();
}

class _BottomSheetPlayListState extends State<BottomSheetPlayList> {
  final List<Widget> list = [];
  int curIndex = 0;
  TransformerPageController _pageController;


  @override
  void initState() {
    super.initState();
    initList();

    _pageController = TransformerPageController(
      initialPage: curIndex,
      loop: false,
      itemCount: list.length,
      viewportFraction: 0.92
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomPaint(
              size: Size((list.length * 7 + (list.length - 1) * 8 - 8).toDouble(), 16.0),
              painter: CustomDotPagination(
                itemCount: list.length,
                index: curIndex,
              ),
            ),
            Expanded(
              child: TransformerPageView(
                transformer: ScaleAndFadeTransformer(scale: 1),
                pageController: _pageController,
                index: curIndex,
                itemCount: list.length,
                viewportFraction: 0.92,
                onPageChanged: (index) {
                  setState(() {
                    curIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return list[index];
                },
              ),
            )
          ],
        )
    );
  }

  void initList() {
    // 判断有没有历史播放
    if (true) {
      list.add(_buildHistoryList());
    }
    // 判断有没有上次播放
    if (true) {
      list.add(_buildLastTimeList());
    }
    // 当前播放
    list.add(_buildCurrentPlayList());

    if (list.length > 0) {
      curIndex = list.length - 1;
    }
  }

  Widget _buildCurrentPlayList() {
    return Consumer<PlaySongsProvider>(
      builder: (context, provider, value) {
        return _buildPlayListContainer(provider.allSongs, type: _PlayListType.current, curId: provider.curSong?.id);
      },
    );

  }

  Widget _buildLastTimeList() {
    return _buildPlayListContainer([], type: _PlayListType.lastTime, source: '每日推荐');
  }

  Widget _buildHistoryList() {
    return _buildPlayListContainer([], type: _PlayListType.history, source: '歌单[我喜欢的音乐]');
  }

  Widget _buildPlayListContainer(List<Song> playList, {String source = '', _PlayListType type, int curId}) {
    String title;
    switch (type) {
      case _PlayListType.current:
        title = '当前播放';
        break;
      case _PlayListType.lastTime:
        title = '上次播放';
        break;
      case _PlayListType.history:
        title = '历史播放';
        break;
    }
    String modeImage = 'images/icon_play_loop.png';
    String modeText = '循环播放';
    switch (Provider.of<PlaySongsProvider>(context, listen: false).playMode) {
      case PlayMode.sequence:
        modeImage = 'images/icon_play_loop.png';
        modeText = '列表循环';
        break;
      case PlayMode.random:
        modeImage = 'images/icon_play_random.png';
        modeText = '随机播放';
        break;
      case PlayMode.single:
        modeImage = 'images/icon_play_single.png';
        modeText = '单曲循环';
        break;
      case PlayMode.intelligence:
        modeImage = 'images/icon_play_heartbeat.png';
        modeText = '心动模式';
        break;
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          // 头部
          SliverPersistentHeader(
            pinned: true,
            delegate: _BottomSheetHeaderDelegate(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(text: title, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                            TextSpan(text: type == _PlayListType.current ? '  (${playList.length})' : '', style: TextStyle(color: Colors.grey, fontSize: 14))
                          ]
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    /// 播放类型切换
                    type == _PlayListType.current
                        ? GestureDetector(
                            onTap: () {
                              Provider.of<PlaySongsProvider>(context, listen: false).changePlayMode();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Image.asset(modeImage, height: 20, color: Colors.grey, colorBlendMode: BlendMode.color),
                                Text(modeText, style: TextStyle(fontSize: 12, color: Colors.black87),)
                              ],
                            ),
                          )
                        : Text(source, style: TextStyle(color: Colors.grey, fontSize: 14),)
                  ],
                ),
              ),
            ),
          ),
          // 列表
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              Song song = playList[index];
              List<Widget> children = [];
              if (curId != null && song.id == curId) {
                children.add(Icon(Icons.volume_up, color: Colors.red, size: 16,));
                children.add(SizedBox(width: 6,));
              }
              children.add(Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(height: 1),
                    children: [
                      TextSpan(text: song.name, style: TextStyle(color: curId != null && song.id == curId ? Colors.red : Colors.black87, fontSize: 15)),
                      TextSpan(text: ' - ' + song.artists, style: TextStyle(color: curId != null && song.id == curId ? Colors.red :Colors.grey, fontSize: 13))
                    ]
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ));

              if (curId != null && song.id == curId) {
                children.add(Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xffd0d0d0), width: 0.5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Text('播放来源', style: TextStyle(color: Colors.black87, fontSize: 11, height: 1),),
                ));
              }

              if (type == _PlayListType.current) {
                children.add(Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Provider.of<PlaySongsProvider>(context, listen: false).removeSong(index);
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(12, 14, 0, 14),
                      margin: EdgeInsets.only(left: 6),
                      child: Icon(Icons.close, size: 18, color: Colors.grey,),
                    )
                  ))
                );
              }

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (type == _PlayListType.current) {
                      Provider.of<PlaySongsProvider>(context, listen: false).playIndex(index);
                    } else {
                      Provider.of<PlaySongsProvider>(context).playSongs(playList, index: index);
                    }
                  },
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: children
                      )
                  ),
                )
              );
            },
              childCount: playList.length),
          )
        ],
      ),
    );
  }
}

/// 分页提示器
class CustomDotPagination extends CustomPainter {
  // 数量
  final int itemCount;
  // 当前高亮
  final int index;
  // 默认颜色
  final Color inactiveColor;
  // 高亮颜色
  final Color activeColor;
  // 默认大小
  final double inactiveSize;
  // 当前大小
  final double activeSize;
  // 间距
  final double space;

  List<Paint> paints = [];

  CustomDotPagination({
    @required this.itemCount,
    @required this.index,
    this.inactiveColor,
    this.activeColor = Colors.white,
    this.inactiveSize = 7,
    this.activeSize = 7,
    this.space = 8
  }) {
    for (int i = 0; i < itemCount; i++) {
      paints.add(Paint()
        ..color = Color.fromRGBO(255, 255, 255, 0.4)
        ..strokeWidth = inactiveSize
        ..strokeCap = StrokeCap.round
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 从左往右布局
    double x = 0;
    double y = math.max(inactiveSize, activeSize) / 2; // y轴中线
    for (int i = 0; i < itemCount; i++) {
      if (index == i) {
        paints[i].color = activeColor;
        paints[i].strokeWidth = activeSize;
        canvas.drawCircle(Offset(x, y - activeSize / 2), activeSize / 2, paints[i]);
        x += activeSize + space;
      } else {
        canvas.drawCircle(Offset(x, y - inactiveSize / 2), inactiveSize / 2, paints[i]);
        x += inactiveSize + space;
      }
    }
  }

  @override
  bool shouldRepaint(CustomDotPagination oldDelegate) {
    return oldDelegate.index != index ||
     oldDelegate.itemCount != itemCount;
  }
}

/// 自定义的滚动过渡动画
class ScaleAndFadeTransformer extends PageTransformer {
  final double _scale;
  final double _fade;

  ScaleAndFadeTransformer({double fade: 0.3, double scale: 0.8})
      : _fade = fade,
        _scale = scale;

  @override
  Widget transform(Widget item, TransformInfo info) {
    double position = info.position;
    double scaleFactor = (1 - position.abs()) * (1 - _scale);
    double fadeFactor = (1 - position.abs()) * (1 - _fade) / 0.3;
    double opacity = (1 - position.abs()) > 0.3 ? 1 : (_fade + fadeFactor);
    double scale = _scale + scaleFactor;
    return new Opacity(
      opacity: opacity,
      child: new Transform.scale(
        scale: scale,
        child: item,
      ),
    );
  }
}

/// 自定义滚动头
class _BottomSheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  _BottomSheetHeaderDelegate({
    @required this.child,
  });

  final Widget child;

  @override
  double get minExtent => 80;

  @override
  double get maxExtent => 80;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_BottomSheetHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

/// 基于Navigator的弹窗
Future showBottomSheetPlayList(BuildContext context) {
  return showModalCustomBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    maxHeight: Application.screenHeight * 2 / 3,
    builder: (context) {
      return BottomSheetPlayList();
    }
  );
}