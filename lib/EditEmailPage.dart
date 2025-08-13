import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EditProfilePage.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({Key? key}) : super(key: key);

  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _emailController.text = user?.email ?? '';
  }

  Future<void> _saveEmail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final FirebaseAuth auth = FirebaseAuth.instance;
    final newEmail = _emailController.text.trim();
    final currentPassword = _passwordController.text;
    final user = auth.currentUser;

    if (user == null) {
      setState(() {
        _error = 'No user is currently signed in.';
        _loading = false;
      });
      return;
    }

    if (newEmail.isEmpty || currentPassword.isEmpty) {
      setState(() {
        _error = 'Please fill in both email and password.';
        _loading = false;
      });
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await user.verifyBeforeUpdateEmail(newEmail);

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
              controller: _emailController,
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
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: darkTextColor),
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: darkTextColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: darkTextColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: darkTextColor, width: 2),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loading ? null : _saveEmail,
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
