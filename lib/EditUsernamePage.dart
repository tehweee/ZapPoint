import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EditProfilePage.dart';

class ChangeUsernameScreen extends StatefulWidget {
  const ChangeUsernameScreen({Key? key}) : super(key: key);

  @override
  _ChangeUsernameScreenState createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _usernameController.text = user?.displayName ?? '';
  }

  Future<void> _saveUsername() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final FirebaseAuth auth = FirebaseAuth.instance;
    final newDisplayName = _usernameController.text.trim();
    final user = auth.currentUser;
    await user?.updateDisplayName(newDisplayName ?? "User");
    if (user == null) {
      setState(() {
        _error = 'No user is currently signed in.';
        _loading = false;
      });
      return;
    }

    try {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EditAccountScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00BFFF);
    const Color darkTextColor = Color(0xFF1A1A40);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkTextColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EditAccountScreen()),
            );
          },
        ),
        title: const Text(
          'Change Email',
          style: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: darkTextColor),
              decoration: InputDecoration(
                labelText: 'New Email',
                labelStyle: TextStyle(color: darkTextColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: darkTextColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: darkTextColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loading ? null : _saveUsername,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkTextColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
