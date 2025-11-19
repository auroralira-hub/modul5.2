import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models.dart';
import '../../../services/supabase_services.dart';
import '../../../widgets/theme_toggle_action.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.user});

  final User user;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final SupabaseProfileService _profileService = const SupabaseProfileService();
  final ImagePicker _picker = ImagePicker();
  String? _avatarUrl;
  bool _loadingAvatar = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _fetchAvatar();
  }

  Future<void> _fetchAvatar() async {
    final id = widget.user.supabaseUserId;
    if (id == null) return;
    setState(() => _loadingAvatar = true);
    try {
      final url = await _profileService.fetchAvatarUrl(id);
      if (!mounted) return;
      setState(() => _avatarUrl = url);
    } on SupabaseProfileServiceException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Gagal memuat foto profil: $e');
    } finally {
      if (mounted) setState(() => _loadingAvatar = false);
    }
  }

  Future<void> _changePhoto() async {
    final id = widget.user.supabaseUserId;
    if (id == null) {
      _showSnack('Akun ini belum terhubung ke Supabase.');
      return;
    }
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final bytes = await picked.readAsBytes();
      final extension = _extractExtension(picked.name);
      final fileName =
          '${id}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final contentType = _guessContentType(extension);
      final url = await _profileService.uploadProfilePhoto(
        userId: id,
        bytes: bytes,
        fileName: fileName,
        contentType: contentType,
      );
      if (!mounted) return;
      setState(() => _avatarUrl = url);
      _showSnack('Foto profil diperbarui');
    } on SupabaseProfileServiceException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Gagal mengunggah foto: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _extractExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) return 'jpg';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  String _guessContentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  void _showSnack(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF141A2A) : null;
    final borderColor = isDark ? Colors.white.withOpacity(0.05) : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.indigo,
        actions: const [ThemeToggleAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Hero(
              tag: 'app-logo',
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: isDark
                        ? Colors.indigo.shade200
                        : Colors.indigo.shade100,
                    backgroundImage: _avatarUrl != null
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: (_avatarUrl == null && !_loadingAvatar)
                        ? Text(
                            widget.user.name.isNotEmpty
                                ? widget.user.name[0]
                                : 'U',
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                            ),
                          )
                        : _loadingAvatar
                        ? const CircularProgressIndicator()
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: _uploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.edit, color: Colors.white),
                        onPressed: _uploading ? null : _changePhoto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.user.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor ?? Colors.transparent),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _infoRow('Username', widget.user.username),
                    _infoRow('Nama', widget.user.name),
                    _infoRow('Usia', '${widget.user.age}'),
                    _infoRow('Jurusan', widget.user.major),
                    _infoRow('Email', widget.user.email),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
