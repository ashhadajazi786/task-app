import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<FormState> _signupkey = GlobalKey<FormState>();
  final TextEditingController UserNameController = TextEditingController();
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();

  bool _obscurePassword = true; // 👁️ Toggle state for password visibility

  var users = FirebaseFirestore.instance.collection("users");

  void RegisterUser() async {
    if (_signupkey.currentState!.validate()) {
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: EmailController.text,
          password: PasswordController.text,
        );

        users.doc(credential.user!.uid).set({
          'email': EmailController.text,
          'UserName': UserNameController.text,
          'password': PasswordController.text,
          'role': "user",
        }).then((value) {
          EmailController.clear();
          PasswordController.clear();
          UserNameController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Registration Success!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 65, 65, 65),
            ),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to Register"),
              backgroundColor: Colors.red,
            ),
          );
        });
      } on FirebaseAuthException catch (e) {
        String msg = "Something went wrong";
        if (e.code == 'weak-password') {
          msg = 'Password too weak.';
        } else if (e.code == 'email-already-in-use') {
          msg = 'Email already in use.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _signupkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Register to get started",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 25),

                  // Username
                  TextFormField(
                    controller: UserNameController,
                    validator: (value) =>
                        value!.isEmpty ? "Username is required" : null,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.person, color: Colors.black45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Email
                  TextFormField(
                    controller: EmailController,
                    validator: (value) {
                      if (value!.isEmpty) return "Email is required";
                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return "Invalid email format";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.mail, color: Colors.black45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Password
                  TextFormField(
                    controller: PasswordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value!.isEmpty) return "Password is required";
                      if (!RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$')
                          .hasMatch(value)) {
                        return "Must be 8+ chars, include upper, lower,\ndigit & special char.";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock, color: Colors.black45),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black45,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Register Button
                  ElevatedButton(
                    onPressed: RegisterUser,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    child: Text("Register Now"),
                  ),
                  SizedBox(height: 20),

                  // Login redirect
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, "/login"),
                    child: Text(
                      "Already have an account? Login!",
                      style: TextStyle(
                        color: Colors.grey[800],
                        decoration: TextDecoration.underline,
                      ),
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
