import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';
import '../app_theme.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;
  final void Function(String)? onStatusUpdate;
  final VoidCallback? onFeedback;

  const SessionCard({
    super.key,
    required this.session,
    this.onStatusUpdate,
    this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(session.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.subject,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('with ${session.tutorName}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                _statusChip(session.status, statusColor),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.calendar_today_outlined,
                DateFormat('EEE, MMM d, yyyy').format(session.dateTime)),
            const SizedBox(height: 6),
            _infoRow(Icons.access_time,
                DateFormat('hh:mm a').format(session.dateTime)),
            const SizedBox(height: 6),
            _infoRow(Icons.tag, session.sessionId, monospace: true),
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.notes, session.notes!),
            ],
            if (onStatusUpdate != null || onFeedback != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  if (onStatusUpdate != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onStatusUpdate!('cancelled'),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onStatusUpdate!('completed'),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                  if (onFeedback != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onFeedback,
                        icon: const Icon(Icons.rate_review_outlined, size: 16),
                        label: const Text('Give Feedback'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {bool monospace = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: monospace ? AppTheme.accentColor : AppTheme.textSecondary,
              fontSize: monospace ? 11 : 13,
              fontFamily: monospace ? 'monospace' : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

