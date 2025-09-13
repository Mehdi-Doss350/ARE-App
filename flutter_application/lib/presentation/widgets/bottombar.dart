import 'package:flutter/material.dart';
import 'package:flutter_application/data/logic.dart';
import '../screens/home.dart';
import '../screens/orders.dart';
import '../screens/alerts.dart';
import '../screens/account.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final int ordersCount;
  bool get _isAdmin => loggedInEmail == "admin123@gmail.com";
  final List<dynamic> _reservations = [];
  int get _reservationCount {
    if (_isAdmin) {
      return _reservations.where((res) => res['isResponse'] == false).length;
    } else {
      return _reservations
          .where((res) =>
              res['user_email'] == loggedInEmail && res['isResponse'] == true)
          .length;
    }
  }

  BottomBar({super.key, required this.currentIndex, required this.ordersCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE1DBBD),
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: Container(
            color: const Color.fromARGB(255, 255, 200, 0),
            child: BottomNavigationBar(
              elevation: 0,
              currentIndex: currentIndex,
              backgroundColor: Colors.transparent,
              selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
              unselectedItemColor: Colors.black,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                // Navigation logic
                switch (index) {
                  case 0:
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                      (route) => false,
                    );
                    break;
                  case 1:
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Orders()),
                      (route) => false,
                    );
                    break;
                  case 2:
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Notifications()),
                      (route) => false,
                    );
                    break;
                  case 3:
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Account()),
                      (route) => false,
                    );
                    break;
                }
              },
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (ordersCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              ordersCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications),
                      if (_reservationCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$_reservationCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Alerts',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Account',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
