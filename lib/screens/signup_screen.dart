import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignupPage> {
  var userNameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Adjust the height as needed
        child: AppBar(
          title: const Text(
            'Register',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.white,
              letterSpacing: 2.0, // Adjust letter spacing as needed
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
          ),
          elevation: 4.0,
          shadowColor: Colors.black54,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 100, 30, 30),
          child: Column(
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 18.0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: userNameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 18.0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 18.0,
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 18.0,
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  var fullName = userNameController.text.trim();
                  var email = emailController.text.trim();
                  var password = passwordController.text.trim();
                  var confirmPass = confirmController.text.trim();

                  if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPass.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please fill all fields');
                    return;
                  }

                  if (password.length < 6) {
                    Fluttertoast.showToast(msg: 'Weak Password, at least 6 characters are required');
                    return;
                  }

                  if (password != confirmPass) {
                    Fluttertoast.showToast(msg: 'Passwords do not match');
                    return;
                  }

                  ProgressDialog progressDialog = ProgressDialog(
                    context,
                    title: const Text('Signing Up'),
                    message: const Text('Please wait'),
                  );

                  progressDialog.show();
                  try {
                    FirebaseAuth auth = FirebaseAuth.instance;

                    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
                        email: email, password: password);

                    if (userCredential.user != null) {
                      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users');

                      String uid = userCredential.user!.uid;
                      int dt = DateTime.now().millisecondsSinceEpoch;

                      await userRef.child(uid).set({
                        'fullName': fullName,
                        'email': email,
                        'uid': uid,
                        'dt': dt,
                        'profileImage': ''
                      });

                      Fluttertoast.showToast(msg: 'Success');
                      progressDialog.dismiss();

                      // Redirect to login page
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      Fluttertoast.showToast(msg: 'Failed');
                      progressDialog.dismiss();
                    }
                  } on FirebaseAuthException catch (e) {
                    progressDialog.dismiss();
                    if (e.code == 'email-already-in-use') {
                      Fluttertoast.showToast(msg: 'Email is already in Use');
                    } else if (e.code == 'weak-password') {
                      Fluttertoast.showToast(msg: 'Password is weak');
                    }
                  } catch (e) {
                    progressDialog.dismiss();
                    Fluttertoast.showToast(msg: 'Something went wrong');
                  }
                },
                child: const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Have an account? Login',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
