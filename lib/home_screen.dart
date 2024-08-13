import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:komatsu_diagnostic/image_view_screen.dart';
import 'package:komatsu_diagnostic/kerusakan_dialog_screen.dart';
import 'package:komatsu_diagnostic/partcatalogue.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartCataloguePage(),
                ),
              ),
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
                  _searchText = value.toUpperCase();
                });
              },
            ),
          ),
          Expanded(
            child: _searchText.isEmpty
                ? const Center(
                    child: Text("Type Error Code to search."),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _searchText.isEmpty
                        ? myItems.snapshots()
                        : myItems
                            .where('KodeError',
                                isGreaterThanOrEqualTo: _searchText)
                            .where('KodeError',
                                isLessThanOrEqualTo: '$_searchText\uf8ff')
                            .snapshots(),
                    builder:
                        (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        if (streamSnapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No results found."),
                          );
                        }
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
                                        builder: (context) => ImageViewScreen(
                                          imageUrls: List<String>.from(
                                              documentSnapshot['imageUrls']),
                                        ),
                                      ),
                                    );
                                  },
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
    );
  }
}
