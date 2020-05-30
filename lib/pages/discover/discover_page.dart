import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:netease_cloud_music/models/song.dart';
import 'package:netease_cloud_music/pages/discover/play_list_page.dart';
import 'package:netease_cloud_music/pages/discover/play_song_page.dart';
import 'package:netease_cloud_music/provider/play_songs_provider.dart';
import 'package:netease_cloud_music/utils/dio_utils.dart';
import 'package:netease_cloud_music/utils/number_utils.dart';
import 'package:netease_cloud_music/widget/cache_network_image.dart';
import 'package:netease_cloud_music/widget/custom_future_builder.dart';
import 'package:netease_cloud_music/widget/pagination_grid_view.dart';
import 'package:netease_cloud_music/widget/tab_view_wrapper.dart';
import 'package:provider/provider.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> with AutomaticKeepAliveClientMixin {
  List _categoryList = [
    {
      'title': '每日推荐',
      'icon': 'images/icon_daily.png',
      'text': DateTime.now().day.toString(),
      'onTap': () {}
    },
    {
      'title': '歌单',
      'icon': 'images/icon_playlist.png',
      'text': '',
      'onTap': () {}
    },
    {
      'title': '排行榜',
      'icon': 'images/icon_rank.png',
      'text': '',
      'onTap': () {}
    },
    {
      'title': '电台',
      'icon': 'images/icon_radio.png',
      'text': '',
      'onTap': () {}
    },
    {
      'title': '直播',
      'icon': 'images/icon_look.png',
      'text': '',
      'onTap': () {}
    }
  ];
  double _categoryWidth = 44;
  int _newType = 0; // 0-新歌   1-新碟

  @override
  void initState() {
    super.initState();
  }

  Future _getBanner() async {
    var data = await DioUtils.get('/banner/1');
    return data['banners'];
  }
  Future _getRecommendPlayList() async {
    var data = await DioUtils.get('/personalized', queryParameters: {
      'limit': 6
    });
    return data['result'];
  }
  Future _getRecommendSongs() async {
    var data = await DioUtils.get('/recommend/songs');
    return data['recommend'];
  }
  Future _getTopResource() async {
    var data = await DioUtils.get('/top/playlist/highquality', queryParameters: {
      'limit': 6
    });
    return data['playlists'];
  }
  Future _getNewSongs() async {
    var data = await DioUtils.get('/personalized/newsong');
    return data['result'];
  }
  Future _getNewAlbum() async {
    var data = await DioUtils.get('/album/newest', queryParameters: {
      'limit': 6
    });
    return data['albums'];
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TabViewWrapper(
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: <Widget>[
            _buildBanner(),
            _buildCategoryList(),
            _buildTitle('宝藏歌单，值得聆听'),
            _buildRecommendResource(),
            _buildTitle('一秒沦陷，华语精选', icon: Icons.play_arrow, moreText: '播放全部'),
            _buildRecommendSongs(),
            _buildTitle('网友精选碟'),
            _buildTopResource(),
            _buildTitle('',
                moreText: _newType == 1 ? '更多新碟' : '更多新歌',
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _newType = 0;
                        });
                      },
                      child: Text('新歌', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _newType == 0 ? Colors.black87 : Colors.grey
                      )),
                    ),
                    Container(
                      width: 1,
                      height: 16,
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _newType = 1;
                        });
                      },
                      child: Text('新碟', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _newType == 1 ? Colors.black87 : Colors.grey
                      )),
                    ),
                  ],
                )
            ),
            _newType == 1 ? _buildNewAlbum() : _buildNewSongs()
          ],
        ),
      )
    );
  }

  void goPlayListPage(int id) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PlayListPage(id);
    }));
  }

  // 构建通用的标题栏
  Widget _buildTitle(String title, { String moreText = '查看更多', Function onTap, IconData icon, Widget content}) {
    return Container(
      padding: EdgeInsets.only(top: 24, right: 16, bottom: 12, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          content ?? Text(title, style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),),
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Color(0xffd0d0d0),
                width: 0.5
              )
            ),
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  icon == null
                      ? Container()
                      : Icon(icon, size: 14, color: Colors.black87,),
                  Text(moreText, style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.1
                  ),)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  // 构建Banner
  Widget _buildBanner() {
    Map<String, Color> colorMap = {
      'red': Colors.red,
      'green': Colors.green,
      'blue': Colors.blue,
    };
    return CustomFutureBuilder(
      defaultHeight: 160,
      futureFunc: _getBanner,
      loadingWidget: Container(),
      builder: (context, data) {
        var bannerList = data;
        return SizedBox(
            height: 150,
            child: Swiper(
              autoplay: true,
              autoplayDelay: 5000,
              itemCount: bannerList.length,
              itemBuilder: (BuildContext context,int index){
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                          image: NetworkImage(bannerList[index]['imageUrl']),
                          fit: BoxFit.fill
                      )
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                              color: colorMap[bannerList[index]['titleColor']],
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6)
                              )
                          ),
                          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                          child: Text(bannerList[index]['typeTitle'], style: TextStyle(
                              color: Colors.white,
                              fontSize: 12
                          ),),
                        ),
                      )
                    ],
                  ),
                );
                Image.network(bannerList[index]['imageUrl'], fit: BoxFit.cover,);
              },
              pagination: SwiperPagination(
                  builder: DotSwiperPaginationBuilder(
                      size: 7,
                      activeSize: 7,
                      space: 3,
                      color: Color.fromRGBO(255, 255, 255, 0.5)
                  )
              ),
            )
        );
      },
    );
  }
  // 构建分类入口
  Widget _buildCategoryList() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categoryList.map((e) {
          return GestureDetector(
            onTap: e['onTap'],
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      width: _categoryWidth,
                      height: _categoryWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_categoryWidth / 2),
                        border: Border.all(color: Colors.black12, width: 0.5),
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFFFF8174),
                            Colors.red,
                          ],
                          center: Alignment(-1.7, 0),
                          radius: 1,
                        ),
                        color: Colors.red),
                    ),
                    Image.asset(
                      e['icon'],
                      width: _categoryWidth,
                      height: _categoryWidth,
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(e['text'], style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  child: Text(e['title'], style: TextStyle(color: Colors.black87, fontSize: 12)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  // 构建精选歌单
  Widget _buildRecommendResource() {
    return CustomFutureBuilder(
      defaultHeight: 164,
      futureFunc: _getRecommendPlayList,
      loadingWidget: Container(),
      builder: (context, data) {
        var recommendList = data;
        return SizedBox(
          height: 164,
          child: NotificationListener<OverscrollNotification>(
            onNotification: (notification) {
              notification.dispatch(context);
              return false;
            },
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendList.length > 6 ? 6 : recommendList.length,
                itemBuilder: (context, index) {
                  var item = recommendList[index];
                  return Container(
                      width: 120,
                      margin: EdgeInsets.only(left: index == 0 ? 16 : 4, right: index == recommendList.length - 1 ? 16 : 4),
                      child: GestureDetector(
                        onTap: () {
                          goPlayListPage(item['id']);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Stack(
                              alignment: Alignment.topRight,
                              children: <Widget>[
                                CustomCacheNetworkImage(
                                  imageUrl: item['picUrl'] + '?param=400y400',
                                  borderRadius: BorderRadius.circular(6),
                                  width: 120,
                                  height: 120,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Image.asset(
                                        'images/icon_triangle.png',
                                        width: 14,
                                        height: 14,
                                      ),
                                      Text(NumberUtils.amountConversion(item['playCount']), style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11
                                      ),)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(item['name'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            )
                          ],
                        ),
                      )
                  );
                }
            ),
          ),
        );
      }
    );
  }
  // 构建推荐歌曲
  Widget _buildRecommendSongs() {
    return CustomFutureBuilder(
      defaultHeight: 192,
      futureFunc: _getRecommendSongs,
      loadingWidget: Container(),
      builder: (context, data) {
        var recommendList = data;
        return Consumer<PlaySongsProvider>(
          builder: (context, model, child) {
            Song curSong = model.curSong;
            return PaginationGridView(
              height: 192,
              itemCount: recommendList.length > 12 ? 12 : recommendList.length,
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 16,
              childAspectRatio: 1 / 6.1,
              padding: EdgeInsets.symmetric(horizontal: 16),
              builder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (curSong != null && curSong.id == recommendList[index]['id']) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return PlaySongPage();
                      }));
                      return;
                    }
                    List<Map> data = (recommendList as List).cast();
                    List<Song> songs = [];
                    data.forEach((e) {
                      String artists = (e['artists'] as List).map((e) => e['name']).join('、');
                      songs.add(Song(e['id'], name: e['name'], artists: artists, picUrl: e['album']['picUrl']));
                    });
                    Provider.of<PlaySongsProvider>(context, listen: false).playSongs(songs, index: index);
                  },
                  child: Row(
                    children: <Widget>[
                      CustomCacheNetworkImage(
                        imageUrl: recommendList[index]['album']['picUrl'] + '?param=200y200',
                        width: 56,
                        height: 56,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        style: TextStyle(fontSize: 15, color: Colors.black87),
                                        children: [
                                          TextSpan(text: recommendList[index]['name']),
                                          TextSpan(text: ' - ' + recommendList[index]['artists'][0]['name'], style: TextStyle(fontSize: 12, color: Colors.grey, ),)
                                        ]
                                    )
                                ),
                                Text(recommendList[index]['reason'],
                                  style: TextStyle(fontSize: 12, color: Colors.grey, ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                      ),
                      curSong != null && curSong.id == recommendList[index]['id']
                      ? Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        child: Icon(Icons.volume_up, color: Colors.red, size: 21,),
                      )
                      : Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                                color: Color(0xffd0d0d0),
                                width: 0.5
                            )
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.play_arrow, color: Colors.red, size: 16,),
                      )
                    ],
                  ),
                );
              },
            );
          },
        );
      }
    );
  }
  // 构建网友精选碟
  Widget _buildTopResource() {
    return CustomFutureBuilder(
        defaultHeight: 164,
        futureFunc: _getTopResource,
        builder: (context, data) {
          var topList = data;
          return SizedBox(
              height: 164,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: topList.length > 6 ? 6 : topList.length,
                  itemBuilder: (context, index) {
                    var item = topList[index];
                    return Container(
                        width: 120,
                        margin: EdgeInsets.only(left: index == 0 ? 16 : 4, right: index == topList.length - 1 ? 16 : 4),
                        child: GestureDetector(
                          onTap: () {
                            goPlayListPage(item['id']);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Stack(
                                alignment: Alignment.topRight,
                                children: <Widget>[
                                  Container(
                                    width: 120,
                                    height: 120,
                                    margin: EdgeInsets.only(bottom: 3),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                            image: NetworkImage(item['coverImgUrl'] + '?param=400y400'),
                                            fit: BoxFit.cover
                                        )
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Image.asset(
                                          'images/icon_triangle.png',
                                          width: 14,
                                          height: 14,
                                        ),
                                        Text(NumberUtils.amountConversion(item['playCount']), style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11
                                        ),)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(item['name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              )
                            ],
                          ),
                        )
                    );
                  }
              )
          );
        }
    );
  }
  // 构建新歌
  Widget _buildNewSongs() {
    return CustomFutureBuilder(
        defaultHeight: 192,
        futureFunc: _getNewSongs,
        builder: (context, data) {
          var songList = data;
          return Consumer<PlaySongsProvider>(
            builder: (context, model, child) {
              Song curSong = model.curSong;
              return PaginationGridView(
                  height: 192,
                  itemCount: songList.length > 6 ? 6 : songList.length,
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1 / 6.1,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  builder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (curSong != null && curSong.id == songList[index]['id']) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return PlaySongPage();
                          }));
                          return;
                        }

                        List<Map> data = (songList as List).cast();
                        List<Song> songs = [];
                        data.forEach((e) {
                          String artists = (e['song']['artists'] as List).map((e) => e['name']).join('、');
                          songs.add(Song(e['id'], name: e['name'], artists: artists, picUrl: e['picUrl']));
                        });
                        Provider.of<PlaySongsProvider>(context, listen: false).playSongs(songs, index: index);
                      },
                      child: Row(
                        children: <Widget>[
                          CustomCacheNetworkImage(
                            imageUrl: songList[index]['picUrl'] + '?param=200y200',
                            width: 56,
                            height: 56,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    RichText(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                            style: TextStyle(fontSize: 15, color: Colors.black87),
                                            children: [
                                              TextSpan(text: songList[index]['name']),
                                              TextSpan(text: ' - ' + songList[index]['song']['artists'][0]['name'], style: TextStyle(fontSize: 12, color: Colors.grey, ),)
                                            ]
                                        )
                                    ),
//                                      Text(songList[index]['reason'],
//                                        style: TextStyle(fontSize: 12, color: Colors.grey, ),
//                                        maxLines: 1,
//                                        overflow: TextOverflow.ellipsis,
//                                      ),
                                  ],
                                ),
                              )
                          ),
                          curSong != null && curSong.id == songList[index]['id']
                              ? Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            child: Icon(Icons.volume_up, color: Colors.red, size: 21,),
                          )
                              : Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                    color: Color(0xffd0d0d0),
                                    width: 0.5
                                )
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.play_arrow, color: Colors.red, size: 16,),
                          )
                        ],
                      ),
                    );
                  }
              );
            }
          );
        }
    );
  }
  // 构建新碟
  Widget _buildNewAlbum() {
    return CustomFutureBuilder(
        defaultHeight: 192,
        futureFunc: _getNewAlbum,
        builder: (context, data) {
          var albumList = data;
          return PaginationGridView(
            height: 192,
            itemCount: albumList.length > 6 ? 6 : albumList.length,
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 16,
            childAspectRatio: 1 / 6.1,
            padding: EdgeInsets.symmetric(horizontal: 16),
            builder: (context, index) {
              return InkWell(
                onTap: () {
                  print(albumList[index]);
                },
                child: Row(
                  children: <Widget>[
                    CustomCacheNetworkImage(
                      imageUrl: albumList[index]['picUrl'] + '?param=200y200',
                      width: 56,
                      height: 56,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                      children: [
                                        TextSpan(text: albumList[index]['name']),
                                        TextSpan(text: ' - ' + albumList[index]['artists'][0]['name'], style: TextStyle(fontSize: 12, color: Colors.grey, ),)
                                      ]
                                  )
                              ),
//                                      Text(songList[index]['reason'],
//                                        style: TextStyle(fontSize: 12, color: Colors.grey, ),
//                                        maxLines: 1,
//                                        overflow: TextOverflow.ellipsis,
//                                      ),
                            ],
                          ),
                        )
                    ),
                  ],
                ),
              );
            },
          );
        }
    );
  }
}
