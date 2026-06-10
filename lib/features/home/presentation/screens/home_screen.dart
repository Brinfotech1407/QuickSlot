import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../booking/data/models/booking_models.dart';
import '../../../booking/presentation/cubit/booking_cubit.dart';
import '../../../booking/presentation/cubit/booking_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus &&
          current.actionStatus != BookingActionStatus.idle &&
          current.actionStatus != BookingActionStatus.loading,
      listener: (context, state) {
        final message = state.actionMessage;
        if (message == null) {
          return;
        }

        if (state.actionStatus == BookingActionStatus.success) {
          SnackbarHelper.showSuccess(context, message);
        } else {
          SnackbarHelper.showError(context, message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppConstants.appName),
            actions: [
              if (state.users.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _UserSelector(state: state),
                ),
            ],
          ),
          body: _Body(state: state),
          bottomNavigationBar: NavigationBar(
            selectedIndex: state.tab.index,
            onDestinationSelected: (index) => context
                .read<BookingCubit>()
                .selectTab(BookingTab.values[index]),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.sports_tennis_outlined),
                selectedIcon: Icon(Icons.sports_tennis),
                label: 'Venues',
              ),
              NavigationDestination(
                icon: Icon(Icons.event_note_outlined),
                selectedIcon: Icon(Icons.event_note),
                label: 'Bookings',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    switch (state.loadStatus) {
      case BookingLoadStatus.initial:
      case BookingLoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case BookingLoadStatus.error:
        return _ErrorState(
          message: state.errorMessage ?? 'Unable to load QuickSlot.',
          onRetry: () => context.read<BookingCubit>().initialize(),
        );
      case BookingLoadStatus.success:
        if (state.users.isEmpty) {
          return const _EmptyState(
            icon: Icons.person_off_outlined,
            title: 'No users found',
            message: 'Seed users in the backend and refresh.',
          );
        }

        return IndexedStack(
          index: state.tab.index,
          children: [
            _VenueTab(state: state),
            _BookingsTab(state: state),
          ],
        );
    }
  }
}

class _UserSelector extends StatelessWidget {
  const _UserSelector({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<QuickSlotUser>(
        value: state.selectedUser,
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.expand_more),
        items: state.users
            .map(
              (user) => DropdownMenuItem<QuickSlotUser>(
                value: user,
                child: Text(user.name),
              ),
            )
            .toList(),
        onChanged: (user) {
          if (user != null) {
            context.read<BookingCubit>().selectUser(user);
          }
        },
      ),
    );
  }
}

class _VenueTab extends StatelessWidget {
  const _VenueTab({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    if (state.venues.isEmpty) {
      return const _EmptyState(
        icon: Icons.stadium_outlined,
        title: 'No venues yet',
        message: 'Run the backend seed and refresh this screen.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingCubit>().initialize(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Choose a venue', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...state.venues.map(
            (venue) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _VenueCard(
                venue: venue,
                isSelected: venue == state.selectedVenue,
                onTap: () => context.read<BookingCubit>().selectVenue(venue),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _DateSelector(selectedDate: state.selectedDate ?? DateTime.now()),
          const SizedBox(height: 18),
          _SlotGrid(state: state),
        ],
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({
    required this.venue,
    required this.isSelected,
    required this.onTap,
  });

  final Venue venue;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? const Color(0xFFEFF6FF) : AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    isSelected ? AppColors.primary : AppColors.border,
                foregroundColor:
                    isSelected ? Colors.white : AppColors.textSecondary,
                child: const Icon(Icons.sports),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(venue.name, style: AppTextStyles.title),
                    const SizedBox(height: 4),
                    Text(
                      '${venue.sport} • ${venue.area}',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 2),
                    Text(venue.address, style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('EEE, dd MMM yyyy').format(selectedDate);

    return OutlinedButton.icon(
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );

        if (date != null && context.mounted) {
          context.read<BookingCubit>().selectDate(date);
        }
      },
      icon: const Icon(Icons.calendar_month_outlined),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    if (state.slots.isEmpty) {
      return const _EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'No slots available',
        message: 'Try another venue or date.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Slots',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.read<BookingCubit>().refreshSlots(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.slots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.35,
          ),
          itemBuilder: (context, index) {
            final slot = state.slots[index];
            return _SlotTile(
              slot: slot,
              isBusy: state.actionStatus == BookingActionStatus.loading,
            );
          },
        ),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.isBusy,
  });

  final VenueSlot slot;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final available = slot.isAvailable;
    final color = available ? AppColors.success : AppColors.textSecondary;

    return OutlinedButton(
      onPressed: available && !isBusy
          ? () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Book this slot?'),
                  content: Text(slot.label),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Book'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                context.read<BookingCubit>().bookSlot(slot);
              }
            }
          : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: available ? color : AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: available ? Colors.white : const Color(0xFFF1F5F9),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(slot.label, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            available ? 'Available' : 'Booked',
            style: AppTextStyles.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    if (state.bookings.isEmpty) {
      return const _EmptyState(
        icon: Icons.event_available_outlined,
        title: 'No bookings yet',
        message: 'Book an available slot to see it here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingCubit>().refreshBookings(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final booking = state.bookings[index];
          return _BookingCard(
            booking: booking,
            isBusy: state.actionStatus == BookingActionStatus.loading,
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: state.bookings.length,
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.isBusy,
  });

  final UserBooking booking;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(booking.venueName, style: AppTextStyles.title),
                ),
                _StatusBadge(active: booking.isActive),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${booking.sport} • ${booking.area}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(booking.date)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule_outlined, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(booking.slotLabel)),
              ],
            ),
            if (booking.isActive) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isBusy
                    ? null
                    : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Cancel booking?'),
                            content: Text(
                              '${booking.venueName}\n${booking.date}, ${booking.slotLabel}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text('Keep'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text('Cancel booking'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          context.read<BookingCubit>().cancelBooking(booking);
                        }
                      },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel booking'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEAF7EF) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          active ? 'Booked' : 'Cancelled',
          style: AppTextStyles.caption.copyWith(
            color: active ? AppColors.success : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
