import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/data/logic.dart' as cat_logic;
import 'package:flutter_application/presentation/widgets/appbar.dart';
import 'package:flutter_application/presentation/widgets/bottombar.dart';
import 'home.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/core/app_constants.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _showReservationDialog() async {
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme:
              DialogThemeData(backgroundColor: const Color(0xFFE1DBBD)),
        ),
        child: Dialog(
          backgroundColor: const Color(0xFFE1DBBD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reservation Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HvDTrial Brandon Grotesque',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Start Date Picker
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Start Date*",
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: _startDateController,
                      validator: (value) {
                        if (_startDate == null)
                          return "Please select start date";
                        return null;
                      },
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFFFFC800),
                                  onPrimary: Colors.black,
                                  surface: Color(0xFFE1DBBD),
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null && picked != _startDate) {
                          _startDateController.text =
                              DateFormat('yyyy-MM-dd').format(picked);
                          _startDate = picked;
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 15),

                    // End Date Picker
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "End Date*",
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: _endDateController,
                      validator: (value) {
                        if (_endDate == null) return "Please select end date";
                        if (_startDate != null &&
                            _endDate!.isBefore(_startDate!)) {
                          return "End date must be after start date";
                        }
                        return null;
                      },
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate:
                              _endDate ?? (_startDate ?? DateTime.now()),
                          firstDate: _startDate ?? DateTime.now(),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFFFFC800),
                                  onPrimary: Colors.black,
                                  surface: Color(0xFFE1DBBD),
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null && picked != _endDate) {
                          _endDateController.text =
                              DateFormat('yyyy-MM-dd').format(picked);
                          _endDate = picked;
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 15),

                    // Objective Field
                    TextFormField(
                      controller: _objectiveController,
                      decoration: InputDecoration(
                        labelText: "Objective*",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Objective is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Comment Field
                    TextFormField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: "Comment (Optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 25),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _processReservation();
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC800),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            "CONFIRM",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  void _processReservation() async {
    try {
      final reservationDetails = {
        'user_email': cat_logic.loggedInEmail,
        'material_list': Map<String, int>.from(cat_logic.orders),
        'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
        'end_date': DateFormat('yyyy-MM-dd').format(_endDate!),
        'objective': _objectiveController.text,
        'Comment': _commentController.text.isEmpty
            ? "No comment"
            : _commentController.text,
      };

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/reservations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reservationDetails),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reservation confirmed and saved!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _startDate = null;
          _endDate = null;
          _objectiveController.clear();
          _commentController.clear();
          cat_logic.orders.clear();
          cat_logic.orderedItems.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save reservation: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
        print("Failed to save reservation: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        final shouldExit = await showExitDialog(context);
        if (shouldExit && mounted) {
          if (Theme.of(context).platform == TargetPlatform.android) {
            SystemNavigator.pop();
          } else {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        bottomNavigationBar:
            BottomBar(currentIndex: 1, ordersCount: cat_logic.orders.length),
        appBar: customAppBar(
          title: "Orders",
          leadingIcon: Icons.shopping_cart,
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFE1DBBD),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cat_logic.orders.isNotEmpty) ...[
                ...cat_logic.orderedItems.map((material) {
                  final count = cat_logic.orders[material.name] ?? 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: buildCard(material, count),
                  );
                }),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Reserve more",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HvDTrial Brandon Grotesque',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (cat_logic.orders.isNotEmpty) ...[
                  Center(
                    child: ElevatedButton(
                      onPressed: _showReservationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 200, 0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Confirm",
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
              ] else ...[
                empty(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Expanded empty(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "You don't have any orders yet",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'HvDTrial Brandon Grotesque',
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Reserve now",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'HvDTrial Brandon Grotesque',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(cat_logic.Material details, int count) {
    String imageUrl = details.image.startsWith('http')
        ? details.image
        : '${AppConstants.baseUrl.replaceAll("/api", "")}/${details.image}';

    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          details.image.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 32),
                  ),
                )
              : const Icon(Icons.image, size: 32),
          Text(
            details.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'HvDTrial Brandon Grotesque',
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (count > 1) {
                      cat_logic.orders[details.name] = count - 1;
                    } else {
                      cat_logic.orders.remove(details.name);
                      cat_logic.orderedItems.remove(details);
                    }
                  });
                },
              ),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'HvDTrial Brandon Grotesque',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (cat_logic.orders[details.name]! < details.quantity) {
                      cat_logic.orders[details.name] = count + 1;
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
