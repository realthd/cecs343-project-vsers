import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vsers/admin/AdminDashboard.dart';
import 'package:vsers/authentication/RegisterPage.dart';
import 'package:vsers/firebase/Authentication.dart';
import 'package:vsers/user/UserDashboard.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 40),
                CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: Image.asset('assets/logo.jpg'),
                    )),
                // Text(
                //   'Fin Mentor',
                //   style: TextStyle(fontSize: 30),
                // ),
                SizedBox(height: 20),
                Text('Log in',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center),
                SizedBox(height: 20),
                LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email";
    }
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a password";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: email,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.alternate_email),
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: password,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                labelText: 'Password',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              obscureText: _obscureText,
              validator: _validatePassword,
            ),
            SizedBox(height: 30),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
              height: 60,
              child: FilledButton(
                // ... existing code ...

                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                      });
                    }

                    var authHelper = AuthenticationHelper();
                    var result = await authHelper.signIn(
                      email: email.text,
                      password: password.text,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    if (result['error'] == null) {
                      bool isAdmin = result['isAdmin'];
                      if (isAdmin) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminDashboard()),
                              (Route<dynamic> route) => false,
                        );
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserDashboard()),
                              (Route<dynamic> route) => false,
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['error'])),
                      );
                    }
                  }
                },
                child: Text('Login'),
              ),
            ),
            TextButton(
              onPressed: () {
                _showForgotPasswordDialog(
                    context); // Call the pop-up for password reset
              },
              child: Text(
                'Forgot Password?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 1),
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  letterSpacing: -0.44999998807907104,
                  fontWeight: FontWeight.normal,
                  height: 1,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero, // Removes default padding
                tapTargetSize: MaterialTapTargetSize
                    .shrinkWrap, // Minimizes the tap target size
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserDashboard()),
                  );
                },
                child: Text('Anonymous Login', style: TextStyle(fontSize:20))),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not a member?',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 2),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  child: Text(
                    'Register Now',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'Raleway',
                      fontSize: 16,
                      letterSpacing: -0.44999998807907104,
                      fontWeight: FontWeight.normal,
                      height: 1,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Removes default padding
                    tapTargetSize: MaterialTapTargetSize
                        .shrinkWrap, // Minimizes the tap target size
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to show a dialog for "Forgot Password"
  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email to reset your password.'),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String email = emailController.text.trim();
              if (email.isNotEmpty) {
                var result = await AuthenticationHelper().resetPassword(email);
                Navigator.of(context).pop(); // Close the dialog
                if (result == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reset link sent to $email')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
              }
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }
}
