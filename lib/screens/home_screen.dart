import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';
import '../l10n/bilingual_date_formatter.dart';
import '../models/event.dart';
import '../services/firestore_service.dart';
import 'add_event_sheet.dart';

/// Main screen displaying today's date in a large font and a list of
/// upcoming shared events.
class HomeScreen extends StatelessWidget {
  final FirestoreService firestoreService;

  const HomeScreen({super.key, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Large Date Display ----
            _DateDisplay(date: DateTime.now()),
            const Divider(height: 1),
            // ---- Upcoming Events ----
            Expanded(child: _EventList(firestoreService: firestoreService)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEventSheet(context),
        tooltip: AppStrings.addEventTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openAddEventSheet(BuildContext context) {
    AddEventSheet.show(context, firestoreService: firestoreService);
  }
}

// ---------------------------------------------------------------------------
// Date Display Widget
// ---------------------------------------------------------------------------
class _DateDisplay extends StatelessWidget {
  final DateTime date;

  const _DateDisplay({required this.date});

  @override
  Widget build(BuildContext context) {
    final formatted = BilingualDateFormatter.full(date);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Text(
            formatted,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.upcomingEvents,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Event List Widget
// ---------------------------------------------------------------------------
class _EventList extends StatelessWidget {
  final FirestoreService firestoreService;

  const _EventList({required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: firestoreService.getUpcomingEvents(),
      builder: (context, snapshot) {
        // ---- Loading ----
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // ---- Error ----
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.couldNotLoadEvents,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final events = snapshot.data ?? [];

        // ---- Empty State ----
        if (events.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_note,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noUpcomingEvents,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.tapPlusToAdd,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        // ---- Event List ----
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          itemCount: events.length,
          itemBuilder: (context, index) => _EventCard(event: events[index]),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Event Card Widget
// ---------------------------------------------------------------------------
class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = BilingualDateFormatter.compact(event.date);

    // Check if the event is today.
    final now = DateTime.now();
    final isToday = event.date.year == now.year &&
        event.date.month == now.month &&
        event.date.day == now.day;

    final monthLabel = DateFormat('M月', 'zh_TW').format(event.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Date badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isToday
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.date.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    monthLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? theme.colorScheme.onPrimary
                              .withValues(alpha: 0.8)
                          : theme.colorScheme.onSecondaryContainer
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
