import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/routes.dart';
import '../../utils/app_colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.put(AuthController());

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _tryLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _authController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.92;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF0B2545)],
                ),
              ),
            ),

            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.34),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ExpenseTracker',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Frosted glass card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: cardWidth,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Sign in to continue to your account',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // Email
                                _buildInputField(
                                  controller: _emailController,
                                  label: 'Email',
                                  hint: 'user@gmail.com',
                                  icon: Icons.email_outlined,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Please enter email';
                                    if (!GetUtils.isEmail(v.trim()))
                                      return 'Enter a valid email';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 12),

                                // Password
                                _buildInputField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: 'Minimum 6 characters',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  obscureText: _obscurePassword,
                                  trailing: IconButton(
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Please enter password';
                                    if (v.length < 6)
                                      return 'Password should be at least 6 characters';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 6),

                                const SizedBox(height: 10),

                                // Login button or loading
                                Obx(
                                  () => _authController.isLoading.value
                                      ? const SizedBox(
                                          height: 48,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: _tryLogin,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              elevation: 6,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                            ),
                                            child: const Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  children: const [
                                    Expanded(
                                      child: Divider(color: Colors.white12),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(color: Colors.white60),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(color: Colors.white12),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Social sign-in
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _authController.loginWithGoogle(),
                                    icon: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.g_mobiledata,
                                        color: Colors.black,
                                      ),
                                    ),
                                    label: const Text(
                                      'Continue with Google',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.white12,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Register link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'New here?',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Get.toNamed(AppRoutes.register),
                                      child: const Text(
                                        'Create account',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    Widget? trailing,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            keyboardType: isPassword
                ? TextInputType.visiblePassword
                : TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white70),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              suffixIcon: trailing,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
