import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleCreateAccount() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to the Terms of Service',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      // TODO: Implement actual registration
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isTablet = maxWidth > 600;
        final formMaxWidth = isTablet ? 440.0 : maxWidth * 0.92;
        final logoSize = isTablet ? 72.0 : 56.0;
        final titleSize = isTablet ? 32.0 : 26.0;
        final spacing = isTablet ? 24.0 : 20.0;

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0F),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: (maxWidth - formMaxWidth) / 2,
                  vertical: isTablet ? 48 : 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PhosphorIcons.arrowLeft(
                              PhosphorIconsStyle.light,
                              size: 24,
                              color: const Color(0xFFA0A0A0),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 12 : 8),

                      // App logo
                      Center(
                        child: Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(logoSize * 0.28),
                            border: Border.all(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: PhosphorIcons.filmStrip(
                              PhosphorIconsStyle.light,
                              size: logoSize * 0.45,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 32 : 24),

                      // Heading
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start creating amazing videos today',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: isTablet ? 15 : 14,
                          color: const Color(0xFFA0A0A0),
                        ),
                      ),

                      SizedBox(height: spacing * 1.5),

                      // Card container
                      Container(
                        padding: EdgeInsets.all(isTablet ? 32 : 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Name field
                            _buildTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'John Doe',
                              keyboardType: TextInputType.name,
                              icon: PhosphorIcons.user(
                                PhosphorIconsStyle.light,
                                size: 20,
                              ),
                              isTablet: isTablet,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                if (value.trim().length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: spacing * 0.75),

                            // Email field
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'you@example.com',
                              keyboardType: TextInputType.emailAddress,
                              icon: PhosphorIcons.envelopeSimple(
                                PhosphorIconsStyle.light,
                                size: 20,
                              ),
                              isTablet: isTablet,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value.trim())) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: spacing * 0.75),

                            // Password field
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              obscureText: _obscurePassword,
                              icon: PhosphorIcons.lockSimple(
                                PhosphorIconsStyle.light,
                                size: 20,
                              ),
                              isTablet: isTablet,
                              suffixIcon: GestureDetector(
                                onTap: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword
                                      ? PhosphorIcons.eyeClosed(
                                          PhosphorIconsStyle.light,
                                          size: 20,
                                        )
                                      : PhosphorIcons.eye(
                                          PhosphorIconsStyle.light,
                                          size: 20,
                                        ),
                                  color: const Color(0xFFA0A0A0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                                  return 'Include at least one uppercase letter';
                                }
                                if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
                                  return 'Include at least one number';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: spacing * 0.75),

                            // Confirm password field
                            _buildTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hint: '••••••••',
                              obscureText: _obscureConfirmPassword,
                              icon: PhosphorIcons.lockSimple(
                                PhosphorIconsStyle.light,
                                size: 20,
                              ),
                              isTablet: isTablet,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
                                child: Icon(
                                  _obscureConfirmPassword
                                      ? PhosphorIcons.eyeClosed(
                                          PhosphorIconsStyle.light,
                                          size: 20,
                                        )
                                      : PhosphorIcons.eye(
                                          PhosphorIconsStyle.light,
                                          size: 20,
                                        ),
                                  color: const Color(0xFFA0A0A0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: spacing * 0.75),

                            // Terms checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (value) {
                                      setState(() => _agreeToTerms = value ?? false);
                                    },
                                    activeColor: const Color(0xFF3B82F6),
                                    checkColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _agreeToTerms = !_agreeToTerms);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 1),
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'I agree to the ',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: const Color(0xFFA0A0A0),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Terms of Service',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF3B82F6),
                                              ),
                                            ),
                                            const TextSpan(text: ' and '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF3B82F6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: spacing * 0.75),

                            // Create Account button
                            SizedBox(
                              height: isTablet ? 54 : 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleCreateAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      const Color(0xFF3B82F6).withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Create Account',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: spacing * 1.2),

                      // Sign in link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.inter(
                              fontSize: isTablet ? 15 : 14,
                              color: const Color(0xFFA0A0A0),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.inter(
                                fontSize: isTablet ? 15 : 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isTablet ? 32 : 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isTablet,
    required String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? icon,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFA0A0A0),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: isTablet ? 16 : 15,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: isTablet ? 16 : 15,
              color: const Color(0xFF505055),
            ),
            prefixIcon: icon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: IconTheme(
                      data: const IconThemeData(color: Color(0xFF505055)),
                      child: icon,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: const Color(0xFF141418),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isTablet ? 16 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
            errorStyle: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFFEF4444),
            ),
          ),
        ),
      ],
    );
  }
}
