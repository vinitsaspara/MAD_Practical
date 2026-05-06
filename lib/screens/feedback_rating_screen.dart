import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../providers/session_provider.dart';
import '../providers/user_provider.dart';
import '../models/session_model.dart';
import '../app_theme.dart';

class FeedbackRatingScreen extends StatefulWidget {
  const FeedbackRatingScreen({super.key});

  @override
  State<FeedbackRatingScreen> createState() => _FeedbackRatingScreenState();
}

class _FeedbackRatingScreenState extends State<FeedbackRatingScreen> {
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;
  SessionModel? _session;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _session = ModalRoute.of(context)?.settings.arguments as SessionModel?;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating.'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a comment.'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }
    if (_session == null) return;

    final userId = context.read<UserProvider>().currentUser?.id;
    if (userId == null) return;

    setState(() => _isSubmitting = true);

    final success = await context.read<SessionProvider>().submitFeedback(
          session: _session!,
          rating: _rating,
          comment: _commentController.text.trim(),
          givenBy: userId,
        );

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Thank You! 🌟', style: TextStyle(color: AppTheme.textPrimary)),
          content: const Text('Your feedback helps improve the tutoring community.',
              style: TextStyle(color: AppTheme.textSecondary)),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/sessions');
              },
              child: const Text('Back to Sessions'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<SessionProvider>().error ?? 'Failed to submit feedback.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate & Review')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: _session == null
            ? const Center(child: Text('No session data.'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    _buildSessionSummary(),
                    const SizedBox(height: 40),
                    _buildRatingSection(),
                    const SizedBox(height: 32),
                    _buildCommentField(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSessionSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            child: Text(
              _session!.tutorName.isNotEmpty ? _session!.tutorName[0].toUpperCase() : 'T',
              style: const TextStyle(
                  color: AppTheme.primaryColor, fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Text(_session!.tutorName,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Session: ${_session!.subject}',
              style: const TextStyle(color: AppTheme.accentColor, fontSize: 14)),
          const SizedBox(height: 4),
          Text('ID: ${_session!.sessionId}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        const Text('How was your session?',
            style: TextStyle(
                color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Tap a star to rate',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        RatingBar.builder(
          initialRating: _rating.toDouble(),
          minRating: 1,
          itemCount: 5,
          itemSize: 52,
          glow: true,
          glowColor: AppTheme.warningColor.withValues(alpha: 0.3),
          itemPadding: const EdgeInsets.symmetric(horizontal: 6),
          itemBuilder: (ctx, _) => const Icon(Icons.star, color: AppTheme.warningColor),
          onRatingUpdate: (r) => setState(() => _rating = r.toInt()),
        ),
        const SizedBox(height: 16),
        Text(
          _rating == 0
              ? ''
              : ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'][_rating],
          style: TextStyle(
            color: _rating == 0 ? Colors.transparent : AppTheme.warningColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Feedback',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Share your experience with this tutor...',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.comment_outlined),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
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
          onPressed: _isSubmitting ? null : _submitFeedback,
          child: _isSubmitting
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Submit Feedback',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

