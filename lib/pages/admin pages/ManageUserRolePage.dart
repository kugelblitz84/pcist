import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/services/userApi.dart';
import 'dart:convert';

class ManageUserRolePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const ManageUserRolePage({super.key, required this.user});

  @override
  State<ManageUserRolePage> createState() => _ManageUserRolePageState();
}

class _ManageUserRolePageState extends State<ManageUserRolePage> {
  late String _selectedTitle;
  late bool _isAdmin;
  late bool _isTreasurer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedTitle = widget.user['title'] ?? 'Member';
    _isAdmin = widget.user['role'] == 2;
    _isTreasurer = widget.user['treasurer'] ?? false;
  }

  Future<void> _updateTitle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tokenData = await Tokenprocess.readToken();
      final token = tokenData['authToken'];
      final adminSlug = tokenData['slug'];
      final userId = widget.user['_id'];

      final response = await UserAPI.updateUserTitle(
        token: token ?? '',
        adminSlug: adminSlug ?? '',
        userId: userId,
        title: _selectedTitle,
      );

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            'Success',
            'Title updated to $_selectedTitle',
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
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAdmin() async {
    // Prevent self-demotion
    final tokenData = await Tokenprocess.readToken();
    final currentSlug = tokenData['slug'];
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
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = tokenData['authToken'];
      final adminSlug = tokenData['slug'];
      final userId = widget.user['_id'];

      final response = await UserAPI.toggleAdminStatus(
        token: token ?? '',
        adminSlug: adminSlug ?? '',
        userId: userId,
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
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTreasurer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tokenData = await Tokenprocess.readToken();
      final token = tokenData['authToken'];
      final adminSlug = tokenData['slug'];
      final userId = widget.user['_id'];

      final response = await UserAPI.toggleTreasurerStatus(
        token: token ?? '',
        adminSlug: adminSlug ?? '',
        userId: userId,
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
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final userName = widget.user['name'] ?? 'Unknown User';
    final userEmail = widget.user['email'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage User Role'),
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
                          userName.isNotEmpty
                              ? userName.substring(0, 1).toUpperCase()
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
                              userName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userEmail,
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

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

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

                  // Title Section
                  const Text(
                    'Organizational Title',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        onChanged: _isLoading
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
                      onPressed: _isLoading ? null : _updateTitle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
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

                  // Admin Toggle
                  const Text(
                    'Admin Access',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                          onPressed: _isLoading ? null : _toggleAdmin,
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
                            _isAdmin ? 'Disable' : 'Enable',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Treasurer Toggle
                  const Text(
                    'Treasurer Access',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        Switch(
                          value: _isTreasurer,
                          onChanged: _isLoading
                              ? null
                              : (_) => _toggleTreasurer(),
                          activeColor: Colors.green,
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
