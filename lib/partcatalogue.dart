import 'package:flutter/material.dart';

class PartCataloguePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 145, 0),
        title: Text("Part Catalogue"),
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
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              trailing: Icon(Icons.book),
              title: Text("Part Catalogue"),
              onTap: () {
                Navigator.pop(context);
                // Tetap di halaman ini
              },
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
      body: Center(
        child: Text("Part Catalogue Page"),
      ),
    );
  }
}
