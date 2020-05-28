import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:netease_cloud_music/application.dart';
import 'package:netease_cloud_music/models/song.dart';
import 'package:netease_cloud_music/pages/discover/play_song_page.dart';
import 'package:netease_cloud_music/provider/play_songs_provider.dart';
import 'package:netease_cloud_music/widget/bottom_sheet_play_list.dart';
import 'package:netease_cloud_music/widget/cache_network_image.dart';
import 'package:provider/provider.dart';

/// 页面底部 播放音乐的控制条
class PlayBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Consumer<PlaySongsProvider>(builder: (context, model, child) {
        if (model.allSongs.isEmpty) return Container();

        Song curSong = model.curSong;
        return Container(
          height: 50 + Application.bottomBarHeight,
          padding: EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200], width: 0.5)),
              color: Colors.white
          ),
          alignment: Alignment.topCenter,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PlaySongPage();
              }));
            },
            child: SizedBox(
              height: 50,
              child: Row(
                children: <Widget>[
                  CustomCacheNetworkImage(
                    imageUrl: curSong.picUrl + '?param=100y100',
                    isCircle: true,
                    width: 36,
                    height: 36,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(curSong.name, style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.3), maxLines: 1, overflow: TextOverflow.ellipsis,),
                          Text(curSong.artists, style: TextStyle(fontSize: 12, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                  _PlayButton(
                    assetPath: model.curState == AudioPlayerState.PLAYING
                        ? 'images/pause.png'
                        : 'images/play.png',
                    onTap: () {
                      if(model.curState == null){
                        model.play();
                      } else {
                        model.togglePlay();
                      }
                    },
                  ),
                  _PlayButton(
                    assetPath: 'images/list.png',
                    onTap: () {
                      showBottomSheetPlayList(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      })
    );
  }
}

class _PlayButton extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final Function onTap;

  _PlayButton({
    @required this.assetPath,
    this.width = 26,
    this.height = 26,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Image.asset(assetPath, width: width, height: width,),
        ),
        onTap: onTap,
      ),
    );
  }
}

