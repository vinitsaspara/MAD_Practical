import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../providers/user_provider.dart';
import '../models/session_model.dart';
import '../app_theme.dart';
import '../widgets/session_card.dart';

class SessionManagementScreen extends StatefulWidget {
  const SessionManagementScreen({super.key});

  @override
  State<SessionManagementScreen> createState() => _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSessions());
  }

  void _loadSessions() {
    final userId = context.read<UserProvider>().currentUser?.id;
    if (userId != null) {
      context.read<SessionProvider>().loadSessionsForUser(userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sessions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Upcoming (${provider.upcomingSessions.length})'),
            Tab(text: 'Completed (${provider.completedSessions.length})'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildSessionList(provider.upcomingSessions, 'scheduled'),
                  _buildSessionList(provider.completedSessions, 'completed'),
                  _buildSessionList(provider.cancelledSessions, 'cancelled'),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/tutors'),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Book Session'),
      ),
    );
  }

  Widget _buildSessionList(List<SessionModel> sessions, String tab) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_tabIcon(tab), size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No $tab sessions', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
            const SizedBox(height: 8),
            if (tab == 'scheduled')
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/tutors'),
                child: const Text('Find a Tutor'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionCard(
          session: session,
          onStatusUpdate: tab == 'scheduled'
              ? (newStatus) => _updateStatus(session, newStatus)
              : null,
          onFeedback: tab == 'completed'
              ? () => Navigator.pushNamed(context, '/feedback', arguments: session)
              : null,
        );
      },
    );
  }

  Future<void> _updateStatus(SessionModel session, String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text('Mark as ${newStatus[0].toUpperCase()}${newStatus.substring(1)}?',
            style: const TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          newStatus == 'cancelled'
              ? 'Are you sure you want to cancel this session?'
              : 'Mark this session as completed?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: newStatus == 'cancelled'
                  ? ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor)
                  : null,
              child: const Text('Yes')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<SessionProvider>().updateStatus(session.sessionId, newStatus);
      if (newStatus == 'completed' && mounted) {
        Navigator.pushNamed(context, '/feedback', arguments: session);
      }
    }
  }

  IconData _tabIcon(String tab) {
    switch (tab) {
      case 'scheduled': return Icons.event_outlined;
      case 'completed': return Icons.check_circle_outline;
      default: return Icons.cancel_outlined;
    }
  }
}

