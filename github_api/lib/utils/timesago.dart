import 'package:timeago/timeago.dart' as timeago;

String timeAgoFromIso(String isoString) {
  try {
    final date = DateTime.parse(isoString).toLocal();
    return timeago.format(date);
  } catch (e) {
    return 'Invalid date';
  }
}