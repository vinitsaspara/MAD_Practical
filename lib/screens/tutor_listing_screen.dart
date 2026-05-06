import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tutor_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../app_theme.dart';
import '../widgets/tutor_card.dart';

class TutorListingScreen extends StatefulWidget {
  const TutorListingScreen({super.key});

  @override
  State<TutorListingScreen> createState() => _TutorListingScreenState();
}

class _TutorListingScreenState extends State<TutorListingScreen> {
  final _searchController = TextEditingController();
  bool _showFilters = false;
  String? _selectedSkill;
  double _minRating = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTutors());
  }

  void _loadTutors() {
    final learner = context.read<UserProvider>().currentUser;
    context.read<TutorProvider>().loadTutorsForLearner(learner);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutorProvider = context.watch<TutorProvider>();
    final learner = context.watch<UserProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Tutor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: Column(
          children: [
            _buildSearch(tutorProvider, learner),
            if (_showFilters) _buildFilterPanel(tutorProvider, learner),
            Expanded(
              child: tutorProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : tutorProvider.tutors.isEmpty
                      ? _buildEmptyState()
                      : _buildTutorList(tutorProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(TutorProvider provider, UserModel? learner) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (q) => provider.updateSearch(q, learner),
              decoration: InputDecoration(
                hintText: 'Search by name or subject...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.updateSearch('', learner);
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: _showFilters ? AppTheme.primaryColor : AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Icon(Icons.tune,
                  color: _showFilters ? Colors.white : AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(TutorProvider provider, UserModel? learner) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter by Skill Level',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['beginner', 'intermediate', 'advanced'].map((s) {
              final sel = _selectedSkill == s;
              return ChoiceChip(
                label: Text(s[0].toUpperCase() + s.substring(1)),
                selected: sel,
                selectedColor: AppTheme.skillColor(s).withValues(alpha: 0.25),
                labelStyle: TextStyle(
                  color: sel ? AppTheme.skillColor(s) : AppTheme.textSecondary,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                ),
                side: BorderSide(color: sel ? AppTheme.skillColor(s) : Colors.white12),
                onSelected: (v) {
                  setState(() => _selectedSkill = v ? s : null);
                  provider.updateFilters(skill: _selectedSkill, minRating: _minRating, learner: learner);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Min Rating:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _minRating,
                  min: 0, max: 5, divisions: 5,
                  label: _minRating == 0 ? 'Any' : _minRating.toStringAsFixed(0),
                  activeColor: AppTheme.primaryColor,
                  onChanged: (v) {
                    setState(() => _minRating = v);
                    provider.updateFilters(skill: _selectedSkill, minRating: v, learner: learner);
                  },
                ),
              ),
              Text(_minRating == 0 ? 'Any' : '${_minRating.toInt()}★',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() { _selectedSkill = null; _minRating = 0; });
                provider.resetFilters(learner);
              },
              child: const Text('Reset', style: TextStyle(color: AppTheme.primaryColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorList(TutorProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: provider.tutors.length,
      itemBuilder: (context, index) {
        final tutor = provider.tutors[index];
        return TutorCard(
          tutor: tutor,
          onBook: () => Navigator.pushNamed(context, '/book', arguments: tutor),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('No tutors found',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Try adjusting your filters',
              style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

