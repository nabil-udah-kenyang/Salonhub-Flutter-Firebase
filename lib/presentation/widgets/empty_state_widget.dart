import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final IconData? icon;
  final Widget? customWidget;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.icon,
    this.customWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Custom Widget
            if (customWidget != null)
              customWidget!
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  icon ?? Icons.inbox_outlined,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),

            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: AppTheme.heading3,
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              PrimaryButton(
                text: buttonText!,
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateSearch extends StatelessWidget {
  final String query;
  final VoidCallback? onClearSearch;

  const EmptyStateSearch({
    super.key,
    required this.query,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: "No results found",
      subtitle: "We couldn't find anything for \"$query\"",
      buttonText: "Clear search",
      onButtonPressed: onClearSearch,
      icon: Icons.search_off,
    );
  }
}

class EmptyStateBookings extends StatelessWidget {
  final VoidCallback? onBookNow;

  const EmptyStateBookings({
    super.key,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: "No bookings yet",
      subtitle: "You haven't made any bookings yet. Start by booking a service at your favorite salon.",
      buttonText: "Book Now",
      onButtonPressed: onBookNow,
      icon: Icons.calendar_today,
    );
  }
}

class EmptyStateFavorites extends StatelessWidget {
  final VoidCallback? onBrowseSalons;

  const EmptyStateFavorites({
    super.key,
    this.onBrowseSalons,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: "No favorites yet",
      subtitle: "Start adding your favorite salons to see them here.",
      buttonText: "Browse Salons",
      onButtonPressed: onBrowseSalons,
      icon: Icons.favorite_border,
    );
  }
}

class EmptyStateNotifications extends StatelessWidget {
  final VoidCallback? onRefresh;

  const EmptyStateNotifications({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: "No notifications",
      subtitle: "You're all caught up! Check back later for new updates.",
      buttonText: "Refresh",
      onButtonPressed: onRefresh,
      icon: Icons.notifications_none,
    );
  }
}

class EmptyStateNetwork extends StatelessWidget {
  final VoidCallback? onRetry;

  const EmptyStateNetwork({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: "No internet connection",
      subtitle: "Please check your internet connection and try again.",
      buttonText: "Retry",
      onButtonPressed: onRetry,
      icon: Icons.wifi_off,
    );
  }
}

class EmptyStateError extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;

  const EmptyStateError({
    super.key,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: "Something went wrong",
      subtitle: error ?? "An unexpected error occurred. Please try again.",
      buttonText: "Try Again",
      onButtonPressed: onRetry,
      icon: Icons.error_outline,
    );
  }
}
