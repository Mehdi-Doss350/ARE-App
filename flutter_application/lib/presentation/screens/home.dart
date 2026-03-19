import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/data/logic.dart';
import 'package:flutter_application/presentation/screens/product.dart';
import 'package:flutter_application/presentation/widgets/appbar.dart';
import 'package:flutter_application/presentation/widgets/bottombar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<category>> fetchCategories() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.15:5000/api/categories'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String email = 'admin123@gmail.com';

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        final shouldExit = await showExitDialog(context);
        if (shouldExit) {
          if (Theme.of(context).platform == TargetPlatform.android) {
            SystemNavigator.pop();
          } else {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        bottomNavigationBar:
            BottomBar(currentIndex: 0, ordersCount: orders.length),
        appBar: customAppBar(
          title: "Home",
          leadingIcon: Icons.home,
        ),
        body: Container(
          color: const Color(0xFFE1DBBD),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<List<category>>(
              future: fetchCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final categories = snapshot.data!;
                  if (categories.isEmpty) {
                    return const Center(
                      child: Text(
                        'No categories found.\nPlease add a category.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'HvDTrial Brandon Grotesque',
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          indexcategoryclick = index;
                          categoryclick = categories[index].name;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductPage(),
                            ),
                          );
                        },
                        child: product(
                            categories[index].image, categories[index].name),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
        floatingActionButton: email == 'admin123@gmail.com'
            ? FloatingActionButton(
                onPressed: () async {
                  final added = await showAddCategoryDialog(context);
                  if (added) setState(() {});
                },
                backgroundColor: Colors.black,
                tooltip: 'Add Category',
                child: const Icon(Icons.add, color: Colors.white))
            : null,
      ),
    );
  }

  Widget product(String image, String name) {
    final String imageUrl =
        image.startsWith('http') ? image : 'http://192.168.1.15:5000/$image';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 50);
                },
              ),
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'HvDTrial Brandon Grotesque',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> showExitDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
            dialogTheme:
                DialogThemeData(backgroundColor: const Color(0xFFE1DBBD)),
          ),
          child: PopScope(
            canPop: false,
            child: Dialog(
              backgroundColor: const Color(0xFFE1DBBD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Exit App',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HvDTrial Brandon Grotesque',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Do you want to exit the application?',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'HvDTrial Brandon Grotesque',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: 'HvDTrial Brandon Grotesque',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC800),
                            foregroundColor: Colors.black,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'EXIT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'HvDTrial Brandon Grotesque',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ) ??
      false;
}

Future<bool> showAddCategoryDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final techniqueOp1Controller = TextEditingController();
  final techniqueOp2Controller = TextEditingController();
  final techniqueOp3Controller = TextEditingController();
  final techniqueOp4Controller = TextEditingController();
  final techniqueOp5Controller = TextEditingController();

  File? pickedImage;
  String? responseMessage;
  bool isLoading = false;
  bool categoryAdded = false;
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Theme(
      data: Theme.of(context).copyWith(
        dialogTheme: DialogThemeData(backgroundColor: const Color(0xFFE1DBBD)),
      ),
      child: StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: const Color(0xFFE1DBBD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (responseMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: responseMessage!.contains('added')
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: responseMessage!.contains('added')
                            ? Colors.green
                            : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          responseMessage!.contains('added')
                              ? Icons.check_circle
                              : Icons.error,
                          color: responseMessage!.contains('added')
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            responseMessage!,
                            style: TextStyle(
                              color: responseMessage!.contains('added')
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setState(() {
                        pickedImage = File(picked.path);
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 1,
                      ),
                    ),
                    child: pickedImage == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 40, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to select image',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(pickedImage!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Technique Options:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: [
                        techniqueOp1Controller,
                        techniqueOp2Controller,
                        techniqueOp3Controller,
                        techniqueOp4Controller,
                        techniqueOp5Controller,
                      ][index],
                      decoration: InputDecoration(
                        labelText: 'Technique Option ${index + 1}',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC800),
                        foregroundColor: Colors.black,
                        elevation: 2,
                        minimumSize: const Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (pickedImage == null) {
                                setState(() {
                                  responseMessage = 'Please pick an image';
                                });
                                return;
                              }

                              setState(() {
                                isLoading = true;
                                responseMessage = null;
                              });

                              var request = http.MultipartRequest(
                                'POST',
                                Uri.parse(
                                    'http://192.168.1.15:5000/api/categories'),
                              );
                              request.fields['name'] = nameController.text;
                              request.fields['op1'] =
                                  techniqueOp1Controller.text;
                              request.fields['op2'] =
                                  techniqueOp2Controller.text;
                              request.fields['op3'] =
                                  techniqueOp3Controller.text;
                              request.fields['op4'] =
                                  techniqueOp4Controller.text;
                              request.fields['op5'] =
                                  techniqueOp5Controller.text;
                              request.files.add(
                                  await http.MultipartFile.fromPath(
                                      'image', pickedImage!.path));

                              final response = await request.send();

                              setState(() {
                                isLoading = false;
                              });

                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                categoryAdded = true;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Category added!')),
                                );
                              } else {
                                final respStr =
                                    await response.stream.bytesToString();
                                String errorMsg = 'Failed to add category';
                                try {
                                  final respJson = jsonDecode(respStr);
                                  if (respJson['error'] != null) {
                                    if (respJson['error']
                                        .toString()
                                        .toLowerCase()
                                        .contains('exists')) {
                                      errorMsg =
                                          'Category name already exists, please choose another name.';
                                    } else {
                                      errorMsg = respJson['error'];
                                    }
                                  }
                                } catch (_) {}
                                setState(() {
                                  responseMessage = errorMsg;
                                });
                              }
                            },
                      child: const Text(
                        'ADD',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  return categoryAdded;
}
