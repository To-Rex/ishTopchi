// Old Message class for messages list screen
class Message {
  final String sender;
  final String preview;
  final String time;
  final int unreadCount;

  Message({
    required this.sender,
    required this.preview,
    required this.time,
    this.unreadCount = 0,
  });
}

// Old ChatMessage class for chat messages
class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final bool isMe;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
  });
}

// New models for Chat Room Messages API
class MessageSender {
  final int id;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String birthDate;
  final String gender;
  final bool verified;
  final bool isBlocked;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  MessageSender({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    required this.birthDate,
    required this.gender,
    required this.verified,
    required this.isBlocked,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['profile_picture'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      verified: json['verified'],
      isBlocked: json['is_blocked'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt:
          json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }
}

class MessageReceiver {
  final int id;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String birthDate;
  final String gender;
  final bool verified;
  final bool isBlocked;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  MessageReceiver({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    required this.birthDate,
    required this.gender,
    required this.verified,
    required this.isBlocked,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory MessageReceiver.fromJson(Map<String, dynamic> json) {
    return MessageReceiver(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['profile_picture'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      verified: json['verified'],
      isBlocked: json['is_blocked'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt:
          json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }
}

class MessageChatRoom {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageChatRoom({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageChatRoom.fromJson(Map<String, dynamic> json) {
    return MessageChatRoom(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class MessageResumeEducation {
  final String? degree;
  final String? field;
  final String? institution;
  final String? period;

  MessageResumeEducation({
    this.degree,
    this.field,
    this.institution,
    this.period,
  });

  factory MessageResumeEducation.fromJson(Map<String, dynamic> json) {
    return MessageResumeEducation(
      degree: json['degree'],
      field: json['field'],
      institution: json['institution'],
      period: json['period'],
    );
  }
}

class MessageResumeExperience {
  final String? position;
  final String? company;
  final String? period;
  final String? description;

  MessageResumeExperience({
    this.position,
    this.company,
    this.period,
    this.description,
  });

  factory MessageResumeExperience.fromJson(Map<String, dynamic> json) {
    return MessageResumeExperience(
      position: json['position'],
      company: json['company'],
      period: json['period'],
      description: json['description'],
    );
  }
}

class MessageResume {
  final int id;
  final String title;
  final String content;
  final List<MessageResumeEducation> education;
  final List<MessageResumeExperience> experience;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fileUrl;

  MessageResume({
    required this.id,
    required this.title,
    required this.content,
    required this.education,
    required this.experience,
    required this.createdAt,
    required this.updatedAt,
    this.fileUrl,
  });

  factory MessageResume.fromJson(Map<String, dynamic> json) {
    return MessageResume(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      education:
          (json['education'] as List<dynamic>?)
              ?.map((e) => MessageResumeEducation.fromJson(e))
              .toList() ??
          [],
      experience:
          (json['experience'] as List<dynamic>?)
              ?.map((e) => MessageResumeExperience.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      fileUrl: json['file_url'],
    );
  }
}

class ChatRoomMessage {
  final int id;
  final MessageSender sender;
  final MessageReceiver receiver;
  final MessageChatRoom chatRoom;
  final MessageResume? resume;
  final String content;
  final String? mediaUrl;
  final DateTime createdAt;
  final bool isRead;

  ChatRoomMessage({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.chatRoom,
    this.resume,
    required this.content,
    this.mediaUrl,
    required this.createdAt,
    required this.isRead,
  });

  factory ChatRoomMessage.fromJson(Map<String, dynamic> json) {
    return ChatRoomMessage(
      id: json['id'],
      sender: MessageSender.fromJson(json['sender']),
      receiver: MessageReceiver.fromJson(json['receiver']),
      chatRoom: MessageChatRoom.fromJson(json['chatRoom']),
      resume:
          json['resume'] != null
              ? MessageResume.fromJson(json['resume'])
              : null,
      content: json['content'],
      mediaUrl: json['media_url'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'],
    );
  }
}

class ChatRoomMessagesMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  ChatRoomMessagesMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ChatRoomMessagesMeta.fromJson(Map<String, dynamic> json) {
    return ChatRoomMessagesMeta(
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
    );
  }
}

class ChatRoomMessagesResponse {
  final List<ChatRoomMessage> data;
  final ChatRoomMessagesMeta meta;

  ChatRoomMessagesResponse({required this.data, required this.meta});

  factory ChatRoomMessagesResponse.fromJson(Map<String, dynamic> json) {
    return ChatRoomMessagesResponse(
      data:
          (json['data'] as List<dynamic>)
              .map((e) => ChatRoomMessage.fromJson(e))
              .toList(),
      meta: ChatRoomMessagesMeta.fromJson(json['meta']),
    );
  }
}
