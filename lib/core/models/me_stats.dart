class MeStats {
  MeStatsData? data;

  MeStats({this.data});

  MeStats.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? MeStatsData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class MeStatsData {
  String? postcount;
  String? totalViews;

  MeStatsData({this.postcount, this.totalViews});

  MeStatsData.fromJson(Map<String, dynamic> json) {
    postcount = json['postcount'];
    totalViews = json['totalviews'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postcount'] = postcount;
    data['totalviews'] = totalViews;
    return data;
  }
}
