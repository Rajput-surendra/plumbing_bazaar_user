import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


class PdfView extends StatefulWidget {
  String url;
   PdfView({
    required this.url, Key? key}) : super(key: key);

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  // final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  String urlPDFPath = "";
  bool exists = true;
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
   late PDFViewController controller;
  bool loaded = false;
  int pages = 0;
  int indexPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      PDFView(
        filePath: "https://alphawizztest.tk/plumbing_bazzar/uploads/media/2022/mediclam1.pdf",
        // autoSpacing: false,
        // swipeHorizontal: true,
        // pageSnap: false,
        // pageFling: false,
        onRender: (pages) => setState(() => this.pages = pages!),
        onViewCreated: (controller) =>
            setState(() => this.controller = controller),
        onPageChanged: (indexPage, _) =>
            setState(() => this.indexPage = indexPage!),
      ),
      // PDFView(
      //   filePath: "https://alphawizztest.tk/plumbing_bazzar/uploads/media/2022/dummy.pdf",
      //   //widget.url,
      //   autoSpacing: true,
      //   enableSwipe: true,
      //   pageSnap: true,
      //   swipeHorizontal: true,
      //   nightMode: false,
      //   onError: (e) {
      //     //Show some error message or UI
      //   },
      //   onRender: (_pages) {
      //     setState(() {
      //       _totalPages = _pages!;
      //       pdfReady = true;
      //     });
      //   },
      //   onViewCreated: (PDFViewController vc) {
      //     setState(() {
      //       _pdfViewController = vc;
      //     });
      //   },
      //   // onPageChanged: (int page, int total) {
      //   //   setState(() {
      //   //     _currentPage = page;
      //   //   });
      //   // },
      //   onPageError: (page, e) {},
      // ),

      // Container(
      //   // child: SfPdfViewer.network(
      //   //   "https://alphawizztest.tk/plumbing_bazzar/uploads/media/2022/dummy.pdf"
      //   //   //widget.url,
      //   //  // key: _pdfViewerKey,
      //   // ),
      // ),
    );
  }
}
