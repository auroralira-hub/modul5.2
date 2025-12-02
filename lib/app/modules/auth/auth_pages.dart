import 'package:flutter/material.dart';

import '../../data/in_memory_service.dart';
import '../../data/models.dart';
import '../../routes/app_routes.dart';
import '../../services/network_service.dart';
import '../../services/session_service.dart';
import '../../services/supabase_services.dart';
import '../../widgets/theme_toggle_action.dart';

/* ===========================
   Login & Register
   =========================== */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final SupabaseProfileService _supabaseProfileService =
      const SupabaseProfileService();

  late AnimationController _bgController;
  bool _isLoggingIn = false;
  String _selectedLoginRole = UserRole.student;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_isLoggingIn) return;
    final u = _usernameCtrl.text.trim();
    final p = _passwordCtrl.text;
    if (u.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan email/username dan password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoggingIn = true);
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      // Coba login dengan Supabase terlebih dahulu
      final online = await NetworkService.hasConnection();
      if (!online) {
        // Fallback ke akun lokal jika offline
        final localUser = InMemoryService.login(u, p);
        if (localUser == null) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Offline: Akun tidak ditemukan di lokal'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        await SessionService.saveUser(localUser);
        _navigateToHome(localUser);
        return;
      }

      // Online: wajib gunakan email (RLS mencegah lookup username sebelum login)
      if (!u.contains('@')) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Silakan login menggunakan email (bukan username).'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Login dengan Supabase
      final remoteUser = await _supabaseProfileService.loginUser(
        username: u,
        password: p,
      );
      
      // Simpan ke local storage untuk offline access
      final existing = InMemoryService.getByUsername(remoteUser.username);
      if (existing == null) {
        InMemoryService.register(remoteUser);
      }
      
      await SessionService.saveUser(remoteUser);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Login berhasil!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      
      _navigateToHome(remoteUser);
    } on SupabaseProfileServiceException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal login: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }
  
  void _navigateToHome(User user) {
    if (!mounted) return;

    if (UserRole.isPsychologist(user.role) ||
        user.username == 'Rofika') {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.psikologHome,
        arguments: user.username,
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: user,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F3FF),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const ThemeToggleAction(iconColor: Colors.grey),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogoBig(),
                        const SizedBox(height: 16),
                        const Text(
                          'MoodTracker',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Kesehatan Mental Mahasiswa',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildAuthCard(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoBig() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.psychology,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pilih role Anda',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _LoginRoleCard(
                    title: 'Mahasiswa',
                    subtitle: 'Catat mood harian Anda',
                    icon: Icons.person_outline,
                    value: UserRole.student,
                    selected: _selectedLoginRole == UserRole.student,
                    onTap: () =>
                        setState(() => _selectedLoginRole = UserRole.student),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LoginRoleCard(
                    title: 'Psikolog',
                    subtitle: 'Monitor klien mahasiswa',
                    icon: Icons.psychology_outlined,
                    value: UserRole.psychologist,
                    selected: _selectedLoginRole == UserRole.psychologist,
                    onTap: () => setState(
                      () => _selectedLoginRole = UserRole.psychologist,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameCtrl,
              style: const TextStyle(color: Color(0xFF111827)),
              cursorColor: Color(0xFF7C3AED),
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.email_outlined, color: Color(0xFF9CA3AF)),
                hintText: 'Email',
                helperText: 'Gunakan email Supabase untuk login',
                helperStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              style: const TextStyle(color: Color(0xFF111827)),
              cursorColor: Color(0xFF7C3AED),
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF)),
                hintText: '••••••••',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoggingIn ? null : _onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1C4E9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoggingIn
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Belum punya akun? ',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, anim, __) => ScaleTransition(
                        scale: anim,
                        child: const RegisterPage(),
                      ),
                      transitionDuration: const Duration(milliseconds: 420),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginRoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _LoginRoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3F4F6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF7C3AED) : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    selected ? const Color(0xFF7C3AED) : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF6B7280),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: selected ? const Color(0xFF7C3AED) : const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _u = TextEditingController();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _major = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final SupabaseProfileService _supabaseProfileService =
      const SupabaseProfileService();
  String _selectedRole = UserRole.student;

  late AnimationController _entrance;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _u.dispose();
    _name.dispose();
    _age.dispose();
    _major.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (_isRegistering || !_form.currentState!.validate()) return;

    final email = _email.text.trim();
    final password = _pass.text;
    
    // Validasi email format
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Validasi password minimal 6 karakter (requirement Supabase)
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 6 karakter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = User(
      username: _u.text.trim(),
      name: _name.text.trim(),
      age: int.tryParse(_age.text.trim()) ?? 0,
      major: _major.text.trim(),
      email: email,
      password: password,
      role: _selectedRole,
    );

    // Cek username di local terlebih dahulu
    if (InMemoryService.getByUsername(user.username) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username sudah digunakan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isRegistering = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Cek koneksi internet
      final online = await NetworkService.hasConnection();
      if (!online) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Tidak ada koneksi internet. Register memerlukan koneksi.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Register ke Supabase
      final supabaseUserId = await _supabaseProfileService.registerUser(user);
      final registeredUser = user.copyWith(supabaseUserId: supabaseUserId);
      
      // Simpan ke local storage
      InMemoryService.register(registeredUser);
      
      if (!mounted) return;
      await SessionService.saveUser(registeredUser);
      
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan verifikasi email Anda.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Navigate berdasarkan role
      if (UserRole.isPsychologist(registeredUser.role)) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.psikologHome,
          (r) => false,
          arguments: registeredUser.username,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (r) => false,
          arguments: registeredUser,
        );
      }
    } on UsernameAlreadyExistsException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } on SupabaseProfileServiceException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal registrasi: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPsychologist = _selectedRole == UserRole.psychologist;
    return ScaleTransition(
      scale: CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Akun'),
          backgroundColor: Colors.indigo,
          actions: const [ThemeToggleAction()],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      _RoleSelector(
                        selectedRole: _selectedRole,
                        onChanged: (value) =>
                            setState(() => _selectedRole = value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _u,
                        style: const TextStyle(color: Color(0xFF111827)),
                        cursorColor: Color(0xFF7C3AED),
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Masukkan username'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _name,
                        style: const TextStyle(color: Color(0xFF111827)),
                        cursorColor: Color(0xFF7C3AED),
                        decoration: const InputDecoration(
                          labelText: 'Nama lengkap',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Masukkan nama'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _age,
                              style: const TextStyle(color: Color(0xFF111827)),
                              cursorColor: Color(0xFF7C3AED),
                              decoration: const InputDecoration(
                                labelText: 'Usia',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Masukkan usia';
                                }
                                if (int.tryParse(v) == null) {
                                  return 'Usia tidak valid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _major,
                              style: const TextStyle(color: Color(0xFF111827)),
                              cursorColor: Color(0xFF7C3AED),
                              decoration: InputDecoration(
                                labelText:
                                    isPsychologist ? 'Gelar' : 'Jurusan',
                              ),
                              validator: (v) {
                                if (!isPsychologist) return null;
                                if (v == null || v.trim().isEmpty) {
                                  return 'Masukkan gelar';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _email,
                        style: const TextStyle(color: Color(0xFF111827)),
                        cursorColor: Color(0xFF7C3AED),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          helperText: 'Digunakan untuk login dengan Supabase Auth',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Masukkan email';
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pass,
                        obscureText: true,
                        style: const TextStyle(color: Color(0xFF111827)),
                        cursorColor: Color(0xFF7C3AED),
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Password minimal 6 karakter'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isRegistering ? null : _onRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isRegistering
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Daftar & Lanjutkan'),
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
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const _RoleSelector({
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Pilih role Anda',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                title: 'Mahasiswa',
                subtitle: 'Catat mood harian Anda',
                icon: Icons.person_outline,
                value: UserRole.student,
                selected: selectedRole == UserRole.student,
                onTap: () => onChanged(UserRole.student),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoleCard(
                title: 'Psikolog',
                subtitle: 'Monitor klien mahasiswa',
                icon: Icons.psychology_outlined,
                value: UserRole.psychologist,
                selected: selectedRole == UserRole.psychologist,
                onTap: () => onChanged(UserRole.psychologist),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.indigo.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.indigo : Colors.grey.shade300,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.indigo.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: selected
                  ? Colors.indigo.withOpacity(0.12)
                  : Colors.grey.shade100,
              child: Icon(
                icon,
                color: selected ? Colors.indigo : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
