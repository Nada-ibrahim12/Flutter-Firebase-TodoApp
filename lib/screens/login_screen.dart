import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'signup_screen.dart';
import 'todo_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          title: const Text(
            'Login',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.white,
              letterSpacing: 2.0,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              ElevatedButton(
                onPressed: () async {
                  var email = emailController.text.trim();
                  var password = passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please fill all fields');
                    return;
                  }

                  ProgressDialog progressDialog = ProgressDialog(
                    context,
                    title: const Text('Logging In'),
                    message: const Text('Please wait'),
                  );

                  progressDialog.show();

                  try {
                    FirebaseAuth auth = FirebaseAuth.instance;

                    UserCredential userCredential =
                        await auth.signInWithEmailAndPassword(
                            email: email, password: password);

                    progressDialog.dismiss();

                    if (userCredential.user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TodoScreen()),
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    progressDialog.dismiss();

                    if (e.code == 'user-not-found') {
                      Fluttertoast.showToast(msg: 'User not found');
                    } else if (e.code == 'wrong-password') {
                      Fluttertoast.showToast(msg: 'Wrong password');
                    } else {
                      Fluttertoast.showToast(msg: 'Something went wrong');
                    }
                  } catch (e) {
                    progressDialog.dismiss();
                    Fluttertoast.showToast(msg: 'Something went wrong');
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not Registered Yet?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupPage()),
                      );
                    },
                    child: const Text(
                      'Signup',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
