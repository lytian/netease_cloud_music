import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netease_cloud_music/models/lyric.dart';
import 'package:netease_cloud_music/provider/play_songs_provider.dart';
import 'package:netease_cloud_music/utils/dio_utils.dart';
import 'package:netease_cloud_music/utils/utils.dart';
import 'package:netease_cloud_music/widget/lyric_widget.dart';
import 'package:volume/volume.dart';

typedef SeekCallback = Function(int milliseconds);

class LyricPage extends StatefulWidget {
  final PlaySongsProvider provider;
  final Function onTap; // 点击空白区域的回调事件

  LyricPage(this.provider, { this.onTap });

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

  Timer _dragEndTimer; // 拖动结束任务

  double curVol = 0;
  double maxVol = 10;

  @override
  void initState() {
    super.initState();
    songId = widget.provider.curSong.id;
    _getLyricData();
    _getMediaVolume();
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
    _dragEndTimer?.cancel();
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
  }

  /// 获取媒体音量属性
  void _getMediaVolume() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
    int cur = await Volume.getVol;
    int max = await Volume.getMaxVol;
    print('cur: $cur, max: $max');
    setState(() {
      this.curVol = cur.toDouble();
      this.maxVol = max.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildVolumeBar(),
        _buildLyricWidget(),
        _buildToolBar(),
      ],
    );

  }

  /// 开始下一行动画
  void changeLineAnim(int curLine, { bool isDrag = false, bool ignoreCur = true }) {
    if (ignoreCur && !isDrag && _lyricWidget.curLine == curLine) return;

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

  /// 构建音量控制器
  Widget _buildVolumeBar() {
    return Container(
      height: 20,
      margin: EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: <Widget>[
          Icon(Icons.volume_up, size: 18, color: Colors.grey,),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 1.5,
                activeTrackColor: Colors.white70,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: 3,
                ),
              ),
              child: Slider(
                value: curVol,
                onChanged: (data) async {
                  await Volume.setVol(data.round(), showVolumeUI: ShowVolumeUI.HIDE);
                  setState(() {
                    curVol = data;
                  });
                },
                min: 0,
                max: maxVol,
              ),
            ),
          )
        ]
      )
    );
  }

  /// 构建歌词
  Widget _buildLyricWidget() {
    return Expanded(
      child: Container(
        key: _key,
        margin: EdgeInsets.only(bottom: 12),
        child: _lyrics == null
            ? Center(
          child: Text(
            '歌词加载中...',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        )
            : GestureDetector(
            onTapDown: (e) {
              if (_lyricWidget.isDragging &&
                  e.localPosition.dy >= (_paintHeight / 2 - 20) &&
                  e.localPosition.dy <= (_paintHeight / 2 + 20)) {
                // 拖动状态下，点击中间的横条
                widget.provider.seekPlay(_lyricWidget.dragLineTime);
                setState(() {
                  _lyricWidget.isDragging = false;
                });
              } else {
                widget.onTap();
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
              _lyricWidget.offsetY += e.delta.dy;
            },
            onVerticalDragEnd: (e) {
              if (_lyricWidget.isDragging) {
                changeLineAnim(_lyricWidget.dragLine, isDrag: true);
              }
              if (_dragEndTimer != null) {
                _dragEndTimer.cancel();
                _dragEndTimer = null;
              }
              _dragEndTimer = Timer(Duration(seconds: 5), () {
                if (_lyricWidget.isDragging) {
                  // 5S过后还原状态
                  changeLineAnim(_lyricWidget.curLine, ignoreCur: false);
                  setState(() {
                    _lyricWidget.isDragging = false;
                  });
                }
              });
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
      )
    );
  }

  /// 构建操作栏
  Widget _buildToolBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {},
            child: Image.asset('images/icon_music_dynamic.png', height: 24,),
          ),
          GestureDetector(
            onTap: () {},
            child: Image.asset('images/icon_play_more.png', height: 38,),
          ),
        ],
      )
    );
  }
}
