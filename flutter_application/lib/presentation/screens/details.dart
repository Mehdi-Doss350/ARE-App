import 'package:flutter/material.dart';
import 'package:flutter_application/data/logic.dart' as data_logic;
import 'package:flutter_application/presentation/widgets/appbar.dart';
import 'package:flutter_application/presentation/widgets/bottombar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application/core/app_constants.dart';

// Helper to fetch the category by name
Future<data_logic.category?> fetchCategoryByName(String name) async {
  final response =
      await http.get(Uri.parse('${AppConstants.baseUrl}/categories'));
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    for (final json in data) {
      if (json['name'] == name) {
        return data_logic.category.fromJson(json);
      }
    }
    return null;
  } else {
    return null;
  }
}

Future<Map<String, dynamic>?> fetchMaterialAndCategory(
    String categoryName, int materialIndex) async {
  // Fetch materials for the category
  final materialResponse = await http.get(
      Uri.parse('${AppConstants.baseUrl}/materials?category=$categoryName'));
  if (materialResponse.statusCode != 200) return null;
  final List materialData = jsonDecode(materialResponse.body);
  if (materialIndex < 0 || materialIndex >= materialData.length) return null;
  final material = data_logic.Material.fromJson(materialData[materialIndex]);

  // Fetch the category object
  final category = await fetchCategoryByName(categoryName);

  return {
    'material': material,
    'category': category,
  };
}

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<Map<String, dynamic>?> detailsFuture;

  @override
  void initState() {
    super.initState();
    detailsFuture = fetchMaterialAndCategory(
      data_logic.categoryclick,
      data_logic.productclick,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          BottomBar(currentIndex: 0, ordersCount: data_logic.orders.length),
      appBar: customAppBar(
        title: "Details",
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE1DBBD),
        ),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: detailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data!['material'] == null ||
                snapshot.data!['category'] == null) {
              return const Center(child: Text("No details available"));
            } else {
              final details = snapshot.data!['material'] as data_logic.Material;
              final category =
                  snapshot.data!['category'] as data_logic.category;

              String imageUrl = details.image.isNotEmpty
                  ? (details.image.startsWith('http')
                      ? details.image
                      : '${AppConstants.baseUrl.replaceAll("/api", "")}/${details.image}')
                  : '';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: details.image.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    imageUrl,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                size: 80),
                                  ),
                                )
                              : Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.image, size: 80),
                                ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Name:",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'HvDTrial Brandon Grotesque',
                                ),
                              ),
                              Text(
                                details.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'HvDTrial Brandon Grotesque',
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Type:",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'HvDTrial Brandon Grotesque',
                                ),
                              ),
                              Text(
                                details.type,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'HvDTrial Brandon Grotesque',
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Quantity: ${details.quantity}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'HvDTrial Brandon Grotesque',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1, color: Colors.black),
                    const SizedBox(height: 10),
                    // Details
                    const Text(
                      "Details:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HvDTrial Brandon Grotesque',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      details.detail,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'HvDTrial Brandon Grotesque',
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Technical Specifications
                    const Text(
                      "Technical Specifications:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HvDTrial Brandon Grotesque',
                      ),
                    ),
                    const SizedBox(height: 5),
                    technicalRow(category.op1, details.op1),
                    technicalRow(category.op2, details.op2),
                    technicalRow(category.op3, details.op3),
                    technicalRow(category.op4, details.op4),
                    technicalRow(category.op5, details.op5),
                    const SizedBox(height: 30),
                    // Reserve button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          final currentOrderQty =
                              data_logic.orders[details.name] ?? 0;
                          if (details.quantity > currentOrderQty) {
                            if (data_logic.orders.containsKey(details.name)) {
                              data_logic.orders[details.name] =
                                  data_logic.orders[details.name]! + 1;
                            } else {
                              data_logic.orders[details.name] = 1;
                              data_logic.orderedItems.add(details);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${details.name} added to your order',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => Theme(
                                data: Theme.of(context).copyWith(
                                  dialogTheme: DialogThemeData(
                                      backgroundColor: const Color(
                                          0xFFE1DBBD)), // Your beige color
                                ),
                                child: Dialog(
                                  backgroundColor: const Color(
                                      0xFFE1DBBD), // Consistent background
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        15), // Matching corner radius
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Out of Stock",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily:
                                                'HvDTrial Brandon Grotesque',
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "This item is currently out of stock.",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily:
                                                'HvDTrial Brandon Grotesque',
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                    0xFFFFC800), // Amber button
                                                foregroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12),
                                              ),
                                              child: const Text(
                                                "OK",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      'HvDTrial Brandon Grotesque',
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
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 200, 0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Reserve it",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'HvDTrial Brandon Grotesque',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Replace the technicalRow widget with this more professional version:
  Widget technicalRow(String categoryValue, String materialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    categoryValue,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'HvDTrial Brandon Grotesque',
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Text(
                  ' : ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    materialValue,
                    style: const TextStyle(
                      fontFamily: 'HvDTrial Brandon Grotesque',
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
