import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LitsUserDataPage());
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
}

class _LitsUserDataPageState extends State<LitsUserDataPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController umurCtrl = TextEditingController();

  List<UserModel> userList = [
    UserModel(1, nama: "Satu", umur: 10),
    UserModel(2, nama: "Dua", umur: 20),
    UserModel(3, nama: "Tiga", umur: 30),
    UserModel(4, nama: "Empat", umur: 40),
  ];

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

  void save(int? id, String nama, int umur) {
    if (id != null) {
      var user = userList.firstWhere((data) => data.id == id);
      setState(() {
        user.nama = nama;
        user.umur = umur;
      });
    } else {
      var nextId = userList.length + 1;
      var newUser = UserModel(nextId, nama: nama, umur: umur);
      setState(() {
        userList.add(newUser);
      });
    }

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
            onPressed: () {
              setState(() => userList.removeWhere((data) => data.id == id));
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
      appBar: AppBar(title: Text("User List")),
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
