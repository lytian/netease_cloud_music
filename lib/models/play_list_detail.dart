import 'package:netease_cloud_music/models/user.dart';

class PlayListDetail {
  List<User> subscribers; // 订阅者列表
  bool subscribed; // 是否订阅
  User creator; // 创建者
  List<Track> tracks; // 歌单
  List<TrackId> trackIds; // 歌单ID
  String updateFrequency; // 更新频率。文字
  int backgroundCoverId;
  String backgroundCoverUrl; // 背景图
  int titleImage;
  String titleImageUrl; // 头部背景图
  String englishTitle; // 英语标题
  bool opRecommend;
  String description; // 详情
  bool ordered;
  int userId;
  int adType;
  int trackNumberUpdateTime;
  int status;
  int cloudTrackCount;
  int createTime;
  bool highQuality;
  int coverImgId;
  bool newImported;
  int updateTime;
  int specialType;  // 0-歌单   100-官方动态歌单
  String commentThreadId;
  int privacy;
  int trackUpdateTime;
  int trackCount;
  String coverImgUrl;
  int subscribedCount;
  List<String> tags;
  int playCount;
  String name;
  int id;
  int shareCount;
  String coverImgIdStr;
  int commentCount;

  PlayListDetail(
      {this.subscribers,
        this.subscribed,
        this.creator,
        this.tracks,
        this.trackIds,
        this.updateFrequency,
        this.backgroundCoverId,
        this.backgroundCoverUrl,
        this.titleImage,
        this.titleImageUrl,
        this.englishTitle,
        this.opRecommend,
        this.description,
        this.ordered,
        this.userId,
        this.adType,
        this.trackNumberUpdateTime,
        this.status,
        this.cloudTrackCount,
        this.createTime,
        this.highQuality,
        this.coverImgId,
        this.newImported,
        this.updateTime,
        this.specialType,
        this.commentThreadId,
        this.privacy,
        this.trackUpdateTime,
        this.trackCount,
        this.coverImgUrl,
        this.subscribedCount,
        this.tags,
        this.playCount,
        this.name,
        this.id,
        this.shareCount,
        this.coverImgIdStr,
        this.commentCount});

  PlayListDetail.fromJson(Map<String, dynamic> json) {
    if (json['subscribers'] != null) {
      subscribers = new List<User>();
      json['subscribers'].forEach((v) {
        subscribers.add(new User.fromJson(v));
      });
    }
    subscribed = json['subscribed'];
    creator = json['creator'] != null
        ? new User.fromJson(json['creator'])
        : null;
    if (json['tracks'] != null) {
      tracks = new List<Track>();
      json['tracks'].forEach((v) {
        tracks.add(new Track.fromJson(v));
      });
    }
    if (json['trackIds'] != null) {
      trackIds = new List<TrackId>();
      json['trackIds'].forEach((v) {
        trackIds.add(new TrackId.fromJson(v));
      });
    }
    updateFrequency = json['updateFrequency'];
    backgroundCoverId = json['backgroundCoverId'];
    backgroundCoverUrl = json['backgroundCoverUrl'];
    titleImage = json['titleImage'];
    titleImageUrl = json['titleImageUrl'];
    englishTitle = json['englishTitle'];
    opRecommend = json['opRecommend'];
    description = json['description'];
    ordered = json['ordered'];
    userId = json['userId'];
    adType = json['adType'];
    trackNumberUpdateTime = json['trackNumberUpdateTime'];
    status = json['status'];
    cloudTrackCount = json['cloudTrackCount'];
    createTime = json['createTime'];
    highQuality = json['highQuality'];
    coverImgId = json['coverImgId'];
    newImported = json['newImported'];
    updateTime = json['updateTime'];
    specialType = json['specialType'];
    commentThreadId = json['commentThreadId'];
    privacy = json['privacy'];
    trackUpdateTime = json['trackUpdateTime'];
    trackCount = json['trackCount'];
    coverImgUrl = json['coverImgUrl'];
    subscribedCount = json['subscribedCount'];
    tags = json['tags'].cast<String>();
    playCount = json['playCount'];
    name = json['name'];
    id = json['id'];
    shareCount = json['shareCount'];
    coverImgIdStr = json['coverImgId_str'];
    commentCount = json['commentCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.subscribers != null) {
      data['subscribers'] = this.subscribers.map((v) => v.toJson()).toList();
    }
    data['subscribed'] = this.subscribed;
    if (this.creator != null) {
      data['creator'] = this.creator.toJson();
    }
    if (this.tracks != null) {
      data['tracks'] = this.tracks.map((v) => v.toJson()).toList();
    }
    if (this.trackIds != null) {
      data['trackIds'] = this.trackIds.map((v) => v.toJson()).toList();
    }
    data['updateFrequency'] = this.updateFrequency;
    data['backgroundCoverId'] = this.backgroundCoverId;
    data['backgroundCoverUrl'] = this.backgroundCoverUrl;
    data['titleImage'] = this.titleImage;
    data['titleImageUrl'] = this.titleImageUrl;
    data['englishTitle'] = this.englishTitle;
    data['opRecommend'] = this.opRecommend;
    data['description'] = this.description;
    data['ordered'] = this.ordered;
    data['userId'] = this.userId;
    data['adType'] = this.adType;
    data['trackNumberUpdateTime'] = this.trackNumberUpdateTime;
    data['status'] = this.status;
    data['cloudTrackCount'] = this.cloudTrackCount;
    data['createTime'] = this.createTime;
    data['highQuality'] = this.highQuality;
    data['coverImgId'] = this.coverImgId;
    data['newImported'] = this.newImported;
    data['updateTime'] = this.updateTime;
    data['specialType'] = this.specialType;
    data['commentThreadId'] = this.commentThreadId;
    data['privacy'] = this.privacy;
    data['trackUpdateTime'] = this.trackUpdateTime;
    data['trackCount'] = this.trackCount;
    data['coverImgUrl'] = this.coverImgUrl;
    data['subscribedCount'] = this.subscribedCount;
    data['tags'] = this.tags;
    data['playCount'] = this.playCount;
    data['name'] = this.name;
    data['id'] = this.id;
    data['shareCount'] = this.shareCount;
    data['coverImgId_str'] = this.coverImgIdStr;
    data['commentCount'] = this.commentCount;
    return data;
  }
}

class TrackId {
  int id;
  int v;
  dynamic alg;

  TrackId({this.id, this.v, this.alg});

  TrackId.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    v = json['v'];
    alg = json['alg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['v'] = this.v;
    data['alg'] = this.alg;
    return data;
  }
}

class Track {
  String name;
  int id;
  int pst;
  int t;
  List ar;
  List<String> alia;
  int pop;
  int st;
  String rt;
  int fee;
  int v;
  var crbt;
  String cf;
  var al;
  int dt;
  var h;
  var m;
  var l;
  var a;
  String cd;
  int no;
  String rtUrl;
  int ftype;
  List rtUrls;
  int djId;
  int copyright;
  int sId;
  int mark;
  int originCoverType;
  var noCopyrightRcmd;
  int mst;
  int cp;
  int mv;
  int rtype;
  String rurl;
  int publishTime;
  List<String> tns;

  Track(
      {this.name,
        this.id,
        this.pst,
        this.t,
        this.ar,
        this.alia,
        this.pop,
        this.st,
        this.rt,
        this.fee,
        this.v,
        this.crbt,
        this.cf,
        this.al,
        this.dt,
        this.h,
        this.m,
        this.l,
        this.a,
        this.cd,
        this.no,
        this.rtUrl,
        this.ftype,
        this.rtUrls,
        this.djId,
        this.copyright,
        this.sId,
        this.mark,
        this.originCoverType,
        this.noCopyrightRcmd,
        this.mst,
        this.cp,
        this.mv,
        this.rtype,
        this.rurl,
        this.publishTime,
        this.tns});

  Track.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    pst = json['pst'];
    t = json['t'];
    ar = json['ar'];
    alia = json['alia'].cast<String>();
    pop = json['pop'];
    st = json['st'];
    rt = json['rt'];
    fee = json['fee'];
    v = json['v'];
    crbt = json['crbt'];
    cf = json['cf'];
    al = json['al'];
    dt = json['dt'];
    h = json['h'];
    m = json['m'];
    l = json['l'];
    a = json['a'];
    cd = json['cd'];
    no = json['no'];
    rtUrl = json['rtUrl'];
    ftype = json['ftype'];
    if (json['rtUrls'] != null) {
      rtUrls = new List();
      json['rtUrls'].forEach((v) {
        rtUrls.add(v);
      });
    }
    djId = json['djId'];
    copyright = json['copyright'];
    sId = json['s_id'];
    mark = json['mark'];
    originCoverType = json['originCoverType'];
    noCopyrightRcmd = json['noCopyrightRcmd'];
    mst = json['mst'];
    cp = json['cp'];
    mv = json['mv'];
    rtype = json['rtype'];
    rurl = json['rurl'];
    publishTime = json['publishTime'];
    if (json['tns'] != null) {
      tns = json['tns'].cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['pst'] = this.pst;
    data['t'] = this.t;
    data['ar'] = this.ar;
    data['alia'] = this.alia;
    data['pop'] = this.pop;
    data['st'] = this.st;
    data['rt'] = this.rt;
    data['fee'] = this.fee;
    data['v'] = this.v;
    data['crbt'] = this.crbt;
    data['cf'] = this.cf;
    data['al'] = this.al;
    data['dt'] = this.dt;
    data['h'] = this.h;
    data['m'] = this.m;
    data['l'] = this.l;
    data['a'] = this.a;
    data['cd'] = this.cd;
    data['no'] = this.no;
    data['rtUrl'] = this.rtUrl;
    data['ftype'] = this.ftype;
    if (this.rtUrls != null) {
      data['rtUrls'] = this.rtUrls.map((v) => v).toList();
    }
    data['djId'] = this.djId;
    data['copyright'] = this.copyright;
    data['s_id'] = this.sId;
    data['mark'] = this.mark;
    data['originCoverType'] = this.originCoverType;
    data['noCopyrightRcmd'] = this.noCopyrightRcmd;
    data['mst'] = this.mst;
    data['cp'] = this.cp;
    data['mv'] = this.mv;
    data['rtype'] = this.rtype;
    data['rurl'] = this.rurl;
    data['publishTime'] = this.publishTime;
    data['tns'] = this.tns;
    return data;
  }
}