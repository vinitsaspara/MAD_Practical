import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/session_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../app_theme.dart';

class SessionBookingScreen extends StatefulWidget {
  const SessionBookingScreen({super.key});

  @override
  State<SessionBookingScreen> createState() => _SessionBookingScreenState();
}

class _SessionBookingScreenState extends State<SessionBookingScreen> {
  final _notesController = TextEditingController();
  String? _selectedSubject;
  DateTime? _selectedDateTime;
  bool _isBooking = false;

  UserModel? _tutor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tutor = ModalRoute.of(context)?.settings.arguments as UserModel?;
    if (_selectedSubject == null && _tutor != null && _tutor!.subjects.isNotEmpty) {
      _selectedSubject = _tutor!.subjects.first;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _bookSession() async {
    if (_tutor == null) return;
    if (_selectedSubject == null) {
      _showSnack('Please select a subject.', AppTheme.errorColor);
      return;
    }
    if (_selectedDateTime == null) {
      _showSnack('Please select a date and time.', AppTheme.errorColor);
      return;
    }
    if (_selectedDateTime!.isBefore(DateTime.now())) {
      _showSnack('Please select a future date and time.', AppTheme.errorColor);
      return;
    }

    final learner = context.read<UserProvider>().currentUser;
    if (learner == null) return;

    setState(() => _isBooking = true);

    final (success, message) = await context.read<SessionProvider>().bookSession(
          tutor: _tutor!,
          learner: learner,
          subject: _selectedSubject!,
          dateTime: _selectedDateTime!,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

    setState(() => _isBooking = false);

    if (!mounted) return;

    if (success) {
      _showBookingSuccess(message);
    } else {
      _showSnack(message, AppTheme.errorColor);
    }
  }

  void _showBookingSuccess(String sessionId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Session Booked!',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your session has been scheduled.',
                style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Session ID:\n$sessionId',
                style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontFamily: 'monospace',
                    fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/sessions');
            },
            child: const Text('View Sessions'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Session')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: _tutor == null
            ? const Center(child: Text('No tutor selected.'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTutorHeader(),
                    const SizedBox(height: 28),
                    _buildSubjectSelector(),
                    const SizedBox(height: 24),
                    _buildDateTimePicker(),
                    const SizedBox(height: 24),
                    _buildNotesField(),
                    const SizedBox(height: 32),
                    _buildBookButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTutorHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            child: Text(
              _tutor!.name.isNotEmpty ? _tutor!.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_tutor!.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(_tutor!.skillLevel[0].toUpperCase() + _tutor!.skillLevel.substring(1),
                    style: TextStyle(color: AppTheme.skillColor(_tutor!.skillLevel))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppTheme.warningColor, size: 16),
                    const SizedBox(width: 4),
                    Text(_tutor!.rating.toStringAsFixed(1),
                        style: const TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Subject',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tutor!.subjects.map((s) {
            final sel = _selectedSubject == s;
            return GestureDetector(
              onTap: () => setState(() => _selectedSubject = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primaryColor.withValues(alpha: 0.25) : AppTheme.bgCardLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? AppTheme.primaryColor : Colors.white12,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Text(s,
                    style: TextStyle(
                        color: sel ? AppTheme.primaryColor : AppTheme.textSecondary,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.normal)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date & Time',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDateTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgCardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedDateTime != null ? AppTheme.primaryColor : Colors.white12,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  _selectedDateTime == null
                      ? 'Tap to select date & time'
                      : DateFormat('EEE, MMM d, yyyy  •  hh:mm a').format(_selectedDateTime!),
                  style: TextStyle(
                    color: _selectedDateTime == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notes (optional)',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'What topics do you need help with?',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.notes),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
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
          onPressed: _isBooking ? null : _bookSession,
          child: _isBooking
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Confirm Booking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

