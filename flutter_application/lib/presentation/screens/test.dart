import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/data/logic.dart';
import 'package:flutter_application/presentation/screens/home.dart';
import 'package:flutter_application/presentation/widgets/appbar.dart';
import 'package:flutter_application/presentation/widgets/bottombar.dart';
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final Set<String> _viewedNotifications = {};
  bool get _isAdmin => loggedInEmail == "admin123@gmail.com";
  List<dynamic> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);

    try {
      if (loggedInEmail == null) return;

      final data = await ReservationService.getReservations(loggedInEmail!);

      setState(() {
        _reservations = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  List<dynamic> get _filteredReservations {
    if (_isAdmin) {
      return _reservations
          .where(
              (res) => res['isResponse'] == false && res['isResponse'] == true)
          .toList();
    } else {
      return _reservations.where((res) {
        return res['user_email'] == loggedInEmail && res['isResponse'] == true;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            BottomBar(currentIndex: 2, ordersCount: orders.length),
        appBar: customAppBar(
          title: _isAdmin ? "Reservations" : "My Responses",
          leadingIcon: Icons.notifications,
        ),
        body: Container(
          decoration: const BoxDecoration(color: Color(0xFFE1DBBD)),
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    if (_filteredReservations.isEmpty)
                      Center(
                        child: Text(
                          _isAdmin
                              ? "No reservation requests"
                              : "No responses yet",
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'HvDTrial Brandon Grotesque',
                          ),
                        ),
                      )
                    else
                      ..._filteredReservations.map((reservation) {
                        final isViewed =
                            _viewedNotifications.contains(reservation['_id']);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _viewedNotifications.add(reservation['_id']);
                            });
                            _showReservationDetailsDialog(context, reservation);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isViewed
                                  ? Colors.white
                                  : const Color(0xFFFFF8E1),
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
                                  _isAdmin
                                      ? "New Request - ${reservation['objective']}"
                                      : "Response - ${reservation['objective']}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'HvDTrial Brandon Grotesque',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Period: ${reservation['start_date']} to ${reservation['end_date']}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'HvDTrial Brandon Grotesque',
                                  ),
                                ),
                                if (_isAdmin) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    "From: ${reservation['user_email']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'HvDTrial Brandon Grotesque',
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    "Status: ${reservation['admin_response']}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _getStatusColor(
                                          reservation['admin_response']),
                                      fontFamily: 'HvDTrial Brandon Grotesque',
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _formatTimeAgo(DateTime.parse(
                                        reservation['createdAt'])),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontFamily: 'HvDTrial Brandon Grotesque',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('approved')) return Colors.green;
    if (status.toLowerCase().contains('rejected')) return Colors.red;
    if (status.toLowerCase().contains('processed')) return Colors.orange;
    return Colors.grey;
  }

  void _showReservationDetailsDialog(
      BuildContext context, Map<String, dynamic> reservation) {
    final TextEditingController _responseController =
        TextEditingController(text: reservation['admin_response'] ?? '');

    showDialog(
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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isAdmin
                                ? "Reservation Request"
                                : "Response Details",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'HvDTrial Brandon Grotesque',
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                              "User Email:", reservation['user_email']),
                          _buildDetailRow(
                              "Objective:", reservation['objective']),
                          _buildDetailRow("Period:",
                              "${reservation['start_date']} to ${reservation['end_date']}"),
                          if (reservation['Comment'] != null &&
                              reservation['Comment'].isNotEmpty)
                            _buildDetailRow(
                                "Comments:", reservation['Comment']),
                          const SizedBox(height: 10),
                          Text(
                            "Materials:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'HvDTrial Brandon Grotesque',
                            ),
                          ),
                          const SizedBox(height: 5),
                          ..._buildMaterialList(reservation['material_list']),
                          if (_isAdmin) ...[
                            const SizedBox(height: 15),
                            TextField(
                              controller: _responseController,
                              decoration: InputDecoration(
                                labelText: 'Admin Response',
                                border: OutlineInputBorder(),
                                hintText: 'Enter your response message...',
                                isDense: true,
                              ),
                              maxLines: 4,
                              minLines: 2,
                            ),
                            const SizedBox(height: 20),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_isAdmin) ...[
                                TextButton(
                                  onPressed: () => _updateReservation(
                                      reservation,
                                      'Rejected',
                                      _responseController.text),
                                  child: const Text("REJECT"),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC800),
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () => _updateReservation(
                                      reservation,
                                      'Approved',
                                      _responseController.text),
                                  child: const Text("APPROVE"),
                                ),
                              ] else ...[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC800),
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("CLOSE"),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }

// Modify your update method
  Future<void> _updateReservation(
    Map<String, dynamic> reservation,
    String status,
    String responseMessage,
  ) async {
    try {
      await ReservationService.updateReservation(
        reservation['_id'],
        status,
        responseMessage,
      );

      await _loadReservations();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation $status successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildDetailRow(String label, String value,
      {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'HvDTrial Brandon Grotesque',
              color: isImportant ? Colors.black : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'HvDTrial Brandon Grotesque',
                color: isImportant ? _getStatusColor(value) : null,
                fontWeight: isImportant ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMaterialList(Map<String, dynamic> materials) {
    return materials.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          "- ${entry.key}: ${entry.value}",
          style: const TextStyle(
            fontFamily: 'HvDTrial Brandon Grotesque',
          ),
        ),
      );
    }).toList();
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return "Just now";
    if (difference.inMinutes < 60) return "${difference.inMinutes} min ago";
    if (difference.inHours < 24) return "${difference.inHours} hours ago";
    if (difference.inDays < 7) return "${difference.inDays} days ago";

    return DateFormat('MMM d, y').format(date);
  }
}
