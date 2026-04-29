import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LitsUserDataPage());
  }
}

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    String path = p.join(await getDatabasesPath(), 'user_db.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT,nama TEXT,umur INTEGER)",
        );
      },
    );
  }

  static Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'user_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            umur INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  //create
  static Future<void> insertData(UserModel userModel) async {
    final db = await database;
    Map<String, dynamic> user = userModel.toJson();
    await db.insert(
      "users",
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //read
  static Future<List<UserModel>> getData() async {
    final db = await database;
    List<Map<String, Object?>> result = await db.query("users");

    List<UserModel> users = result.map((usermap) {
      return UserModel.formjson(usermap);
    }).toList();

    return users;
  }

  //update
  static Future<int> updateData(int id, UserModel userModel) async {
    final db = await database;
    var user = userModel.toJson()..remove("id");

    return await db.update("users", user, where: "id = ?", whereArgs: [id]);
  }

  //delete
  static Future<int> deleteData(int id) async {
    final db = await database;
    return await db.delete("users", where: "id = ?", whereArgs: [id]);
  }
}

class LitsUserDataPage extends StatefulWidget {
  const LitsUserDataPage({super.key});

  @override
  State<LitsUserDataPage> createState() => _LitsUserDataPageState();
}

class UserModel {
  int? id;
  String nama = "";
  int umur = 0;

  UserModel(this.id, {required this.nama, required this.umur});
  // conver dari map ke model / hashmap ke model
  factory UserModel.formjson(Map<String, dynamic> json) {
    return UserModel(json["id"], nama: json["nama"], umur: json["umur"]);
  }

  //conver dari model ke map
  Map<String, dynamic> toJson() {
    return {"id": id, "nama": nama, "umur": umur};
  }
}

class _LitsUserDataPageState extends State<LitsUserDataPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController umurCtrl = TextEditingController();

  List<UserModel> userList = [];
  @override
  void initState() {
    super.initState();

    _reloadData();
  }

  void _reloadData() async {
    var users = await DatabaseHelper.getData();
    setState(() {
      userList = users;
    });
  }

  void form(int? id) {
    if (id != null) {
      var user = userList.firstWhere((data) => data.id == id);
      nameCtrl.text = user.nama;
      nameCtrl.text = user.umur.toString();
    } else {
      nameCtrl.clear();
      umurCtrl.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsetsGeometry.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(hintText: "Nama"),
            ),
            TextField(
              controller: umurCtrl,
              decoration: InputDecoration(hintText: "Umur"),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () =>
                  save(id, nameCtrl.text, int.parse(umurCtrl.text)),
              child: Text(id == null ? "Tambah" : "perbarui"),
            ),
          ],
        ),
      ),
    );
  }

  void save(int? id, String nama, int umur) async {
    var newUser = UserModel(null, nama: nama, umur: umur);
    if (id != null) {
      await DatabaseHelper.updateData(
        id,
        UserModel(id, nama: nama, umur: umur),
      );
    } else {
      await DatabaseHelper.insertData(newUser);
    }
    _reloadData();
    Navigator.pop(context);
  }

  void delete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Hapus"),
        content: Text("Apakah anda yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.deleteData(id);
              _reloadData();
              Navigator.pop(context);
            },
            child: Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Lits")),
      body: ListView.builder(
        itemCount: userList.length,
        itemBuilder: (cxt, i) => ListTile(
          title: Text(userList[i].nama),
          subtitle: Text("umur: ${userList[i].umur}  tahun"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => form(userList[i].id),
                child: Icon(Icons.edit),
              ),
              TextButton(
                onPressed: () => delete(userList[i].id!),
                child: Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => form(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
