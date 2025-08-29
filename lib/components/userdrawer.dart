import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({Key? key}) : super(key: key);

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  String userName = 'Guest';
  String userEmail = 'Not Logged In';
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final data = doc.data();
        setState(() {
          isLoggedIn = true;
          userName = data?['username'] ?? user.displayName ?? 'User';
          userEmail = data?['email'] ?? user.email ?? 'No Email';
        });
      } catch (e) {
        print("Error fetching user details: $e");
      }
    }
  }

  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  void loginUser() {
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Stack(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.black),
                accountName: Text(
                  userName,
                  style: TextStyle(color: Colors.white),
                ),
                accountEmail: Text(
                  userEmail,
                  style: TextStyle(color: Colors.white),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.grey, size: 40),
                ),
              ),
              if (isLoggedIn)
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, "/userdetails");
                    },
                  ),
                ),
            ],
          ),

          ListTile(
            leading: Icon(Icons.home, color: Colors.black),
            title: Text("Home"),
            onTap: () => Navigator.pushNamed(context, "/home"),
          ),

          Spacer(),
          Divider(),

          isLoggedIn
              ? ListTile(
                  leading: Icon(Icons.logout, color: Colors.black),
                  title: Text("Logout"),
                  onTap: logoutUser,
                )
              : ListTile(
                  leading: Icon(Icons.login, color: Colors.black),
                  title: Text("Login"),
                  onTap: loginUser,
                ),
        ],
      ),
    );
  }
}
