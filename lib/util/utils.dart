import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();

  XFile? file = await imagePicker.pickImage(source: source);

  if (file != null) {
    return await file.readAsBytes();
  }
  if (kDebugMode) {
    print('No image selected');
  }
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content)
    ),
  );
}

String capitalizeWords(String input) {
  List<String> words = input.split(' ');
  List<String> processedWords = words.map((word) {
    if (word.length > 3) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    } else {
      return word.toUpperCase();
    }
  }).toList();
  return processedWords.join(' ');
}
