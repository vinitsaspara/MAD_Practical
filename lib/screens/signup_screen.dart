import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String _selectedRole = 'learner';
  String _selectedSkill = 'beginner';
  final List<String> _selectedSubjects = [];
  final List<String> _selectedAvailability = [];
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  static const List<String> _allSubjects = [
    'Java', 'Python', 'Flutter', 'DBMS', 'Data Structures',
    'Algorithms', 'Machine Learning', 'Web Dev', 'C++', 'React',
    'Node.js', 'SQL', 'Mathematics', 'Physics', 'Statistics',
  ];

  static const List<String> _allSlots = [
    'Mon 09:00', 'Mon 11:00', 'Mon 14:00',
    'Tue 09:00', 'Tue 11:00', 'Tue 14:00',
    'Wed 09:00', 'Wed 11:00', 'Wed 14:00',
    'Thu 09:00', 'Thu 11:00', 'Thu 14:00',
    'Fri 09:00', 'Fri 11:00', 'Fri 14:00',
    'Sat 10:00', 'Sat 14:00',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjects.isEmpty) {
      _showSnack('Please select at least one subject.');
      return;
    }
    if (_selectedAvailability.isEmpty) {
      _showSnack('Please select at least one availability slot.');
      return;
    }

    setState(() => _isLoading = true);

    final success = await context.read<UserProvider>().register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _selectedRole,
          subjects: _selectedSubjects,
          skillLevel: _selectedSkill,
          availability: _selectedAvailability,
        );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Welcome to PeerTutor 🎉'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      final err = context.read<UserProvider>().error ?? 'Registration failed.';
      _showSnack(err);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 28),
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // ── Section 1: Basic Info ──────────────────────────────
                  _sectionTitle('Basic Information'),
                  const SizedBox(height: 12),
                  _buildNameField(),
                  const SizedBox(height: 12),
                  _buildEmailField(),
                  const SizedBox(height: 12),
                  _buildPasswordField(),
                  const SizedBox(height: 12),
                  _buildConfirmPasswordField(),

                  const SizedBox(height: 28),

                  // ── Section 2: Role ────────────────────────────────────
                  _sectionTitle('I want to be a...'),
                  const SizedBox(height: 12),
                  _buildRoleSelector(),

                  const SizedBox(height: 28),

                  // ── Section 3: Skill ───────────────────────────────────
                  _sectionTitle('My Skill Level'),
                  const SizedBox(height: 12),
                  _buildSkillSelector(),

                  const SizedBox(height: 28),

                  // ── Section 4: Subjects ────────────────────────────────
                  _sectionTitle('My Subjects'),
                  const SizedBox(height: 4),
                  const Text('Select all that apply',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 10),
                  _buildSubjectChips(),

                  const SizedBox(height: 28),

                  // ── Section 5: Availability ────────────────────────────
                  _sectionTitle('My Availability'),
                  const SizedBox(height: 4),
                  const Text('When are you free for sessions?',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 10),
                  _buildAvailabilityChips(),

                  const SizedBox(height: 36),
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                  _buildLoginLink(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bgCardLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppTheme.textPrimary, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        const Text('Create Account',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
          child: const Text(
            'Join PeerTutor',
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Fill in your details to get matched with tutors',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameCtrl,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Full Name',
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Email Address',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        if (!v.contains('@')) return 'Enter a valid email';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        if (v.length < 6) return 'Minimum 6 characters';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmCtrl,
      obscureText: _obscureConfirm,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirm
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please confirm your password';
        if (v != _passwordCtrl.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  Widget _buildRoleSelector() {
    final roles = [
      ('learner', 'Learner', Icons.school_outlined),
      ('tutor', 'Tutor', Icons.cast_for_education_outlined),
      ('both', 'Both', Icons.swap_horiz),
    ];
    return Row(
      children: roles.map((r) {
        final sel = _selectedRole == r.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedRole = r.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: sel ? AppTheme.primaryGradient : null,
                color: sel ? null : AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: sel ? Colors.transparent : Colors.white12),
              ),
              child: Column(
                children: [
                  Icon(r.$3, color: Colors.white, size: 20),
                  const SizedBox(height: 6),
                  Text(r.$2,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillSelector() {
    const levels = ['beginner', 'intermediate', 'advanced'];
    return Row(
      children: levels.map((level) {
        final sel = _selectedSkill == level;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedSkill = level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel
                    ? AppTheme.skillColor(level).withValues(alpha: 0.2)
                    : AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? AppTheme.skillColor(level) : Colors.white12,
                  width: sel ? 2 : 1,
                ),
              ),
              child: Text(
                level[0].toUpperCase() + level.substring(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: sel ? AppTheme.skillColor(level) : AppTheme.textSecondary,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allSubjects.map((s) {
        final sel = _selectedSubjects.contains(s);
        return FilterChip(
          label: Text(s),
          selected: sel,
          onSelected: (_) => setState(() {
            if (sel) { _selectedSubjects.remove(s); }
            else { _selectedSubjects.add(s); }
          }),
          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.25),
          checkmarkColor: AppTheme.primaryColor,
          side: BorderSide(color: sel ? AppTheme.primaryColor : Colors.white12),
        );
      }).toList(),
    );
  }

  Widget _buildAvailabilityChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allSlots.map((slot) {
        final sel = _selectedAvailability.contains(slot);
        return FilterChip(
          label: Text(slot),
          selected: sel,
          onSelected: (_) => setState(() {
            if (sel) { _selectedAvailability.remove(slot); }
            else { _selectedAvailability.add(slot); }
          }),
          selectedColor: AppTheme.accentColor.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.accentColor,
          side: BorderSide(color: sel ? AppTheme.accentColor : Colors.white12),
        );
      }).toList(),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _isLoading ? null : _register,
          child: _isLoading
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Create Account',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account? ',
            style: TextStyle(color: AppTheme.textSecondary)),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text(
            'Sign In',
            style: TextStyle(
                color: AppTheme.primaryColor, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700),
    );
  }
}
