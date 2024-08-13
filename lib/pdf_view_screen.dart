import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewScreen extends StatelessWidget {
  final String title;
  final String document;
  const PdfViewScreen({super.key, required this.title, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Color.fromARGB(255, 255, 145, 0),
      ),
      body: SfPdfViewer.asset(document),
    );
  }
}