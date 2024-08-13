import 'package:flutter/material.dart';
import 'package:komatsu_diagnostic/home_screen.dart';
import 'package:komatsu_diagnostic/pdf_view_screen.dart';

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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
              },
            ),
            ListTile(
              trailing: Icon(Icons.book),
              title: Text("Part Catalogue"),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartCataloguePage()));
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
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PdfViewScreen(
                  title: "PC200-8M0",
                  document: "assets/document/pc200-8m0.pdf",
                ),
              ),
            ),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      "assets/images/pc200-8.jpeg",
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text("PC200-8M0",),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
