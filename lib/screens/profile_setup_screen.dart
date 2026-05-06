import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedRole = 'learner';
  String _selectedSkill = 'beginner';
  final List<String> _selectedSubjects = [];
  final List<String> _selectedAvailability = [];
  bool _isSaving = false;

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
    'Sat 10:00', 'Sat 14:00', 'Sun 10:00',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _bioController.text = user.bio ?? '';
      _selectedRole = user.role;
      _selectedSkill = user.skillLevel;
      _selectedSubjects.addAll(user.subjects);
      _selectedAvailability.addAll(user.availability);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjects.isEmpty) {
      _showError('Please select at least one subject.');
      return;
    }
    if (_selectedAvailability.isEmpty) {
      _showError('Please select at least one availability slot.');
      return;
    }

    setState(() => _isSaving = true);

    final success = await context.read<UserProvider>().saveProfile(
          name: _nameController.text,
          email: _emailController.text,
          role: _selectedRole,
          subjects: _selectedSubjects,
          skillLevel: _selectedSkill,
          availability: _selectedAvailability,
          bio: _bioController.text.isEmpty ? null : _bioController.text,
        );

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile saved successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pushReplacementNamed(context, '/tutors');
    } else if (mounted) {
      _showError(context.read<UserProvider>().error ?? 'Failed to save profile.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildRoleSection(),
                  const SizedBox(height: 24),
                  _buildSkillSection(),
                  const SizedBox(height: 24),
                  _buildSubjectsSection(),
                  const SizedBox(height: 24),
                  _buildAvailabilitySection(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: const Text(
            'Your Profile',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set up your tutor / learner profile to get started',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Basic Information'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bioController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Short Bio (optional)',
            prefixIcon: Icon(Icons.notes_outlined),
            hintText: 'Tell others a bit about yourself...',
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('I want to be a...'),
        const SizedBox(height: 12),
        Row(
          children: [
            _roleButton('Learner', Icons.school_outlined, 'learner'),
            const SizedBox(width: 10),
            _roleButton('Tutor', Icons.cast_for_education_outlined, 'tutor'),
            const SizedBox(width: 10),
            _roleButton('Both', Icons.swap_horiz, 'both'),
          ],
        ),
      ],
    );
  }

  Widget _roleButton(String label, IconData icon, String value) {
    final isSelected = _selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : AppTheme.bgCardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.white12,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillSection() {
    const levels = ['beginner', 'intermediate', 'advanced'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('My Skill Level'),
        const SizedBox(height: 12),
        Row(
          children: levels.map((level) {
            final isSelected = _selectedSkill == level;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedSkill = level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.skillColor(level).withValues(alpha: 0.25)
                        : AppTheme.bgCardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.skillColor(level)
                          : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    level[0].toUpperCase() + level.substring(1),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.skillColor(level)
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('My Subjects'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allSubjects.map((subject) {
            final isSelected = _selectedSubjects.contains(subject);
            return FilterChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  if (isSelected) {
                    _selectedSubjects.remove(subject);
                  } else {
                    _selectedSubjects.add(subject);
                  }
                });
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.25),
              checkmarkColor: AppTheme.primaryColor,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.white12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('My Availability'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allSlots.map((slot) {
            final isSelected = _selectedAvailability.contains(slot);
            return FilterChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  if (isSelected) {
                    _selectedAvailability.remove(slot);
                  } else {
                    _selectedAvailability.add(slot);
                  }
                });
              },
              selectedColor: AppTheme.accentColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.accentColor,
              side: BorderSide(
                color: isSelected ? AppTheme.accentColor : Colors.white12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isSaving ? null : _saveProfile,
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Profile & Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

