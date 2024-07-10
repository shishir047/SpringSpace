import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spring_space/models/user.dart' as model;
import 'package:spring_space/providers/user_providers.dart';
import 'package:spring_space/resources/firestore_methods.dart';
import 'package:spring_space/util/colors.dart';
import 'package:spring_space/util/utils.dart';

class CreatePostScreen extends StatefulWidget {
  final String postType;
  const CreatePostScreen({super.key, required this.postType});

  @override
  CreatePostScreenState createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  bool isTakeNotice = false;
  bool isFood = false;
  bool isVegetable = false;
  bool isWholeGrains = false;
  bool isDairy = false;
  bool isProtein = false;
  bool isAppreciation = false;
  bool isShareShift = false;
  int selectedEmotionIndex = -1;
  String _selectedEmoji = '';
  bool showEmojiPicker = false;
  Uint8List? _file;
  bool _isLoading = false;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchUserController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeFromController = TextEditingController();
  TextEditingController timeToController = TextEditingController();
  late DateTime selectedDate = DateTime.now();
  late TimeOfDay timeFrom;
  late TimeOfDay timeTo;

  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? selectedUser;

  // Functions

  @override
  void initState() {
    super.initState();
    setPostType();
  }

  void setPostType() {
    switch (widget.postType) {
      case 'isShareShift':
        isShareShift = true;
        break;
      case 'isTakeNotice':
        isTakeNotice = true;
        break;
      case 'isFood':
        isFood = true;
        break;
      case 'isVegetable':
        isVegetable = true;
        break;
      case 'isWholeGrains':
        isWholeGrains = true;
        break;
      case 'isDairy':
        isDairy = true;
        break;
      case 'isProtein':
        isProtein = true;
        break;
      case 'isAppreciation':
        isAppreciation = true;
        break;
    }
    if (kDebugMode) {
      print('Post Type: $widget.postType');
      print('isShareShift: $isShareShift');
    }
  }

  void hideSelectEmotion() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  void toggleEmojiPicker() {
    FocusScope.of(context).unfocus();
    setState(() {
      showEmojiPicker = !showEmojiPicker;
    });
  }

  void selectEmotion(int index) {
    setState(() {
      selectedEmotionIndex = index;
    });
  }

  void onEmojiSelected(Emoji emoji) {
    setState(() {
      _selectedEmoji = emoji.emoji;
    });
  }

  Future<void> _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          backgroundColor: dialogBackgroundColor,
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take a photo'),
              onPressed: () async {
                Navigator.pop(context);
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  final fileBytes = await pickedFile.readAsBytes();
                  setState(() {
                    _file = fileBytes;
                  });
                }
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose from Gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  final fileBytes = await pickedFile.readAsBytes();
                  setState(() {
                    _file = fileBytes;
                  });
                }
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void postImage(
    String uid,
    String username,
    String profImage,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_file == null && !isAppreciation && !isShareShift) {
        _isLoading = false;
        showSnackBar(
          'Please upload a photo',
          context,
        );
        return;
      }
      if (isAppreciation) {
        if (selectedUser == null || descriptionController.text.isEmpty) {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please select a user and write a message.')),
          );
          return;
        }
      }

      if (isShareShift) {
        if (dateController.text.isEmpty) {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select date')),
          );
          return;
        }
        if (timeFromController.text.isEmpty) {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select "Time From"')),
          );
          return;
        }
        if (timeToController.text.isEmpty) {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select "Time To"')),
          );
          return;
        }
        if (descriptionController.text.isEmpty) {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please write description')),
          );
          return;
        }
      }

      String res = await FireStoreMethods().uploadPost(
        descriptionController.text,
        isAppreciation || isShareShift ? Uint8List(0) : _file!,
        _selectedEmoji,
        uid,
        username,
        profImage,
        isTakeNotice,
        isFood,
        isVegetable,
        isWholeGrains,
        isDairy,
        isProtein,
        isAppreciation,
        isShareShift,
        dateController.text,
        timeFromController.text,
        timeToController.text,
        selectedUser?['username'] ?? '',
        selectedUser?['uid'] ?? '',
        selectedUser?['photoUrl'] ?? '',
      );
      if (res == "success") {
        setState(() {
          _isLoading = false;
        });

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        if (context.mounted) {
          showSnackBar(
            'Posted!',
            // ignore: use_build_context_synchronously
            context,
          );
        }
      } else {
        if (context.mounted) {
          showSnackBar(
            res,
            // ignore: use_build_context_synchronously
            context,
          );
        }
      }
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(
        err.toString(),
        // ignore: use_build_context_synchronously
        context,
      );
    }
  }

  void searchUser(String query) async {
    if (query.isEmpty) {
      setState(() {
        users = [];
      });
      return;
    }

    try {
      var result = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .get();

      setState(() {
        users = result.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error searching user: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching user: $e')),
      );
    }
  }

  void selectUser(Map<String, dynamic> user) {
    setState(() {
      selectedUser = user;
      searchUserController.text = user['username'];
      users = [];
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller,
      {bool isFromTime = false}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      if (isFromTime) {
        setState(() {
          timeFrom = picked;
          controller.text = DateFormat('HH:mm').format(selectedTime);
        });
      } else {
        if (picked.hour < timeFrom.hour ||
            (picked.hour == timeFrom.hour &&
                picked.minute <= timeFrom.minute)) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The "To" time must be after the "From" time.'),
            ),
          );
        } else {
          setState(() {
            timeTo = picked;
            controller.text = DateFormat('HH:mm').format(selectedTime);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    model.User? user = Provider.of<UserProvider>(context).getUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: isAppreciation
            ? const Text('Send Appreciation')
            : isShareShift
                ? const Text('Share Shift')
                : const Text('Create a post'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 16.0),
        child: Column(
          children: [
            _isLoading ? const LinearProgressIndicator() : Container(),
            if (!isAppreciation && !isShareShift)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => postImage(
                          user.uid,
                          user.username,
                          user.photoUrl,
                        ),
                        child: const Text('Post'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 11.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _selectImage(context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: _file == null
                                ? BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 129, 129, 129)),
                                    borderRadius: BorderRadius.circular(2),
                                  )
                                : null,
                            child: _file == null
                                ? const Icon(Icons.add)
                                : Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        alignment: FractionalOffset.topCenter,
                                        image: MemoryImage(_file!),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else if (isAppreciation)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 2.0),
                child: Column(
                  children: [
                    TextField(
                      controller: searchUserController,
                      decoration: const InputDecoration(
                          hintText: 'Search for a user...'),
                      onChanged: searchUser,
                    ),
                    if (users.isNotEmpty)
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(users[index]['username']),
                              onTap: () => selectUser(users[index]),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (selectedUser != null)
                      Chip(
                        backgroundColor: Colors.white,
                        label: Text(selectedUser!['username']),
                        onDeleted: () {
                          setState(() {
                            selectedUser = null;
                            searchUserController.clear();
                          });
                        },
                      ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Select Date',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: timeFromController,
                      readOnly: true,
                      onTap: () {
                        _selectTime(context, timeFromController,
                            isFromTime: true);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Time From:',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: timeToController,
                      readOnly: true,
                      onTap: () {
                        _selectTime(context, timeToController);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Time To:',
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: !isShareShift
                  ? const EdgeInsets.only(left: 11.0)
                  : const EdgeInsets.only(left: 11.0, top: 10.0),
              child: TextField(
                maxLines: 4,
                onTap: hideSelectEmotion,
                controller: descriptionController,
                decoration: !isShareShift
                    ? const InputDecoration(
                        hintText: 'Write Caption',
                        border: OutlineInputBorder(),
                      )
                    : const InputDecoration(
                        hintText: 'Write Description',
                        border: OutlineInputBorder(),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (isShareShift)
              Center(
                child: ElevatedButton(
                  onPressed: () => postImage(
                    user.uid,
                    user.username,
                    user.photoUrl,
                  ),
                  child: const Text('Give Shift'),
                ),
              ),
            if (isAppreciation)
              Center(
                child: ElevatedButton(
                  onPressed: () => postImage(
                    user.uid,
                    user.username,
                    user.photoUrl,
                  ),
                  child: const Text('Send'),
                ),
              ),
            const SizedBox(height: 20),
            if (isTakeNotice)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('I am feeling: '),
                  GestureDetector(
                    onTap: toggleEmojiPicker,
                    child: Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: _selectedEmoji == ''
                            ? Icon(
                                Icons.emoji_emotions,
                                color: Colors.green[600],
                              )
                            : Text(
                                _selectedEmoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (showEmojiPicker)
              Expanded(
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    onEmojiSelected(emoji);
                    toggleEmojiPicker();
                  },
                  config: const Config(
                    columns: 7,
                    emojiSizeMax: 32,
                    bgColor: Color.fromARGB(255, 255, 255, 255),
                    recentTabBehavior: RecentTabBehavior.NONE,
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: CategoryIcons(
                      animalIcon: IconData(0),
                      foodIcon: IconData(0),
                      travelIcon: IconData(0),
                      activityIcon: IconData(0),
                      objectIcon: IconData(0),
                      symbolIcon: IconData(0),
                      flagIcon: IconData(0),
                    ),
                    buttonMode: ButtonMode.MATERIAL,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
