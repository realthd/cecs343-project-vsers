import 'package:flutter/material.dart';
import 'package:vsers/admin/AdminDashboard.dart';
import 'package:vsers/components/workoutGoals.dart';
import 'package:vsers/firebase/Authentication.dart';
import 'package:vsers/user/UserDashboard.dart';
import "package:vsers/components/globals.dart" as globals;
class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

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
                Text(
                  'Register',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                RegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isAdmin = false;

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

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a username";
    }
    if (value.length < 6) {
      return "Username must be at least 6 characters long";
    }
    return null;
  }
  String? _validateFirstname(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Firstname";
    }
    return null;
  }
  String? _validateLastname(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Lastname";
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
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
              ),
              validator: _validateFirstname,
            ),
            SizedBox(height: 20,),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
              ),
              validator: _validateLastname,
            ),
            SizedBox(height: 20,),
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
              ),
              validator: _validateUsername,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
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
              controller: passwordController,
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
                  child: Icon(_obscureText
                      ? Icons.visibility_off
                      : Icons.visibility),
                ),
              ),
              obscureText: _obscureText,
              validator: _validatePassword,
            ),
            SizedBox(height: 30),
            CheckboxListTile(
              title: Text('Register as Admin'),
              value: _isAdmin,
              onChanged: (bool? value) {
                setState(() {
                  _isAdmin = value ?? false;
                });
              },
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
                    setState(() {
                      _isLoading = true;
                    });
                    var authHelper = AuthenticationHelper();
                    var result = await authHelper.signUp(
                      email: emailController.text,
                      firstname: firstNameController.text,
                      lastname: lastNameController.text,
                      password: passwordController.text,
                      username: usernameController.text,
                      isAdmin: _isAdmin,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    if (result['error'] == null) {
                      bool isAdmin = result['isAdmin'];
                      if (isAdmin) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => AdminDashboard()),
                              (Route<dynamic> route) => false,
                        );
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) =>  globals.isWorkoutGoalsSetup ? UserDashboard(): WorkoutGoalsPage()),
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
                child: Text('Register'),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('or continue with'),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already a member?',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 2),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Login',
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
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({required String assetName, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        assetName,
        width: 48,
        height: 48,
      ),
    );
  }
}