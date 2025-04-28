import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'dias.db');
    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE user(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId TEXT,
      userType TEXT,
      loginSecretKey TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE attendance(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ciphertext TEXT UNIQUE
    )
  ''');

    await db.execute('''
    CREATE TABLE attendance_table(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      courseCode TEXT,
      totalCount INTEGER,
      present INTEGER
    )
  ''');

    await db.execute('''
    CREATE TABLE meta(
      key TEXT PRIMARY KEY,
      value TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE user_profile(
      userId TEXT PRIMARY KEY,
      email TEXT,
      name TEXT,
      mobile TEXT,
      role TEXT,
      scholar_no TEXT,
      enrollment TEXT,
      class TEXT
    )
  ''');
  }

  // Credentials and user info
  Future<Map<String, String>?> getCredentials() async {
    final db = await database;
    final result = await db.query('user', limit: 1);
    if (result.isNotEmpty) {
      return {
        'userId': result.first['userId'] as String,
        'userType': result.first['userType'] as String,
      };
    }
    return null;
  }

  Future<String> getUserId() async {
    final db = await database;
    final result = await db.query('user', limit: 1);
    if (result.isNotEmpty) {
      return result.first['userId'] as String;
    }
    return "";
  }

  Future<void> storeCredentials(Map<String, String> credentials) async {
    final db = await database;
    await db.insert(
      'user',
      credentials,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Attendance functions
  Future<void> storeAttendance(String ciphertext) async {
    final db = await database;
    await db.insert('attendance', {
      'ciphertext': ciphertext,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<bool> attendanceExists(String ciphertext) async {
    final db = await database;
    final result = await db.query(
      'attendance',
      where: 'ciphertext = ?',
      whereArgs: [ciphertext],
    );
    return result.isNotEmpty;
  }

  Future<List<String>> getAttendanceList() async {
    final db = await database;
    final result = await db.query('attendance');
    return result.map((row) => row['ciphertext'] as String).toList();
  }

  Future<void> clearAttendance() async {
    final db = await database;
    await db.delete('attendance');
  }

  Future<void> updateAttendanceTable(
    List<Map<String, dynamic>> tableData,
  ) async {
    final db = await database;
    await db.delete('attendance_table');
    for (var row in tableData) {
      await db.insert('attendance_table', row);
    }
  }

  Future<List<Map<String, dynamic>>> getAttendanceTable() async {
    final db = await database;
    final result = await db.query('attendance_table');
    return result;
  }

  Future<void> setLastSync(String timestamp) async {
    final db = await database;
    await db.insert('meta', {
      'key': 'lastSync',
      'value': timestamp,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String> getLastSync() async {
    final db = await database;
    final result = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: ['lastSync'],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }
    return "";
  }

  Future<void> storeBlockedStatus(bool isBlocked) async {
    final db = await database;
    await db.insert('meta', {
      'key': 'blocked_status',
      'value': isBlocked.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> getBlockedStatus() async {
    final db = await database;
    final result = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: ['blocked_status'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['value'] == 'true';
    }
    return false;
  }

  // ------------------ New: User Profile methods ------------------

  Future<void> setUserProfile(Map<String, dynamic> profile) async {
    final db = await database;
    await db.insert(
      'user_profile',
      profile,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> getUserProfile() async {

    final db = await database;
    final userId = await getUserId();
    final result = await db.query(
      'user_profile',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return {};
  }

  Future<String> getUserClass() async {
    final profile = await getUserProfile();
    return profile['class'] ?? "";
  }

  Future<void> setUserClass(String newClass) async {
    final db = await database;
    final userId = await getUserId();
    await db.update(
      'user_profile',
      {'class': newClass},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('user');
    await db.delete('attendance');
    await db.delete('attendance_table');
    await db.delete('meta');
    await db.delete('user_profile');
  }
}
