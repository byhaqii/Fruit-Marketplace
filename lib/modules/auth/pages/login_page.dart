// lib/modules/auth/pages/login_page.dart
import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // HEADER with gradient overlay + subtle branding
            SizedBox(
              height: size.height * 0.42,
              width: size.width,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  const Image(
                    image: AssetImage('assets/fruit_background.jpg'),
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xCC2D7F6A), Color(0x992D7F6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Title
                  Positioned(
                    left: 24,
                    bottom: 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hello!',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Welcome to Fruitify',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // FORM CARD with curved top & shadow
            Transform.translate(
              offset: const Offset(0, -32),
              child: Container(
                width: size.width,
                constraints: BoxConstraints(minHeight: size.height * 0.62),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + subtitle
                      Row(
                        children: const [
                          Icon(Icons.lock_outline, color: Color(0xFF2D7F6A)),
                          SizedBox(width: 8),
                          Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFF2D7F6A),
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login form
                      const LoginForm(),

                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'By continuing, you agree to our Terms & Privacy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.45),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
