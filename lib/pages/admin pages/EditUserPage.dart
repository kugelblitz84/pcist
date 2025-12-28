import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/services/userApi.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  // User details
  late String _name;
  late String _email;
  late String _classroll;
  late String _batch;
  late String _tshirt;
  late String _cfHandle;
  late String _ccHandle;
  late String _atcHandle;
  late String _userId;

  // Role & permissions
  late String _selectedTitle;
  late bool _isAdmin;
  late bool _isTreasurer;
  late bool _membership;

  bool _isActionLoading = false; // For action buttons
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  /// Initialize with full data from user list (get-user-list now provides all fields)
  void _initializeUserData() {
    final user = widget.user;
    _name = user['name'] ?? '';
    _email = user['email'] ?? '';
    _classroll = user['classroll']?.toString() ?? '';
    _batch = user['batch']?.toString() ?? '';
    _tshirt = user['tshirt']?.toString() ?? '';
    _cfHandle = user['cfhandle'] ?? '';
    _ccHandle = user['cchandle'] ?? '';
    _atcHandle = user['atchandle'] ?? '';
    _userId = user['_id'] ?? '';
    _selectedTitle = user['title'] ?? 'Member';
    _isAdmin = user['role'] == 2;
    _isTreasurer = user['treasurer'] ?? false;
    _membership = user['membership'] ?? false;
  }

  Future<void> _updateTitle() async {
    setState(() {
      _isActionLoading = true;
      _errorMessage = null;
    });

    try {
      final tokenData = await Tokenprocess.readToken();
      final token = tokenData['authToken'];
      final adminSlug = tokenData['slug'];

      final response = await UserAPI.updateUserTitle(
        token: token ?? '',
        adminSlug: adminSlug ?? '',
        userId: _userId,
        title: _selectedTitle,
      );

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            'Success',
            'Title updated to ${_getTitleFullName(_selectedTitle)}',
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to update title';
          });
        }
      } else {
        final errorBody = response != null ? jsonDecode(response.body) : {};
        setState(() {
          _errorMessage = errorBody['message'] ?? 'Failed to update title';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isActionLoading = false;
      });
    }
  }

  Future<void> _toggleAdmin() async {
    final tokenData = await Tokenprocess.readToken();
    final currentSlug = tokenData['slug'];

    // Prevent self-demotion
    if (widget.user['slug'] == currentSlug && _isAdmin) {
      Get.snackbar(
        'Not Allowed',
        'You cannot demote yourself from admin',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isActionLoading = true;
      _errorMessage = null;
    });

    try {
      final token = tokenData['authToken'];
      final adminSlug = tokenData['slug'];

      final response = await UserAPI.toggleAdminStatus(
        token: token ?? '',
        adminSlug: adminSlug ?? '',
        userId: _userId,
        isAdmin: !_isAdmin,
      );

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _isAdmin = !_isAdmin;
          });
          Get.snackbar(
            'Success',
            _isAdmin ? 'User promoted to admin' : 'User demoted from admin',
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to toggle admin status';
          });
        }
      } else {
        final errorBody = response != null ? jsonDecode(response.body) : {};
        setState(() {
          _errorMessage =
              errorBody['message'] ?? 'Failed to toggle admin status';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isActionLoading = false;
      });
    }
  }

  Future<void> _toggleTreasurer() async {
    setState(() {
      _isActionLoading = true;
      _errorMessage = null;
    });

    try {
      final tokenData = await Tokenprocess.readToken();
      final token = tokenData['authToken'];
      final adminSlug = tokenData['slug'];

      final response = await UserAPI.toggleTreasurerStatus(
        token: token ?? '',
        adminSlug: adminSlug ?? '',
        userId: _userId,
        isTreasurer: !_isTreasurer,
      );

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _isTreasurer = !_isTreasurer;
          });
          Get.snackbar(
            'Success',
            _isTreasurer
                ? 'Treasurer access granted'
                : 'Treasurer access revoked',
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          setState(() {
            _errorMessage =
                data['message'] ?? 'Failed to toggle treasurer status';
          });
        }
      } else {
        final errorBody = response != null ? jsonDecode(response.body) : {};
        setState(() {
          _errorMessage =
              errorBody['message'] ?? 'Failed to toggle treasurer status';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isActionLoading = false;
      });
    }
  }

  Future<void> _toggleMembership(bool newValue) async {
    if (newValue) {
      // Ask for duration in months if enabling membership
      int? selectedMonths = await showDialog<int>(
        context: context,
        builder: (context) {
          int? selected;
          return AlertDialog(
            title: const Text("Select Membership Duration"),
            content: StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  int month = index + 1;
                  return RadioListTile<int>(
                    title: Text("$month Month${month > 1 ? 's' : ''}"),
                    value: month,
                    groupValue: selected,
                    onChanged: (value) {
                      setState(() => selected = value);
                    },
                  );
                }),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                child: const Text("Confirm"),
              ),
            ],
          );
        },
      );

      // Cancel if no selection
      if (selectedMonths == null) return;

      setState(() => _isActionLoading = true);

      try {
        final uri = Uri.http(
          Secret.siteLink,
          '/api/v1/user/update-membership-status/$_userId',
        );
        final tokenData = await Tokenprocess.readToken();
        final token = tokenData['authToken'];
        final slug = tokenData['slug'];
        final header = {
          "Content-type": "application/json",
          "authorization": "Bearer $token",
        };

        final body = jsonEncode({
          "slug": slug,
          "membership": true,
          "durationInMonths": selectedMonths,
        });

        final response = await http.post(uri, headers: header, body: body);

        if (response.statusCode == 200) {
          setState(() => _membership = true);
          Get.snackbar(
            'Success',
            'Membership enabled for $selectedMonths month${selectedMonths > 1 ? 's' : ''}',
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar("Error", "Something went wrong ${response.statusCode}");
        }
      } catch (e) {
        setState(() => _membership = false);
        Get.snackbar("Error", "Error updating membership");
      } finally {
        setState(() => _isActionLoading = false);
      }
    } else {
      // Directly disable without prompt
      setState(() => _isActionLoading = true);

      try {
        final uri = Uri.http(
          Secret.siteLink,
          '/api/v1/user/update-membership-status/$_userId',
        );
        final tokenData = await Tokenprocess.readToken();
        final token = tokenData['authToken'];
        final slug = tokenData['slug'];
        final header = {
          "Content-type": "application/json",
          "authorization": "Bearer $token",
        };

        final body = jsonEncode({"slug": slug, "membership": false});

        final response = await http.post(uri, headers: header, body: body);

        if (response.statusCode == 200) {
          setState(() => _membership = false);
          Get.snackbar(
            'Success',
            'Membership disabled',
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar("Error", "Something went wrong ${response.statusCode}");
        }
      } catch (e) {
        setState(() => _membership = true);
        Get.snackbar("Error", "Error updating membership");
      } finally {
        setState(() => _isActionLoading = false);
      }
    }
  }

  String _getTitleFullName(String title) {
    switch (title) {
      case 'GS':
        return 'General Secretary';
      case 'JS':
        return 'Joint Secretary';
      case 'OS':
        return 'Organizing Secretary';
      default:
        return 'Member';
    }
  }

  Color _getTitleColor(String title) {
    switch (title) {
      case 'GS':
        return const Color(0xFFD4AF37); // Gold
      case 'JS':
        return const Color(0xFF7B7B7B); // Silver/Gray
      case 'OS':
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepOrange),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(144, 148, 201, 241),
              Color.fromARGB(143, 248, 146, 87),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromARGB(255, 211, 119, 44),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User Info Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.deepOrange,
                        child: Text(
                          _name.isNotEmpty
                              ? _name.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name.isNotEmpty ? _name : 'Unknown User',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _email.isNotEmpty ? _email : 'N/A',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ==================== USER DETAILS SECTION ====================
                  _buildSectionHeader('User Details', Icons.person),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Class Roll', _classroll),
                        _buildDetailRow('Batch', _batch),
                        _buildDetailRow('T-Shirt', _tshirt),
                        _buildDetailRow('Codeforces', _cfHandle),
                        _buildDetailRow('CodeChef', _ccHandle),
                        _buildDetailRow('AtCoder', _atcHandle),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ==================== MEMBERSHIP SECTION ====================
                  _buildSectionHeader('Membership', Icons.card_membership),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _membership
                          ? Colors.teal.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _membership
                            ? Colors.teal.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _membership
                              ? Icons.verified_user
                              : Icons.person_off_outlined,
                          color: _membership ? Colors.teal : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _membership ? 'Active Member' : 'Inactive',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _membership
                                      ? Colors.teal
                                      : Colors.grey[700],
                                ),
                              ),
                              Text(
                                _membership
                                    ? 'Membership is currently active'
                                    : 'User does not have active membership',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isActionLoading
                              ? null
                              : () => _toggleMembership(!_membership),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _membership
                                ? Colors.red
                                : Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            _membership ? 'Disable' : 'Enable',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ==================== TITLE SECTION ====================
                  _buildSectionHeader('Organizational Title', Icons.badge),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTitle,
                        isExpanded: true,
                        items: ['GS', 'JS', 'OS', 'Member'].map((title) {
                          return DropdownMenuItem(
                            value: title,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getTitleColor(title),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(_getTitleFullName(title)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _isActionLoading
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedTitle = value;
                                  });
                                }
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedTitle == 'GS')
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Note: Only one user can hold the GS title. Previous GS will be demoted to Member.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isActionLoading ? null : _updateTitle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isActionLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update Title'),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ==================== ADMIN ACCESS SECTION ====================
                  _buildSectionHeader(
                    'Admin Access',
                    Icons.admin_panel_settings,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isAdmin
                          ? Colors.indigo.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isAdmin
                            ? Colors.indigo.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isAdmin
                              ? Icons.admin_panel_settings
                              : Icons.person_outline,
                          color: _isAdmin ? Colors.indigo : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isAdmin ? 'Admin' : 'Regular User',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _isAdmin
                                      ? Colors.indigo
                                      : Colors.grey[700],
                                ),
                              ),
                              Text(
                                _isAdmin
                                    ? 'Full access to all admin features'
                                    : 'Standard member privileges',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isActionLoading ? null : _toggleAdmin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isAdmin
                                ? Colors.red
                                : Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            _isAdmin ? 'Disable Admin' : 'Enable Admin',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ==================== TREASURER ACCESS SECTION ====================
                  _buildSectionHeader(
                    'Treasurer Access',
                    Icons.account_balance_wallet,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isTreasurer
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isTreasurer
                            ? Colors.green.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isTreasurer
                              ? Icons.account_balance_wallet
                              : Icons.account_balance_wallet_outlined,
                          color: _isTreasurer ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isTreasurer ? 'Treasurer' : 'Not a Treasurer',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _isTreasurer
                                      ? Colors.green
                                      : Colors.grey[700],
                                ),
                              ),
                              Text(
                                _isTreasurer
                                    ? 'Can generate and send invoices'
                                    : 'No invoice generation privileges',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isActionLoading ? null : _toggleTreasurer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTreasurer
                                ? Colors.red
                                : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            _isTreasurer ? 'Disable' : 'Enable',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Permission Notes:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Admins have full access to all features\n'
                          '• Treasurers can only generate/send invoices\n'
                          '• Titles are organizational positions (GS, JS, OS)\n'
                          '• Only one user can be General Secretary at a time',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
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
