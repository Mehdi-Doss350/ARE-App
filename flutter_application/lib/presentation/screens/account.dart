import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/data/logic.dart';
import 'package:flutter_application/presentation/screens/home.dart';
import 'package:flutter_application/presentation/widgets/appbar.dart';
import 'package:flutter_application/presentation/widgets/bottombar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_application/presentation/screens/auth/sign_in.dart';
import 'dart:convert';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  late Future<account> accountFuture;
  File? _pickedImage;
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (loggedInEmail != null) {
      accountFuture = fetchAccountByEmail(loggedInEmail!);
      print('Fetching account for $loggedInEmail');
    } else {
      accountFuture = Future.error('No user is logged in');
    }
  }

  Future<void> _pickAndUploadImage(account dbUser) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });

      if (_pickedImage == null) return;

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('http://192.168.1.16:5000/api/accounts/upload-photo'),
      );
      request.fields['email'] = loggedInEmail!;
      request.files
          .add(await http.MultipartFile.fromPath('image', _pickedImage!.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated!')),
        );
        setState(() {
          accountFuture = fetchAccountByEmail(dbUser.email);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload photo')),
        );
      }
    }
  }

  Future<void> _showEditClassPhoneDialog(account dbUser) async {
    _classController.text = dbUser.classname;
    _phoneController.text = dbUser.phone;

    await showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: const Color(0xFFE1DBBD),
        ),
        child: Dialog(
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
                  'Edit Class & Phone',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _classController,
                  decoration: InputDecoration(
                    labelText: 'Class',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                      onPressed: () async {
                        final response = await http.patch(
                          Uri.parse(
                              'http://192.168.1.16:5000/api/accounts/update'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'email': dbUser.email,
                            'classname': _classController.text,
                            'phone': _phoneController.text,
                          }),
                        );
                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated!')),
                          );
                          setState(() {
                            accountFuture = fetchAccountByEmail(dbUser.email);
                          });
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed: ${response.body}')),
                          );
                        }
                      },
                      child: const Text(
                        'Save',
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
    );
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
        backgroundColor: const Color(0xFFE1DBBD),
        resizeToAvoidBottomInset: true,
        bottomNavigationBar:
            BottomBar(currentIndex: 3, ordersCount: orders.length),
        appBar: customAppBar(
          title: "Account",
          leadingIcon: Icons.person,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: FutureBuilder<account>(
              future: accountFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No user data found.'));
                }
                final dbUser = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(60),
                                        border: Border.all(
                                          color: const Color(0xFFFFC800),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: _pickedImage != null
                                            ? Image.file(
                                                _pickedImage!,
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                              )
                                            : (dbUser.imageUrl != 'null' &&
                                                    dbUser.imageUrl.isNotEmpty)
                                                ? Image.network(
                                                    dbUser.imageUrl
                                                            .startsWith('http')
                                                        ? dbUser.imageUrl
                                                        : 'http://192.168.1.16:5000/${dbUser.imageUrl}',
                                                    fit: BoxFit.cover,
                                                    width: 120,
                                                    height: 120,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Icon(Icons.person,
                                                            size: 80,
                                                            color: Colors.grey),
                                                  )
                                                : const Icon(
                                                    Icons.person,
                                                    size: 80,
                                                    color: Colors.grey,
                                                  ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _pickAndUploadImage(dbUser),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dbUser.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        fontFamily:
                                            'HvDTrial Brandon Grotesque',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                                255, 255, 200, 0)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        dbUser.classname,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'HvDTrial Brandon Grotesque',
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        dbUser.role,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'HvDTrial Brandon Grotesque',
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Stack(
                      children: [
                        _buildInfoCard("Phone Number", dbUser.phone),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit,
                                size: 22, color: Colors.black),
                            onPressed: () => _showEditClassPhoneDialog(dbUser),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildInfoCard("Email", dbUser.email),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => showLogoutConfirmation(context),
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
                          "Log out",
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'HvDTrial Brandon Grotesque',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'HvDTrial Brandon Grotesque',
            ),
          ),
        ],
      ),
    );
  }
}

void showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Theme(
      data: Theme.of(context).copyWith(
        dialogBackgroundColor: const Color(0xFFE1DBBD),
      ),
      child: AlertDialog(
        backgroundColor: const Color(0xFFE1DBBD),
        title: const Text(
          "Log Out",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'HvDTrial Brandon Grotesque',
          ),
        ),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(
            fontFamily: 'HvDTrial Brandon Grotesque',
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              "CANCEL",
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text(
              "LOG OUT",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _performLogout(context);
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
  );
}

void _performLogout(BuildContext context) {
  loggedInEmail = null;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const SignIn()),
    (route) => false,
  );
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("You have been logged out")),
  );
}
