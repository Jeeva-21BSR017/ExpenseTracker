import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.put(AuthController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _tryRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      _authController.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.92;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,

        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF071032)],
                ),
              ),
            ),

            Positioned(
              top: -70,
              left: -70,
              child: Container(
                width: 200,
                height: 200,
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

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height:
                          kToolbarHeight +
                          MediaQuery.of(context).padding.top / 2,
                    ),

                    // Header
                    Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.85),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.28),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),

                    const SizedBox(height: 22),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: cardWidth,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputField(
                                  controller: _nameController,
                                  label: 'Full name',
                                  icon: Icons.person_outline,
                                  validator: (v) =>
                                      (v == null || v.trim().length < 2)
                                      ? 'Enter your name'
                                      : null,
                                ),

                                const SizedBox(height: 12),

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

                                _buildInputField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: 'At least 6 characters',
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

                                const SizedBox(height: 12),

                                _buildInputField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  obscureText: _obscurePassword,
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Please confirm password';
                                    if (v != _passwordController.text)
                                      return 'Passwords do not match';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

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
                                            onPressed: _tryRegister,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              elevation: 6,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),

                                const SizedBox(height: 12),

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

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Already have an account?',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Get.toNamed(AppRoutes.login),
                                      child: const Text(
                                        'Login',
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
