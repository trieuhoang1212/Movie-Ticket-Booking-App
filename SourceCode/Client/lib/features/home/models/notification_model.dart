class NotificationModel {
  final int? id;
  final String title;
  final String body;
  final String type;
  final String time;
  final int isRead;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.isRead = 0,
  });

  // Chuyển từ Object sang Map để lưu vào DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'time': time,
      'isRead': isRead,
    };
  }

  // Chuyển từ Map (của DB) ngược lại thành Object để dùng trong App
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      type: map['type'],
      time: map['time'],
      isRead: map['isRead'],
    );
  }
}