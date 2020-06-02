import 'package:flutter/material.dart';
import 'package:netease_cloud_music/application.dart';
import 'package:netease_cloud_music/models/play_list_detail.dart';
import 'package:netease_cloud_music/models/song.dart';
import 'package:netease_cloud_music/pages/discover/play_song_page.dart';
import 'package:netease_cloud_music/provider/play_songs_provider.dart';
import 'package:netease_cloud_music/utils/dio_utils.dart';
import 'package:netease_cloud_music/widget/custom_future_builder.dart';
import 'package:netease_cloud_music/widget/flexible_detail_bar.dart';
import 'package:netease_cloud_music/widget/music_list_header.dart';
import 'package:netease_cloud_music/widget/play_bar.dart';
import 'package:provider/provider.dart';
import 'package:date_format/date_format.dart';

class DailyPage extends StatefulWidget {
  @override
  _DailyPageState createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  List _data = [];

  Future _getDailySongs() async {
    var data = await DioUtils.get('/recommend/songs');
    return data['recommend'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                elevation: 0,
                title: Text('每日推荐'),
                bottom: MusicListHeader(
                  onTap: () {
                    _playSongs(index: 0);
                  },
                  count: _data.length
                ),
                flexibleSpace: FlexibleDetailBar(
                  background: Image.asset('images/bg_daily.png', fit: BoxFit.cover,),
                  collapseMode: CollapseMode.pin,
                  content: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    margin: EdgeInsets.only(top: Application.statusBarHeight + 72),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.white, height: 1),
                                children: [
                                  TextSpan(text: formatDate(DateTime.now(), [dd]), style: TextStyle(fontSize: 32)),
                                  TextSpan(text: '/' + formatDate(DateTime.now(), [mm]), style: TextStyle(fontSize: 18))
                                ]
                              ),
                            ),
                            Text('根据你的音乐口味， 为你推荐好音乐', style: TextStyle(color: Colors.white, fontSize: 12),)
                          ],
                        ),
                        Container(
                          height: 28,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          margin: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.75),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text('历史日推 ', style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.2),),
                              Image.asset('images/vip.png', height: 13,)
                            ]
                          ),
                        )
                      ],
                    )
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: CustomFutureBuilder(
                  futureFunc: _getDailySongs,
                  builder: (context, data) {
                    data = data as List;
                    Future.delayed(Duration(milliseconds: 300), () {
                      if (mounted) {
                        setState(() {
                          _data = data;
                        });
                      }
                    });
                    return Consumer<PlaySongsProvider>(
                      builder: (context, model, child) {
                        return MediaQuery.removePadding(
                            removeTop: true,
                            context: context,
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return _buildMusicItem(data[index], index, model.curSong != null && model.curSong.id == data[index]['id']);
                                })
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          PlayBar()
        ],
      ),
    );
  }

  /// 播放音乐
  void _playSongs({int index, bool all = false }) {
    if (_data.isEmpty) return;

    // 播放音乐
    List<Song> songs = _data.map((track) => Song(
        track['id'],
        name: track['name'],
        artists: track['artists'].map((e) => e['name']).toList().join('/'),
        picUrl: track['album']['picUrl']
    )).toList();

    Provider.of<PlaySongsProvider>(context, listen: false).playSongs(songs, index: all ? 0 : index);
  }
  /// 构建单行音乐
  Widget _buildMusicItem(dynamic track, int index, bool playing) {
    String artists = (track['artists'] as List).map((e) => e['name']).toList().join('/');
    String album = track['album']['name'];
    String titleSub = '';
    List alias = track['alias'] as List;
    if (alias.isNotEmpty) {
      titleSub += ' (' + alias.join("/") + ')';
    }
    List<Widget> desChildren = [];
    if (track['copyright'] == 0) {
      // 独家
      desChildren.add(Image.asset('images/text_dujia.png', height: 10));
      desChildren.add(SizedBox(width: 4,));
    }
    desChildren.add(Expanded(
        child: Text(artists + ' - ' + album,
          style: TextStyle(color: Colors.grey, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
    ));

    return InkWell(
      onTap: () {
        if (playing) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PlaySongPage();
          }));
          return;
        }
        _playSongs(index: index);
      },
      child: Row(
        children: <Widget>[

          Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            child: playing
              ? Icon(Icons.volume_up, color: Colors.red, size: 20,)
              : ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(track['album']['picUrl'] + '?param=100y100', width: 40, height: 40,),
              )
          ),
          Expanded(
            child: Container(
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        children: [
                          TextSpan(text: track['name'], style: TextStyle(color: Colors.black87, fontSize: 15),),
                          TextSpan(text: titleSub, style: TextStyle(color: Colors.grey, fontSize: 15),)
                        ]
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 6),
                    child:Row(
                      children: desChildren,
                    ),
                  ),
                ],
              ),
            ),
          ),
          track['mv'] != 0
              ? InkWell(
            onTap: () {
              print('MV');
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: Image.asset('images/icon_video.png', height: 20,),
            ),
          )
              : Container(),
          InkWell(
            onTap: () {
              _showMusicTool();
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(6, 20, 12, 20),
              child: Image.asset('images/icon_more_vert.png', height: 18,),
            ),
          )
        ],
      ),
    );
  }
  /// 展示音乐操作栏
  void _showMusicTool() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )
        ),
        builder: (context) {
          return Container(
            height: 800,
            color: Colors.red,
          );
        }
    );
  }
}
