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
  late Animation<Alignment> _beginAnim;
  late Animation<Alignment> _endAnim;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _beginAnim = AlignmentTween(
      begin: Alignment.topLeft,
      end: const Alignment(-0.3, -1),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _endAnim = AlignmentTween(
      begin: Alignment.bottomRight,
      end: const Alignment(0.8, 1),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
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
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Login gagal'),
          content: const Text('Masukkan username dan password.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() => _isLoggingIn = true);
    final messenger = ScaffoldMessenger.of(context);
    User? user = InMemoryService.login(u, p);
    try {
      if (user == null) {
        final online = await NetworkService.hasConnection();
        if (!online) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Anda sedang offline, gunakan akun lokal.'),
            ),
          );
          return;
        }
        final remoteUser = await _supabaseProfileService.loginUser(
          username: u,
          password: p,
        );
        final existing = InMemoryService.getByUsername(remoteUser.username);
        if (existing == null) {
          InMemoryService.register(remoteUser);
        }
        user = remoteUser;
      }

      final User authenticatedUser = user as User;
      if (!mounted) return;
      await SessionService.saveUser(authenticatedUser);
      if (authenticatedUser.username == 'Rofika') {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.dosenHome,
          arguments: authenticatedUser.username,
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
          arguments: authenticatedUser,
        );
      }
    } on SupabaseProfileServiceException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal login: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final titleSize = w > 420 ? 34.0 : 24.0;

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _beginAnim.value,
                end: _endAnim.value,
                colors: [
                  Colors.indigo.shade600,
                  Colors.deepPurple.shade400,
                  Colors.teal.shade200,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const ThemeToggleAction(iconColor: Colors.white),
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
                          Hero(tag: 'app-logo', child: _buildLogoBig()),
                          const SizedBox(height: 12),
                          Text(
                            'MoodTracker & Stress',
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildAuthCard(context),
                          const SizedBox(height: 12),
                          Text(
                            'Dosen: Rofika / rofika12 • Contoh user: lira / liralira',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoBig() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 10),
        ],
      ),
      child: Icon(Icons.mood, size: 56, color: Colors.white),
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoggingIn ? null : _onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoggingIn
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, anim, __) => ScaleTransition(
                          scale: anim,
                          child: const RegisterPage(),
                        ),
                        transitionDuration: const Duration(milliseconds: 420),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: const CircleBorder(),
                      elevation: 6,
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum punya akun?'),
                TextButton(
                  onPressed: () => Navigator.push(
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
                    'Daftar',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

    final user = User(
      username: _u.text.trim(),
      name: _name.text.trim(),
      age: int.tryParse(_age.text.trim()) ?? 0,
      major: _major.text.trim(),
      email: _email.text.trim(),
      password: _pass.text,
    );

    if (InMemoryService.getByUsername(user.username) != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username sudah ada')));
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final supabaseUserId = await _supabaseProfileService.registerUser(user);
      final registeredUser = user.copyWith(supabaseUserId: supabaseUserId);
      final ok = InMemoryService.register(registeredUser);
      if (!ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Username sudah ada')));
        return;
      }
      if (!mounted) return;
      await SessionService.saveUser(registeredUser);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (r) => false,
        arguments: registeredUser,
      );
    } on UsernameAlreadyExistsException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } on SupabaseProfileServiceException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan ke Supabase: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      TextFormField(
                        controller: _u,
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
                              decoration: const InputDecoration(
                                labelText: 'Usia',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Masukkan usia';
                                if (int.tryParse(v) == null)
                                  return 'Usia tidak valid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _major,
                              decoration: const InputDecoration(
                                labelText: 'Jurusan',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Masukkan email';
                          if (!v.contains('@')) return 'Email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pass,
                        obscureText: true,
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
