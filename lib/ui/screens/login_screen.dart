import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _password = TextEditingController();
  final _otp = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  bool _showOtpStep = false;
  String _pendingEmail = '';
  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _password.dispose();
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final theme = Theme.of(context);

    if (_showOtpStep) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Verify email'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() {
              _showOtpStep = false;
              _otp.clear();
            }),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _otpFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.mark_email_read_outlined,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Check your email',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We sent a 6-digit code to $_pendingEmail',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _otp,
                            decoration: const InputDecoration(
                              labelText: 'Verification code (OTP)',
                              hintText: '000000',
                              prefixIcon: Icon(Icons.pin_outlined),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            validator: (v) {
                              if (v == null || v.trim().length != 6) {
                                return 'Enter the 6-digit code';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _loading
                                ? null
                                : () async {
                                    if (!_otpFormKey.currentState!.validate()) return;
                                    setState(() => _loading = true);
                                    try {
                                      await auth.verifyEmail(
                                        email: _pendingEmail,
                                        otp: _otp.text.trim(),
                                      );
                                      if (context.mounted) Navigator.of(context).pop();
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString()),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) setState(() => _loading = false);
                                    }
                                  },
                            child: _loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Verify & sign in'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Register' : 'Login')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          _isRegister ? Icons.person_add : Icons.login,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isRegister ? 'Create your account' : 'Welcome back',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (_isRegister) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstName,
                                  decoration: const InputDecoration(
                                    labelText: 'First name',
                                    hintText: 'John',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastName,
                                  decoration: const InputDecoration(
                                    labelText: 'Last name',
                                    hintText: 'Doe',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _username,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            hintText: 'Enter username',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Username is required' : null,
                        ),
                        const SizedBox(height: 16),
                        if (_isRegister) ...[
                          TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'your@email.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              final emailReg = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailReg.hasMatch(v.trim())) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'At least 8 characters',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          textInputAction: _isRegister ? TextInputAction.done : TextInputAction.done,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 8) return 'Password must be at least 8 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _loading
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) return;
                                  setState(() => _loading = true);
                                  try {
                                    if (_isRegister) {
                                      final email = await auth.register(
                                        username: _username.text.trim(),
                                        email: _email.text.trim(),
                                        firstName: _firstName.text.trim(),
                                        lastName: _lastName.text.trim(),
                                        password: _password.text,
                                      );
                                      if (context.mounted) {
                                        setState(() {
                                          _pendingEmail = email;
                                          _showOtpStep = true;
                                        });
                                      }
                                    } else {
                                      await auth.login(
                                        username: _username.text.trim(),
                                        password: _password.text,
                                      );
                                      if (context.mounted) Navigator.of(context).pop();
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _loading = false);
                                  }
                                },
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isRegister ? 'Create account' : 'Login'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => setState(() {
                                    _isRegister = !_isRegister;
                                    _showOtpStep = false;
                                    _formKey.currentState?.reset();
                                  }),
                          child: Text(
                            _isRegister ? 'Have an account? Login' : 'New here? Register',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
