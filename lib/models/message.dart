class Message {
  String senderId;
  String id; // メッセージID
  String content; // メッセージ内容
  bool isRead; // 既読フラグ
  bool isReplied; // 返信済みフラグ
  String sentAt; // 送信日時

  Message({
    required this.senderId,
    required this.id,
    required this.content,
    this.isRead = false,
    this.isReplied = false,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'id': id,
      'content': content,
      'isRead': isRead ? 1 : 0,
      'isReplied': isReplied ? 1 : 0,
      'sentAt': sentAt,
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      id: map['id'],
      content: map['content'],
      isRead: map['isRead'] == 1,
      isReplied: map['isReplied'] == 1,
      sentAt: map['sentAt'],
    );
  }

    // ここではサーバから取得したJSONデータをモデルに変換するためのコードを記述します。
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'],
      id: json['id'],
      content: json['content'],
      // isRead: json['isRead'],
      // isReplied: json['isReplied'],
      sentAt: json['sentAt'],
    );
  }

  // 必要に応じて、モデルをJSONに変換するメソッドを追加できます。
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'id': id,
      'content': content,
      // 'isRead': isRead,
      // 'isReplied': isReplied,
      'sentAt': sentAt,
    };
  }

  void updateReply(String updatedContent) {
    content = updatedContent;
    isReplied = true;
  }
}
