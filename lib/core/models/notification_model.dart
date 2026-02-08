class NotificationModel {
  final int id;
  final String title;
  final String body;
  final dynamic data;
  final String? imageUrl;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    this.imageUrl,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'],
      imageUrl: json['imageUrl'] as String?,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'readAt': readAt,
      'createdAt': createdAt,
    };
  }
}

class NotificationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  NotificationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}

class NotificationResponse {
  final List<NotificationModel> data;
  final NotificationMeta meta;

  NotificationResponse({required this.data, required this.meta});

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] as List<dynamic>;
    final List<NotificationModel> notifications =
        dataList
            .map(
              (item) =>
                  NotificationModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    return NotificationResponse(
      data: notifications,
      meta: NotificationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((notification) => notification.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}



class Notification {
  final String title;
  final String description;
  final String time;
  bool isRead;

  Notification({
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });

  factory Notification.fromModel(NotificationModel model) {
    return Notification(
      title: model.title,
      description: model.body,
      time: model.createdAt,
      isRead: model.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'time': time,
      'isRead': isRead,
    };
  }
}