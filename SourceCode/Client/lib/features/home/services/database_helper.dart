// File: lib/services/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/notification_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notifications.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        type TEXT,
        time TEXT,
        isRead INTEGER
      )
    ''');
  }

  // Thêm thông báo
  Future<void> addNotification(NotificationModel notification) async {
    final db = await instance.database;
    await db.insert('notifications', notification.toMap());
  }

  // Lấy danh sách thông báo
  Future<List<NotificationModel>> getNotifications() async {
    final db = await instance.database;
    final result = await db.query('notifications', orderBy: 'id DESC');

    // Code gọn hơn nhờ hàm fromMap bên Model
    return result.map((json) => NotificationModel.fromMap(json)).toList();
  }

  // Xóa một thông báo theo ID
  Future<void> deleteNotification(int id) async {
    final db = await instance.database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  // Xóa tất cả thông báo
  Future<void> deleteAllNotifications() async {
    final db = await instance.database;
    await db.delete('notifications');
  }
}
