import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:netease_cloud_music/application.dart';
import 'package:netease_cloud_music/models/song.dart';
import 'package:netease_cloud_music/pages/discover/lyric_page.dart';
import 'package:netease_cloud_music/provider/play_songs_provider.dart';
import 'package:netease_cloud_music/widget/bottom_sheet_play_list.dart';
import 'package:provider/provider.dart';
import 'package:date_format/date_format.dart';

/// 音乐播放页面
class PlaySongPage extends StatefulWidget {

  @override
  _PlaySongPageState createState() => _PlaySongPageState();
}

class _PlaySongPageState extends State<PlaySongPage> with TickerProviderStateMixin {

  int musicIndex = 0; // 0-音乐盒子界面   1-歌词提示界面
  AnimationController _coverController; // 封面旋转控制器
  AnimationController _stylusController; // 唱针旋转控制器

  @override
  void initState() {
    super.initState();
    _coverController = AnimationController(vsync: this, duration: Duration(seconds: 20));
    _stylusController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _coverController.addStatusListener((status) {
      // 转完一圈之后继续
      if (status == AnimationStatus.completed) {
        _coverController.reset();
        _coverController.forward();
      }
    });
  }

  @override
  void dispose() {
    _coverController.dispose();
    _stylusController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaySongsProvider>(builder: (context, provider, child) {
      Song curSong = provider.curSong;
      if (provider.curState == AudioPlayerState.PLAYING) {
        // 如果当前状态是在播放当中，则唱片一直旋转，
        // 并且唱针是移除状态
        _coverController.forward();
        _stylusController.reverse();
      } else {
        _coverController.stop();
        _stylusController.forward();
      }
      return Scaffold(
          body: Stack(
            children: <Widget>[
              // 背景高斯模糊
              Image.network(
                curSong.picUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fitHeight,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaY: 100,
                  sigmaX: 100,
                ),
                child: Container(
                  color: Colors.black38,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // AppBar
              _buildAppBar(curSong),
              // body
              Container(
                margin: EdgeInsets.only(top: kToolbarHeight + Application.statusBarHeight),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {
                            if(musicIndex == 0){
                              musicIndex = 1;
                            }else{
                              musicIndex = 0;
                            }
                          });
                        },
                        child: IndexedStack(
                          index: musicIndex,
                          children: <Widget>[
                            _buildMusicBox(curSong),
                            LyricPage(provider, onTap: () {
                              setState(() {
                                if(musicIndex == 0){
                                  musicIndex = 1;
                                }else{
                                  musicIndex = 0;
                                }
                              });
                            },),
                          ],
                        ),
                      ),
                    ),
                    _buildPlayProgress(provider),
                    _buildMusicBtnGroup(provider)
                  ],
                ),
              ),
            ],
          )
      );
    });
  }

  /// 构建标题栏
  Widget _buildAppBar(Song song) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 28,
            child: song.name.length <=12
                ? Text(song.name)
                : Marquee(
              text: song.name,
              startPadding: 16,
              blankSpace: 120,
            ),
          ),
          Text(song.artists + '  >', style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.normal
          ),)
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {},
        )
      ],
    );
  }
  /// 构建音乐盒子
  Widget _buildMusicBox(Song song) {
    return Stack(
      children: <Widget>[
        // 封面
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(top: 110),
            child: RotationTransition(
              turns: _coverController,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 256,
                    height: 256,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.1),
                      borderRadius: BorderRadius.circular(260),
                    ),
                  ),
                  Image.asset('images/bet.png', width: 250, height: 250,),
                  ClipOval(
                    child: Image.network('${song.picUrl}?param=400y400', width: 166, height: 166,),
                  )
                ],
              ),
            ),
          ),
        ),
        // 唱针
        Align(
          alignment: Alignment(105 / Application.screenWidth, -0.99),
          child: RotationTransition(
            turns: Tween<double>(begin: 0, end: -0.08).animate(_stylusController),
            alignment: Alignment(-1 + 90 / 293, -1 + 90 / 504),
            child: Image.asset('images/bgm.png', width: 105, height: 180,),
          ),
        ),
        // 操作栏
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
//            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 32),
            margin: EdgeInsets.only(bottom: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Image.asset('images/icon_play_like.png', height: 40,),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Image.asset('images/icon_play_download.png', height: 40,),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Image.asset('images/icon_play_ring.png', height: 40,),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Image.asset('images/icon_play_comment.png', height: 40,),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Image.asset('images/icon_play_more.png', height: 40,),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
  /// 构建进度条
  Widget _buildPlayProgress(PlaySongsProvider provider) {
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: StreamBuilder<String>(
        stream: provider.curPositionStream,
        builder: (context, snapshot) {
          double curTime = 0;
          String totalTimeStr = '0';
          String curTimeStr = '00:00';
          if (snapshot.hasData) {
            totalTimeStr = snapshot.data.substring(snapshot.data.indexOf('-') + 1);
            curTime = double.parse(snapshot.data.substring(0, snapshot.data.indexOf('-')));
            curTimeStr = formatDate(DateTime.fromMillisecondsSinceEpoch(curTime.toInt()), [nn, ':', ss]);
          }
          return Container(
            height: 20,
            child: Row(
              children: <Widget>[
                Text(
                  curTimeStr,
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
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
                      value: curTime,
                      onChanged: (data) {
                        provider.sinkProgress(data.toInt());
                      },
                      onChangeStart: (data) {
                        provider.pausePlay();
                      },
                      onChangeEnd: (data) {
                        provider.seekPlay(data.toInt());
                      },
                      min: 0,
                      max: double.parse(totalTimeStr),
                    ),
                  ),
                ),
                Text(
                  formatDate(DateTime.fromMillisecondsSinceEpoch(int.parse(totalTimeStr)), [nn, ':', 'ss']),
                  style: TextStyle(fontSize: 10, color: Colors.white38),
                ),
              ],
            ),
          );

        },
      ),
    );
  }
  /// 构建音乐播放按钮组
  Widget _buildMusicBtnGroup(PlaySongsProvider provider) {
    String modeImage = 'images/icon_play_loop.png';
    switch (provider.playMode) {
      case PlayMode.sequence:
        modeImage = 'images/icon_play_loop.png';
        break;
      case PlayMode.random:
        modeImage = 'images/icon_play_random.png';
        break;
      case PlayMode.single:
        modeImage = 'images/icon_play_single.png';
        break;
      case PlayMode.intelligence:
        modeImage = 'images/icon_play_heartbeat.png';
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 32),
      height: 68 + Application.bottomBarHeight,
      alignment: Alignment.topCenter,
      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                provider.changePlayMode();
              },
              child: Image.asset(modeImage, height: 40,),
            )
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                provider.prePlay();
              },
              child: Image.asset('images/icon_play_prev.png', height: 40,),
            )
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                provider.togglePlay();
              },
              child: Image.asset(provider.curState == AudioPlayerState.PLAYING ?  'images/icon_play_pause.png' : 'images/icon_play_play.png', height: 68,),
            )
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                provider.nextPlay();
              },
              child: Image.asset('images/icon_play_next.png', height: 40,),
            )
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                showBottomSheetPlayList(context);
              },
              child: Image.asset('images/icon_play_list.png', height: 40,),
            )
          ),
        ],
      ),
    );
  }
}
