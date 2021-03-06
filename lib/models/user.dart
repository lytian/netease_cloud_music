class User {
	int vipType;
	int gender;
	int accountStatus;
	int avatarImgId;
	String nickname;
	int birthday;
	int city;
	int backgroundImgId;
	int userType;
	String avatarUrl;
	int province;
	bool defaultAvatar;
	int djStatus;
	int authStatus;
	bool mutual;
	String remarkName;
	int userId;
	bool followed;
	String backgroundUrl;
	String detailDescription;
	String description;
	String avatarImgIdStr;
	String backgroundImgIdStr;
	String signature;
	int authority;
	int followeds;
	int follows;
	int eventCount;
	int playlistCount;
	int playlistBeSubscribedCount;

	User({this.vipType, this.gender, this.accountStatus, this.avatarImgId, this.nickname, this.birthday, this.city, this.backgroundImgId, this.userType, this.avatarUrl, this.province, this.defaultAvatar, this.djStatus,  this.authStatus, this.mutual, this.remarkName, this.userId, this.followed, this.backgroundUrl, this.detailDescription, this.description, this.avatarImgIdStr, this.backgroundImgIdStr, this.signature, this.authority, this.followeds, this.follows, this.eventCount, this.playlistCount, this.playlistBeSubscribedCount});

	User.fromJson(Map<String, dynamic> json) {
		vipType = json['vipType'];
		gender = json['gender'];
		accountStatus = json['accountStatus'];
		avatarImgId = json['avatarImgId'];
		nickname = json['nickname'];
		birthday = json['birthday'];
		city = json['city'];
		backgroundImgId = json['backgroundImgId'];
		userType = json['userType'];
		avatarUrl = json['avatarUrl'];
		province = json['province'];
		defaultAvatar = json['defaultAvatar'];
		djStatus = json['djStatus'];
		authStatus = json['authStatus'];
		mutual = json['mutual'];
		remarkName = json['remarkName'];
		userId = json['userId'];
		followed = json['followed'];
		backgroundUrl = json['backgroundUrl'];
		detailDescription = json['detailDescription'];
		description = json['description'];
		avatarImgIdStr = json['avatarImgIdStr'];
		backgroundImgIdStr = json['backgroundImgIdStr'];
		signature = json['signature'];
		authority = json['authority'];
		avatarImgIdStr = json['avatarImgId_str'];
		followeds = json['followeds'];
		follows = json['follows'];
		eventCount = json['eventCount'];
		playlistCount = json['playlistCount'];
		playlistBeSubscribedCount = json['playlistBeSubscribedCount'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['vipType'] = this.vipType;
		data['gender'] = this.gender;
		data['accountStatus'] = this.accountStatus;
		data['avatarImgId'] = this.avatarImgId;
		data['nickname'] = this.nickname;
		data['birthday'] = this.birthday;
		data['city'] = this.city;
		data['backgroundImgId'] = this.backgroundImgId;
		data['userType'] = this.userType;
		data['avatarUrl'] = this.avatarUrl;
		data['province'] = this.province;
		data['defaultAvatar'] = this.defaultAvatar;
		data['authStatus'] = this.authStatus;
		data['mutual'] = this.mutual;
		data['remarkName'] = this.remarkName;
		data['userId'] = this.userId;
		data['followed'] = this.followed;
		data['backgroundUrl'] = this.backgroundUrl;
		data['detailDescription'] = this.detailDescription;
		data['description'] = this.description;
		data['avatarImgIdStr'] = this.avatarImgIdStr;
		data['backgroundImgIdStr'] = this.backgroundImgIdStr;
		data['signature'] = this.signature;
		data['authority'] = this.authority;
		data['avatarImgId_str'] = this.avatarImgIdStr;
		data['followeds'] = this.followeds;
		data['follows'] = this.follows;
		data['eventCount'] = this.eventCount;
		data['playlistCount'] = this.playlistCount;
		data['playlistBeSubscribedCount'] = this.playlistBeSubscribedCount;
		return data;
	}
}
