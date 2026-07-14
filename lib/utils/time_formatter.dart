String formatTimeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);
  if (difference.inDays >= 365) {
    final years = (difference.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  } else if (difference.inDays >= 30) {
    final months = (difference.inDays / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  } else if (difference.inDays >= 7) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
  } else if (difference.inDays >= 1) {
    return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  } else {
    final seconds = difference.inSeconds;
    return '${seconds < 0 ? 0 : seconds} ${seconds == 1 ? 'second' : 'seconds'} ago';
  }
}
