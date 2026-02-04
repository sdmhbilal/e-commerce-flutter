import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../app_config.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

String _displayName(Map<String, dynamic>? p) {
  if (p == null) return '—';
  final first = (p['first_name'] ?? '').toString().trim();
  final last = (p['last_name'] ?? '').toString().trim();
  if (first.isNotEmpty || last.isNotEmpty) return '$first $last'.trim();
  return (p['username'] ?? '—').toString();
}

/// Initials for avatar: "First Last" -> "FL", or username/email fallback (max 2 chars).
String _avatarInitials(Map<String, dynamic>? p) {
  if (p == null) return '?';
  final first = (p['first_name'] ?? '').toString().trim();
  final last = (p['last_name'] ?? '').toString().trim();
  if (first.isNotEmpty && last.isNotEmpty) {
    return '${first[0].toUpperCase()}${last[0].toUpperCase()}';
  }
  if (first.isNotEmpty) return first.length >= 2 ? first.substring(0, 2).toUpperCase() : first.toUpperCase();
  if (last.isNotEmpty) return last.length >= 2 ? last.substring(0, 2).toUpperCase() : last.toUpperCase();
  final username = (p['username'] ?? '').toString().trim();
  if (username.isNotEmpty) return username.length >= 2 ? username.substring(0, 2).toUpperCase() : username.toUpperCase();
  final email = (p['email'] ?? '').toString().trim();
  if (email.isNotEmpty) return email[0].toUpperCase();
  return '?';
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploadingAvatar = false;

  Future<void> _pickAndUploadAvatar(BuildContext context, AuthProvider auth) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take photo'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    setState(() => _uploadingAvatar = true);
    try {
      final xfile = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 85);
      if (xfile == null || !context.mounted) return;
      final bytes = await xfile.readAsBytes();
      final filename = xfile.name.isNotEmpty ? xfile.name : 'avatar.jpg';
      await auth.uploadAvatar(bytes: bytes, filename: filename);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final avatarUrl = auth.userProfile?['avatar_url']?.toString();

    if (!auth.isAuthed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'Not logged in',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                icon: const Icon(Icons.login, size: 20),
                label: const Text('Login / Register'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: auth.profileLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 44,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: _uploadingAvatar
                                      ? Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: theme.colorScheme.onPrimaryContainer,
                                          ),
                                        )
                                      : (avatarUrl != null && avatarUrl.isNotEmpty
                                          ? ClipOval(
                                              child: Image.network(
                                                _absoluteAvatarUrl(avatarUrl),
                                                width: 88,
                                                height: 88,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Text(
                                                  _avatarInitials(auth.userProfile),
                                                  style: theme.textTheme.headlineSmall?.copyWith(
                                                    color: theme.colorScheme.onPrimaryContainer,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Text(
                                              _avatarInitials(auth.userProfile),
                                              style: theme.textTheme.headlineSmall?.copyWith(
                                                color: theme.colorScheme.onPrimaryContainer,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )),
                                ),
                                Positioned(
                                  right: -4,
                                  bottom: -4,
                                  child: Material(
                                    color: theme.colorScheme.primary,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      onTap: _uploadingAvatar
                                          ? null
                                          : () => _pickAndUploadAvatar(context, auth),
                                      customBorder: const CircleBorder(),
                                      child: const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _displayName(auth.userProfile),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    auth.userProfile?['email']?.toString() ?? '—',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                  if ((auth.userProfile?['first_name'] ?? '') != '' ||
                                      (auth.userProfile?['last_name'] ?? '') != '') ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '@${auth.userProfile?['username'] ?? ''}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('Edit profile'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OrderHistoryScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long_outlined, size: 20),
                  label: const Text('My orders'),
                ),
                if (auth.profileError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    auth.profileError!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => auth.loadProfile(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You have been logged out.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
    );
  }

  String _absoluteAvatarUrl(String url) {
    if (url.startsWith('http')) return url;
    final base = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/$'), '');
    return url.startsWith('/') ? '$base$url' : '$base/$url';
  }
}
