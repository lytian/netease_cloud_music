import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:netease_cloud_music/application.dart';
import 'package:netease_cloud_music/models/song.dart';
import 'package:netease_cloud_music/utils/dio_utils.dart';

class PlaySongsProvider with ChangeNotifier {
  AudioPlayer _audioPlayer = AudioPlayer();
  StreamController<String> _curPositionController = StreamController<String>.broadcast();

  List<Song> _songs = [];
  List<Song> _songsBAK = []; // 歌曲备份
  PlayMode playMode = PlayMode.sequence; // 播放模式
  bool isIntelligence = false; // 智能模式
  int curIndex = 0;
  Duration curSongDuration;
  AudioPlayerState _curState;

  List<Song> get allSongs => _songs;
  Song get curSong {
    if (_songs.isEmpty) return null;

    return _songs[curIndex];
  }
  Stream<String> get curPositionStream => _curPositionController.stream;
  AudioPlayerState get curState => _curState;

  void init() {
    _audioPlayer.setReleaseMode(ReleaseMode.STOP);
    // 播放状态监听
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _curState = state;
      // 先做顺序播放
      if(state == AudioPlayerState.COMPLETED){
        nextPlay();
      }
      // 其实也只有在播放状态更新时才需要通知。
      notifyListeners();
    });
    _audioPlayer.onDurationChanged.listen((d) {
      curSongDuration = d;
    });
    // 当前播放进度监听
    _audioPlayer.onAudioPositionChanged.listen((Duration p) {
      sinkProgress(p.inMilliseconds > curSongDuration.inMilliseconds ? curSongDuration.inMilliseconds : p.inMilliseconds);
    });
  }

  // 歌曲进度
  void sinkProgress(int m){
    _curPositionController.sink.add('$m-${curSongDuration.inMilliseconds}');
  }

  /// 播放一首歌。 传入歌单ID，则表示智能播放
  void playSong(Song song, { int pid }) async {
    if (pid != null) {
      // TODO 智能模式，获取心动列表
      isIntelligence = true;
      playMode = PlayMode.intelligence;

      _songs = await getPlayListByIntelligence(song.id, pid);
      if (_songs.isEmpty) return;
      curIndex = 0;
    } else {
      isIntelligence = false;
    }
    _songs.insert(curIndex, song);
    play();
  }

  /// 播放一首歌
  void playIndex(int index) {
    curIndex = index;
    play();
  }

  /// 播放很多歌
  void playSongs(List<Song> songs, {int index}) {
    isIntelligence = false;
    if (playMode == PlayMode.random) {
      // 打乱顺序
      _songsBAK = songs;
      _songs = songs;
      _songs.shuffle();
      // 查找新的index
      if (index != null) {
        this.curIndex = _songs.indexWhere((song) => song.id == songs[index].id);
      }
    } else {
      this._songs = songs;
      if (index != null) curIndex = index;
    }
    play();
  }

  /// 添加歌曲
  void addSongs(List<Song> songs) {
    this._songs.addAll(songs);
    notifyListeners();
  }

  /// 移除歌单
  void removeSong(int index) {
    this._songs.removeAt(index);
    if (index == curIndex) {
      if(curIndex >= _songs.length){
        curIndex = 0;
      }
      play();
    }
    notifyListeners();
  }

  /// 切换播放模式
  void changePlayMode() {
    // 随机模式切换之前
    if (playMode == PlayMode.random) {
      // 先还原
      _songs = List.from(_songsBAK);
      // 查找新的index
      this.curIndex = _songs.indexWhere((song) => song.id == _songsBAK[curIndex].id);
    }
    // 切换操作
    int modeIndex = playMode.index + 1;
    if(modeIndex >= (isIntelligence ? PlayMode.values.length : (PlayMode.values.length - 1))) {
      playMode = PlayMode.values[0];
    } else{
      playMode = PlayMode.values[modeIndex];
    }

    // 切换到随机播放后
    if (playMode == PlayMode.random) {
      // 打乱顺序
      _songsBAK = List.from(_songs);
      _songs.shuffle();
      // 查找新的index
      this.curIndex = _songs.indexWhere((song) => song.id == _songsBAK[curIndex].id);
    }

    notifyListeners();
  }

  /// 播放
  void play() async {
    var songId = this._songs[curIndex].id;
    var url = await getMusicURL(songId);
    _audioPlayer.play(url);
    saveCurSong();
  }

  /// 暂停、恢复
  void togglePlay(){
    if (_audioPlayer.state == AudioPlayerState.PAUSED) {
      resumePlay();
    } else {
      pausePlay();
    }
  }

  /// 暂停
  void pausePlay() {
    _audioPlayer.pause();
  }

  /// 跳转到固定时间
  void seekPlay(int milliseconds){
    _audioPlayer.seek(Duration(milliseconds: milliseconds));
    resumePlay();
  }

  /// 恢复播放
  void resumePlay() {
    _audioPlayer.resume();
  }

  /// 下一首
  void nextPlay(){
    if (playMode == PlayMode.single) {
      // 单曲循环
      play();
      return;
    }
    if(curIndex >= _songs.length){
      curIndex = 0;
    }else{
      curIndex++;
    }
    play();
  }

  /// 上一首
  void prePlay(){
    if (playMode == PlayMode.single) {
      // 单曲循环
      play();
      return;
    }
    if(curIndex <= 0){
      curIndex = _songs.length - 1;
    }else{
      curIndex--;
    }
    play();
  }
  
  Future<String> getMusicURL(int id) async {
    try {
      var data = await DioUtils.get('/song/url', queryParameters: {'id': id});
      return data['data'][0]['url'];
    } catch (e) {
    }
    return "";
  }

  Future getPlayListByIntelligence(int songId, int pid) async {
    List<Song> list = [];
    try {
      var data = await DioUtils.get('/playmode/intelligence/list', queryParameters: {'id': songId, 'pid': pid});
      (data['data'] as List).cast().forEach((e) {
        String ar = (e['songInfo']['ar'] as List).map((a) => a['name']).join('、');
        list.add(Song(e['id'], name: e['songInfo']['name'], picUrl: e['songInfo']['al']['picUrl'], artists: ar));
      });
    } catch(e) {}
    return list;
  }

  // 保存当前歌曲到本地
  void saveCurSong(){
    Application.sp.remove('playing_songs');
    Application.sp.setStringList('playing_songs', _songs.map((s) => jsonEncode(s)).toList());
    Application.sp.setInt('playing_index', curIndex);
  }

  @override
  void dispose() {
    _curPositionController.close();
    _audioPlayer.dispose();
    super.dispose();
  }
}