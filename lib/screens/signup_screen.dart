import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spring_space/resources/auth_methods.dart';
import 'package:spring_space/util/colors.dart';
import 'package:spring_space/util/utils.dart';
import 'package:spring_space/widgets/text_field_input.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  List<String> _departments = [];
  String? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  void selectImage() async {
    Uint8List dp = await pickImage(ImageSource.gallery);
    setState(() {
      _image = dp;
    });
  }

  Future<void> _fetchDepartments() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('departments').get();
    List<String> departments =
        snapshot.docs.map((doc) => doc['departmentName'] as String).toList();
    setState(() {
      _departments = departments;
    });
  }

  void signupUser() async {
    setState(() {
      _isLoading = true;
    });

    if (_image == null) {
      showSnackBar('Please select a profile picture', context);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_selectedDepartment == null) {
      showSnackBar('Please select a department', context);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String res = await AuthMethods().signupUser(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      department: _selectedDepartment!.toLowerCase(),
      dp: _image!,
    );

    setState(() {
      _isLoading = false;
    });

    if (res != 'success') {
      // ignore: use_build_context_synchronously
      showSnackBar(res, context);
    } else {
      await AuthMethods().addDept(
        username: _usernameController.text,
        departmentName: _selectedDepartment!.toLowerCase(),
      );
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 50),
                  const Text(
                    'Spring Space',
                    style: TextStyle(
                      fontFamily: 'AutourOne',
                      fontSize: 30,
                      color: Color.fromARGB(255, 1, 59, 1),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: MemoryImage(_image!),
                              backgroundColor: customGreen[100],
                            )
                          : CircleAvatar(
                              radius: 40,
                              backgroundColor: customGreen[100],
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                      Positioned(
                        bottom: -10,
                        left: 40,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: Icon(
                            Icons.add_a_photo,
                            color: customGreen[500],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFieldInput(
                    labelText: 'Name',
                    textInputType: TextInputType.text,
                    textEditingController: _nameController,
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    labelText: 'Username',
                    textInputType: TextInputType.text,
                    textEditingController: _usernameController,
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    labelText: 'Your Email',
                    textInputType: TextInputType.emailAddress,
                    textEditingController: _emailController,
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    labelText: 'Create Password',
                    textInputType: TextInputType.text,
                    textEditingController: _passwordController,
                    isPass: true,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    hint: const Text('Select Department'),
                    items: _departments.map((String department) {
                      return DropdownMenuItem<String>(
                        value: department,
                        child: Text(capitalizeWords(department)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDepartment = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border:
                          OutlineInputBorder(),
                    ),
                    dropdownColor:
                        const Color.fromARGB(255, 246, 255, 242),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: signupUser,
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: customGreen[600],
                                strokeWidth: 3,
                              ),
                            )
                          : const Text('Sign Up'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to the LoginScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
