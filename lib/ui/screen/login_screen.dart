import 'package:flutter/material.dart';
import '../../utils/assets_path.dart';
import 'auth_screen.dart';

class SignInScreen extends StatefulWidget {
  static const String name = '/';

  SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();

}

class _SignInScreenState extends State<SignInScreen> {

  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final bool _isGoogleLoading = false;


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.1),
                Text(
                  "Login Now",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: 30),
                _buildEmailPasswordForm(),
                SizedBox(height: 25),
                _buildEmailSignInButton(),
                SizedBox(height: 15),
                _buildDivider(),
                SizedBox(height: 15),
                _buildGoogleSignInButton(context),
                SizedBox(height: size.height * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }


  //===================================================
  //=====================Method area==============================
  //===================================================

  Widget _buildEmailPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailTEController,
            decoration: InputDecoration(
              hintText: 'Enter email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) =>
            value?.isEmpty ?? true
                ? 'Enter valid email'
                : null,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _passwordTEController,
            decoration: InputDecoration(
              hintText: 'Enter Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSignInButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleEmailSignIn,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      child: _isLoading
          ? SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : Text("Login"),
    );
  }

  Future<void> _handleEmailSignIn() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {} catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        UserController.loginWithGoogle(context: context);
        setState(() {});
      },

      icon: _isGoogleLoading
          ? SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: Colors.black,
          strokeWidth: 2,
        ),
      )
          : Image.asset(AssetsPath.googleIcon, height: 24),
      label: Text(_isGoogleLoading ? "Signing in..." : "Sign in with Google"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: Size(double.infinity, 50),
        elevation: 2,
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("OR", style: TextStyle(color: Colors.grey)),
        ), // This comma was missing
        Expanded(child: Divider(thickness: 1)),
      ],
    );
  }


  //===================================================
  //=====================Method area end==============================
  //===================================================


  @override
  void dispose() {
    _emailTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }

}