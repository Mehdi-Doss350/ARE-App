import 'package:flutter/material.dart';
import 'package:flutter_application/data/logic.dart' as mylogic;
import 'package:flutter_application/presentation/screens/details.dart';
import 'package:flutter_application/presentation/widgets/appbar.dart';
import 'package:flutter_application/presentation/widgets/bottombar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application/core/app_constants.dart';

Future<List<mylogic.Material>> fetchMaterials(String category) async {
  final response = await http
      .get(Uri.parse('${AppConstants.baseUrl}/materials?category=$category'));
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => mylogic.Material.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load materials');
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<List<mylogic.Material>> materialsFuture;

  @override
  void initState() {
    super.initState();
    materialsFuture = fetchMaterials(mylogic.categoryclick);
  }

  Future<void> _showAddMaterialDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final quantityController = TextEditingController();
    final detailController = TextEditingController();
    final op1Controller = TextEditingController();
    final op2Controller = TextEditingController();
    final op3Controller = TextEditingController();
    final op4Controller = TextEditingController();
    final op5Controller = TextEditingController();

    File? pickedImage;
    String? responseMessage;
    bool isLoading = false;
    bool materialAdded = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme:
              DialogThemeData(backgroundColor: const Color(0xFFE1DBBD)),
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
                    'Add Product',
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
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: typeController,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailController,
                    decoration: InputDecoration(
                      labelText: 'Detail',
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
                                  Icon(Icons.image,
                                      size: 40, color: Colors.grey),
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
                              child:
                                  Image.file(pickedImage!, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Technical Specifications:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: [
                          op1Controller,
                          op2Controller,
                          op3Controller,
                          op4Controller,
                          op5Controller,
                        ][index],
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
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
                                if (nameController.text.isEmpty ||
                                    typeController.text.isEmpty ||
                                    quantityController.text.isEmpty ||
                                    detailController.text.isEmpty ||
                                    op1Controller.text.isEmpty ||
                                    op2Controller.text.isEmpty ||
                                    op3Controller.text.isEmpty ||
                                    op4Controller.text.isEmpty ||
                                    op5Controller.text.isEmpty) {
                                  setState(() {
                                    responseMessage =
                                        'All fields should be completed';
                                  });
                                  return;
                                }
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
                                      'http://192.168.1.15:5000/api/materials'),
                                );
                                request.fields['name'] = nameController.text;
                                request.fields['type'] = typeController.text;
                                request.fields['quantity'] =
                                    quantityController.text;
                                request.fields['detail'] =
                                    detailController.text;
                                request.fields['op1'] = op1Controller.text;
                                request.fields['op2'] = op2Controller.text;
                                request.fields['op3'] = op3Controller.text;
                                request.fields['op4'] = op4Controller.text;
                                request.fields['op5'] = op5Controller.text;
                                request.fields['category'] =
                                    mylogic.categoryclick;
                                request.files.add(
                                    await http.MultipartFile.fromPath(
                                        'image', pickedImage!.path));

                                final response = await request.send();

                                setState(() {
                                  isLoading = false;
                                });

                                if (response.statusCode == 200 ||
                                    response.statusCode == 201) {
                                  materialAdded = true;
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Product added!')),
                                  );
                                } else {
                                  final respStr =
                                      await response.stream.bytesToString();
                                  String errorMsg = 'Failed to add product';
                                  try {
                                    final respJson = jsonDecode(respStr);
                                    if (respJson['error'] != null) {
                                      if (respJson['error']
                                          .toString()
                                          .toLowerCase()
                                          .contains('already exists')) {
                                        errorMsg =
                                            'Material name already exists, please choose another name.';
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
    if (materialAdded)
      setState(() {
        materialsFuture = fetchMaterials(mylogic.categoryclick);
      });
  }

  @override
  Widget build(BuildContext context) {
    // Print the loggedInEmail to the terminal for debugging
    print('loggedInEmail: ${mylogic.loggedInEmail}');

    return Scaffold(
      bottomNavigationBar:
          BottomBar(currentIndex: 0, ordersCount: mylogic.orders.length),
      appBar: customAppBar(
        title: mylogic.categoryclick,
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE1DBBD),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 20),
              child: Text(
                "Available ${mylogic.categoryclick}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'HvDTrial Brandon Grotesque',
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<mylogic.Material>>(
                future: materialsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No materials found.'));
                  } else {
                    final allmaterials = snapshot.data!;
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 2.7,
                      ),
                      itemCount: allmaterials.length,
                      itemBuilder: (context, index) {
                        final mat = allmaterials[index];
                        return buildCard(
                          context,
                          mat.name,
                          mat.image,
                          mat.type,
                          onTap: () {
                            mylogic.productclick = index;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DetailsPage(),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (mylogic.loggedInEmail != null &&
              mylogic.loggedInEmail == 'admin123@gmail.com')
          ? FloatingActionButton(
              onPressed: () => _showAddMaterialDialog(context),
              backgroundColor: Colors.black,
              tooltip: 'Add Product',
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget buildCard(
      BuildContext context, String name, String imagePath, String description,
      {VoidCallback? onTap}) {
    final String imageUrl =
        imagePath.isNotEmpty && !imagePath.startsWith('http')
            ? '${AppConstants.baseUrl.replaceAll("/api", "")}/$imagePath'
            : imagePath;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: onTap ?? () {},
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imagePath.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 40),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HvDTrial Brandon Grotesque',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'HvDTrial Brandon Grotesque',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
