import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  String email = '';
  bool loading = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // simple fade animation
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email ?? '';
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        usernameController.text = data['username'] ?? '';
      }
    }
    setState(() => loading = false);
    _controller.forward();
  }

  Future<void> _saveAll() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'username': usernameController.text,
          'email': email,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Saved Successfully")));
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget buildUsernameField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: usernameController,
            readOnly: true,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: "Username",
              prefixIcon: Icon(Icons.person),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.black),
          onPressed: () {
            _showUsernameEditModal();
          },
        ),
      ],
    );
  }

  void _showUsernameEditModal() {
    TextEditingController tempController =
        TextEditingController(text: usernameController.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Username"),
        content: TextFormField(
          controller: tempController,
          decoration: const InputDecoration(labelText: "New Username"),
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                usernameController.text = tempController.text;
              });
              Navigator.pop(context);
              _saveAll();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("User Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: email,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildUsernameField(),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _saveAll,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Save Changes",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
