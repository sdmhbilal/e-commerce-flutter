import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _email;
  late TextEditingController _emailOtp;
  bool _saving = false;
  bool _showEmailOtpStep = false;
  String _pendingNewEmail = '';
  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = context.read<AuthProvider>().userProfile;
    _firstName = TextEditingController(text: (p?['first_name'] ?? '').toString());
    _lastName = TextEditingController(text: (p?['last_name'] ?? '').toString());
    _email = TextEditingController(text: (p?['email'] ?? '').toString());
    _emailOtp = TextEditingController();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _emailOtp.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = await context.read<AuthProvider>().updateProfile(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          );
      if (!mounted) return;
      final pendingEmail = data['pending_email']?.toString().trim();
      if (pendingEmail != null && pendingEmail.isNotEmpty) {
        setState(() {
          _pendingNewEmail = pendingEmail;
          _showEmailOtpStep = true;
          _emailOtp.clear();
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']?.toString() ?? 'Check your new email for the code.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _verifyEmailChange() async {
    final otp = _emailOtp.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter the code from your email'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().verifyEmailChange(
            newEmail: _pendingNewEmail,
            otp: otp,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _showEmailOtpStep = false;
        _pendingNewEmail = '';
        _email.text = context.read<AuthProvider>().userProfile?['email']?.toString() ?? _email.text;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    if (_showEmailOtpStep) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Verify new email'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() {
              _showEmailOtpStep = false;
              _pendingNewEmail = '';
              _emailOtp.clear();
            }),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
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
                            'Verify your new email',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We sent a code to $_pendingNewEmail',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailOtp,
                            decoration: const InputDecoration(
                              labelText: 'Verification code',
                              hintText: '000000',
                              prefixIcon: Icon(Icons.pin_outlined),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            onFieldSubmitted: (_) => _verifyEmailChange(),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _saving ? null : _verifyEmailChange,
                            child: _saving
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Verify & update email'),
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
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _firstName,
              decoration: const InputDecoration(
                labelText: 'First name',
                hintText: 'John',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastName,
              decoration: const InputDecoration(
                labelText: 'Last name',
                hintText: 'Doe',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'your@email.com',
                prefixIcon: Icon(Icons.email_outlined),
                helperText: 'Changing email requires verification',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                final r = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!r.hasMatch(v.trim())) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Username: ${auth.userProfile?['username'] ?? ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _saveProfile,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
