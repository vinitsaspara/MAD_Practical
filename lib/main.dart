import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'services/hive_service.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';
import 'providers/user_provider.dart';
import 'providers/tutor_provider.dart';
import 'providers/session_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/tutor_listing_screen.dart';
import 'screens/session_booking_screen.dart';
import 'screens/session_management_screen.dart';
import 'screens/feedback_rating_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const PeerTutoringApp());
}

class PeerTutoringApp extends StatelessWidget {
  const PeerTutoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(apiService)),
        ChangeNotifierProvider(create: (_) => TutorProvider(apiService)),
        ChangeNotifierProvider(create: (_) => SessionProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ConnectivityService(apiService)),
      ],
      child: MaterialApp(
        title: 'PeerTutor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return _route(const SplashScreen());
            case '/welcome':
              return _route(const WelcomeScreen());
            case '/login':
              return _route(const LoginScreen());
            case '/signup':
              return _route(const SignupScreen());
            case '/home':
              return _route(const MainShell());
            case '/profile':
              return _route(const ProfileSetupScreen());
            case '/tutors':
              return _route(const TutorListingScreen());
            case '/book':
              return MaterialPageRoute(
                builder: (_) => const SessionBookingScreen(),
                settings: settings,
              );
            case '/sessions':
              return _route(const SessionManagementScreen());
            case '/feedback':
              return MaterialPageRoute(
                builder: (_) => const FeedbackRatingScreen(),
                settings: settings,
              );
            default:
              return _route(const SplashScreen());
          }
        },
      ),
    );
  }

  MaterialPageRoute _route(Widget page) =>
      MaterialPageRoute(builder: (_) => page);
}

// ── Main Shell with Bottom Navigation ────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    TutorListingScreen(),
    SessionManagementScreen(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          // Offline banner
          if (!connectivity.isOnline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.black87, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Offline mode — changes will sync when online',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search, color: AppTheme.primaryColor),
              label: 'Find Tutor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note, color: AppTheme.primaryColor),
              label: 'Sessions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: AppTheme.primaryColor),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Tab (inside shell) ────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: user == null
            ? const Center(child: Text('No profile found.'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildAvatar(user.name),
                    const SizedBox(height: 16),
                    Text(user.name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(user.email,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _badge(
                            user.role[0].toUpperCase() + user.role.substring(1),
                            AppTheme.accentColor),
                        const SizedBox(width: 10),
                        _badge(
                            user.skillLevel[0].toUpperCase() +
                                user.skillLevel.substring(1),
                            AppTheme.skillColor(user.skillLevel)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _infoCard('Subjects', user.subjects.join('  •  ')),
                    const SizedBox(height: 12),
                    _infoCard('Availability',
                        user.availability.take(4).join('  •  ')),
                    const SizedBox(height: 12),
                    _infoCard('Sessions Completed',
                        '${user.totalSessions}'),
                    const SizedBox(height: 12),
                    _infoCard('Rating',
                        user.rating > 0 ? '${user.rating.toStringAsFixed(1)} ★' : 'No ratings yet'),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Profile'),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/profile'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value.isEmpty ? '—' : value,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 14)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('You will be taken back to the login screen.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/welcome', (_) => false);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
