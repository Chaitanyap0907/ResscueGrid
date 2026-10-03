import 'package:intl/intl.dart';

class RgFormatters {
  RgFormatters._();

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  static String timeOnly(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String dateAndTime(DateTime dateTime) {
    return DateFormat('MMM d, y Â· h:mm a').format(dateTime);
  }

  static String distance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String eta(int minutes) {
    if (minutes <= 0) return 'Arrived';
    return '$minutes min';
  }

  static String duration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
