import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:spring_space/models/user.dart' as model;
import 'package:spring_space/util/colors.dart';
import 'package:spring_space/util/utils.dart';

import '../providers/user_providers.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  _CertificatesScreenState createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  Image? _certificateImage;
  bool _isViewingCertificate = false;

  @override
  Widget build(BuildContext context) {
    model.User? user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Certificates'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    color: customGreen[50],
                    child: Text(
                      'Congrats ${user!.name}, you are now eligible to pick shifts from the following departments: ',
                      style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var userData = snapshot.data!.data() as Map<String, dynamic>;
                      var departmentList = userData['departmentList'] as List<dynamic>;

                      return ListView.builder(
                        itemCount: departmentList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            tileColor: const Color.fromARGB(255, 248, 248, 248),
                            onTap: () async {
                              final certificate = await generateCertificate(user.name, departmentList[index]);
                              setState(() {
                                _certificateImage = certificate;
                                _isViewingCertificate = true;
                              });
                            },
                            title: Text(
                              capitalizeWords(departmentList[index].toString()),
                              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                            ),
                            trailing: user.department == departmentList[index] ? const Text('Default') : const Text(''),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isViewingCertificate && _certificateImage != null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isViewingCertificate = false;
                      });
                    },
                    child: _certificateImage,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<Image> generateCertificate(String userName, String department) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(const Offset(0, 0), const Offset(400, 600)));
    final paint = Paint();

    // Draw background
    paint.color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 600), paint);

    // Draw text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = const TextSpan(
      text: 'Certificate of Completion',
      style: TextStyle(
        color: Color.fromARGB(255, 57, 109, 33),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 300);
    textPainter.paint(canvas, const Offset(50, 100));

    textPainter.text = TextSpan(
      text: 'Dear $userName,',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 300);
    textPainter.paint(canvas, const Offset(50, 180));

    textPainter.text = TextSpan(
      text: 'Congratulations on completing the ${capitalizeWords(department)} Department Training.',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 300);
    textPainter.paint(canvas, const Offset(50, 230));

    textPainter.text = TextSpan(
      text: 'Now you are eligible to pick shifts from the ${capitalizeWords(department)} department.',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 300);
    textPainter.paint(canvas, const Offset(50, 280));

    textPainter.text = const TextSpan(
      text: 'HR',
      style: TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 300);
    textPainter.paint(canvas, const Offset(50, 400));

    textPainter.text = TextSpan(
      text: '${capitalizeWords(department)} Department',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 300);
    textPainter.paint(canvas, const Offset(50, 420));

    // Finish the picture
    final picture = recorder.endRecording();
    final img = await picture.toImage(400, 600);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    return Image.memory(pngBytes);
  }

  
}
