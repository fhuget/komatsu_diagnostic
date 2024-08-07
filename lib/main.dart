import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCGc3Y1v4-iib5ayywFuunIIttYIhPfb0c",
      appId: "1:612392661218:android:9f0928b7841be33990aebb",
      messagingSenderId: "612392661218",
      projectId: "komatsu-diagnostic",
      storageBucket: "gs://komatsu-diagnostic.appspot.com",
    ),
  );

  runApp(MaterialApp(
    title: "Komatsu Diagnostic",
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MyApp> {
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection("CRUDItems");
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 145, 0),
        title: Text("Komatsu Diagnostic"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Implementasi dialog login/register di sini
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Selamat Datang"),
              accountEmail: Text("PT. UNITED TRACTORS UJUNG PANDANG"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSVenUb6FDANl6JgThGJTYk4tG_Sw4axfzSKA&s"),
              ),
              decoration: BoxDecoration(
                color: Colors.orange, // Background color
              ),
            ),
            ListTile(
              trailing: Icon(Icons.search),
              title: Text("Find Error Code"),
            ),
            ListTile(
              trailing: Icon(Icons.book),
              title: Text("Part Catalogue"),
            ),
            ListTile(
              trailing: Icon(Icons.book),
              title: Text("Manual"),
            ),
            ListTile(
              trailing: Icon(Icons.info_rounded),
              title: Text("About"),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Type Here Error Code',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchText = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _searchText.isEmpty
                  ? myItems.snapshots()
                  : myItems
                      .where('KodeError', isGreaterThanOrEqualTo: _searchText)
                      .where('KodeError', isLessThanOrEqualTo: _searchText + '\uf8ff')
                      .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(20),
                          child: ListTile(
                            title: Text(
                              "[${documentSnapshot['KodeError']}] ${documentSnapshot['NamaError']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageViewPage(
                                    imageUrls: List<String>.from(documentSnapshot['imageUrls']),
                                  ),
                                ),
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          KerusakanDialog(document: documentSnapshot),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await documentSnapshot.reference.delete();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => KerusakanDialog(),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class KerusakanDialog extends StatefulWidget {
  final DocumentSnapshot? document;

  KerusakanDialog({this.document});

  @override
  _KerusakanDialogState createState() => _KerusakanDialogState();
}

class _KerusakanDialogState extends State<KerusakanDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kodeController;
  late TextEditingController _namaController;
  List<File>? _imageFiles;
  List<Uint8List>? _webImageFiles;
  List<String>? _fileNames;
  List<String>? _imageUrls;

  @override
  void initState() {
    super.initState();
    _kodeController = TextEditingController(
        text: widget.document != null ? widget.document!['KodeError'] : '');
    _namaController = TextEditingController(
        text: widget.document != null ? widget.document!['NamaError'] : '');
    if (widget.document != null) {
      _imageUrls = List<String>.from(widget.document!['imageUrls'] ?? []);
    } else {
      _imageUrls = [];
    }
    _imageFiles = [];
    _webImageFiles = [];
    _fileNames = [];
  }

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _webImageFiles = result.files.map((file) => file.bytes!).toList();
          _fileNames = result.files.map((file) => file.name).toList();
        });
      } else {
        setState(() {
          _imageFiles = result.files.map((file) => File(file.path!)).toList();
        });
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> urls = [];
    if (kIsWeb) {
      if (_webImageFiles != null && _fileNames != null) {
        for (int i = 0; i < _webImageFiles!.length; i++) {
          final ref = FirebaseStorage.instance.ref().child(
              'images/${DateTime.now().toIso8601String()}_${_fileNames![i]}');
          final uploadTask = ref.putData(_webImageFiles![i]);
          final snapshot = await uploadTask;
          urls.add(await snapshot.ref.getDownloadURL());
        }
      }
    } else {
      if (_imageFiles != null) {
        for (File file in _imageFiles!) {
          final ref = FirebaseStorage.instance.ref().child(
              'images/${DateTime.now().toIso8601String()}_${file.path.split('/').last}');
          final uploadTask = ref.putFile(file);
          final snapshot = await uploadTask;
          urls.add(await snapshot.ref.getDownloadURL());
        }
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.document == null ? 'Tambah Kerusakan' : 'Edit Kerusakan'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _kodeController,
              decoration: InputDecoration(labelText: 'Kode Kerusakan'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kode tidak boleh kosong';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama Kerusakan'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImages,
              child: Text('Pilih Gambar'),
            ),
            _imageUrls != null && _imageUrls!.isNotEmpty
                ? Column(
                    children: _imageUrls!.map((url) => Text('Gambar terpilih: $url')).toList(),
                  )
                : Text('Tidak ada gambar terpilih'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final kodeError = _kodeController.text;
              final namaError = _namaController.text;

              if (_imageFiles != null || _webImageFiles != null) {
                final urls = await _uploadImages();
                _imageUrls!.addAll(urls);
              }

              if (widget.document == null) {
                await FirebaseFirestore.instance.collection('CRUDItems').add({
                  'KodeError': kodeError,
                  'NamaError': namaError,
                  'imageUrls': _imageUrls,
                });
              } else {
                await FirebaseFirestore.instance.collection('CRUDItems').doc(widget.document!.id).update({
                  'KodeError': kodeError,
                  'NamaError': namaError,
                  'imageUrls': _imageUrls,
                });
              }

              Navigator.of(context).pop();
            }
          },
          child: Text(widget.document == null ? 'Tambah' : 'Simpan'),
        ),
      ],
    );
  }
}

class ImageViewPage extends StatefulWidget {
  final List<String> imageUrls;

  ImageViewPage({required this.imageUrls});

  @override
  _ImageViewPageState createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  final ScrollController _scrollController = ScrollController();
  final int _perPage = 9;
  List<String> _displayedImages = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadMoreImages();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreImages();
      }
    });
  }

  void _loadMoreImages() {
    setState(() {
      int nextPage = _currentPage + 1;
      int startIndex = _currentPage * _perPage;
      int endIndex = startIndex + _perPage;
      if (startIndex < widget.imageUrls.length) {
        _displayedImages.addAll(widget.imageUrls
            .sublist(startIndex, endIndex > widget.imageUrls.length ? widget.imageUrls.length : endIndex));
        _currentPage = nextPage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Images'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: (_displayedImages.length / 3).ceil() + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index * 3 < _displayedImages.length) {
            int startIndex = index * 3;
            int endIndex = startIndex + 3;
            if (endIndex > _displayedImages.length) {
              endIndex = _displayedImages.length;
            }
            return Row(
              children: _displayedImages
                  .sublist(startIndex, endIndex)
                  .map((imageUrl) => Expanded(
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ))
                  .toList(),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
