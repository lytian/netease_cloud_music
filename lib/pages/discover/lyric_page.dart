import 'dart:async';

import 'package:flutter/material.dart';
import 'package:netease_cloud_music/models/lyric.dart';
import 'package:netease_cloud_music/provider/play_songs_provider.dart';
import 'package:netease_cloud_music/utils/dio_utils.dart';
import 'package:netease_cloud_music/utils/utils.dart';
import 'package:netease_cloud_music/widget/lyric_widget.dart';

typedef SeekCallback = Function(int milliseconds);

class LyricPage extends StatefulWidget {
  PlaySongsProvider provider;

  LyricPage(this.provider);

  @override
  _LyricPageState createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> with TickerProviderStateMixin {
  int songId;
  List<Lyric> _lyrics; // 歌词列表
  GlobalKey _key = GlobalKey();
  double _paintHeight = 0;
  LyricWidget _lyricWidget;
  AnimationController _lyricOffsetYController;

//  Timer dragEndTimer; // 拖动结束任务
//  Function dragEndFunc;

  @override
  void initState() {
    super.initState();
    songId = widget.provider.curSong.id;
    _getLyricData();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getContainerHeight();
    });
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(LyricPage oldWidget) {
    if (songId != widget.provider.curSong.id) {
      _lyrics = null;
      songId = widget.provider.curSong.id;
      _getLyricData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _lyricOffsetYController?.dispose();
    super.dispose();
  }

  /// 网络获取歌词
  void _getLyricData() async {
    var data = await DioUtils.get('/lyric', queryParameters: {
      'id': songId
    });
    setState(() {
      _lyrics = Utils.formatLyric(data['lrc']['lyric']);
      _lyricWidget = LyricWidget(_lyrics, 0);
    });
  }

  /// 获取画板高度
  void _getContainerHeight() {
    _paintHeight = _key.currentContext.size.height;
    print(_paintHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      height: double.infinity,
      child: _lyrics == null
        ? Center(
          child: Text(
            '歌词加载中...',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        )
        : GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTapDown: (e) {
            // 拖动状态下，点击中间的横条
            if (_lyricWidget.isDragging &&
                e.localPosition.dy >= (_paintHeight / 2 - 20) &&
                e.localPosition.dy <= (_paintHeight / 2 + 20)) {
              widget.provider.seekPlay(_lyricWidget.dragLineTime);
              setState(() {
                _lyricWidget.isDragging = false;
              });
            }
          },
          onVerticalDragStart: (e) {
            if (!_lyricWidget.isDragging) {
              setState(() {
                _lyricWidget.isDragging = true;
              });
            }
          },
          onVerticalDragUpdate: (e) {
//            print(e);
            _lyricWidget.offsetY += e.delta.dy;
          },
          onVerticalDragEnd: (e) {
            if (_lyricWidget.isDragging) {
              changeLineAnim(_lyricWidget.dragLine, isDrag: true);
            }
          },
          child: StreamBuilder<String>(
            stream: widget.provider.curPositionStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var curTime = double.parse(snapshot.data.substring(0, snapshot.data.indexOf('-')));
                // 当前哪一行歌词
                int curLine  = Utils.findLyricIndex(curTime, _lyrics);
                if (!_lyricWidget.isDragging) {
                  changeLineAnim(curLine);
                }
                _lyricWidget.curLine = curLine;
                return CustomPaint(
                  size: Size.fromHeight(_paintHeight),
                  painter: _lyricWidget
                );
              }
              return Container();
            }
          )
        )
    );
  }

  /// 开始下一行动画
  void changeLineAnim(int curLine, { bool isDrag = false }) {
    if (_lyricWidget.curLine == curLine) return;

    // 未完成的情况下直接 stop 当前动画，做下一次的动画
    if (_lyricOffsetYController != null) {
      _lyricOffsetYController.stop();
    }
    // 初始化动画控制器，切换歌词时间为300ms，并且添加状态监听，
    // 如果为 completed，则消除掉当前controller，并且置为空。
    _lyricOffsetYController = AnimationController(
      vsync: this, duration: Duration(milliseconds: 300))
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lyricOffsetYController.dispose();
        _lyricOffsetYController = null;
      }
    });
    // 计算出来当前行的偏移量
    var end = _lyricWidget.computeScrollY(curLine) * -1;
    if (isDrag) {
      end += _lyricWidget.lyricPaints[0].height / 2;
    }
    // 起始为当前偏移量，结束点为计算出来的偏移量
    Animation animation = Tween<double>(begin: _lyricWidget.offsetY, end: end)
        .animate(_lyricOffsetYController);
    // 添加监听，在动画做效果的时候给 offsetY 赋值
    _lyricOffsetYController.addListener(() {
      _lyricWidget.offsetY = animation.value;
    });
    // 启动动画
    _lyricOffsetYController.forward();
  }
}
