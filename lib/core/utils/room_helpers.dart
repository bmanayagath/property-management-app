import '../../domain/models/room.dart';

String getRoomDropdownLabel(Room room) {
  if (room.status.toLowerCase() == 'vacant') {
    return '${room.roomName} - Vacant';
  }

  if (room.tenantName.trim().isNotEmpty) {
    return '${room.roomName} - ${room.tenantName.trim()}';
  }

  return '${room.roomName} - Occupied';
}

int compareRoomsNaturally(Room left, Room right) {
  return compareNaturalText(left.roomName, right.roomName);
}

int compareNaturalText(String left, String right) {
  final leftParts = _naturalParts(left);
  final rightParts = _naturalParts(right);
  final length = leftParts.length < rightParts.length
      ? leftParts.length
      : rightParts.length;

  for (var index = 0; index < length; index++) {
    final leftPart = leftParts[index];
    final rightPart = rightParts[index];
    final result = leftPart.compareTo(rightPart);
    if (result != 0) return result;
  }

  return leftParts.length.compareTo(rightParts.length);
}

List<_NaturalPart> _naturalParts(String value) {
  final matches = RegExp(r'\d+|\D+').allMatches(value.trim().toLowerCase());
  return matches.map((match) {
    final text = match.group(0) ?? '';
    final number = int.tryParse(text);
    return _NaturalPart(text: text, number: number);
  }).toList();
}

class _NaturalPart {
  final String text;
  final int? number;

  const _NaturalPart({
    required this.text,
    required this.number,
  });

  int compareTo(_NaturalPart other) {
    final leftNumber = number;
    final rightNumber = other.number;
    if (leftNumber != null && rightNumber != null) {
      final numberCompare = leftNumber.compareTo(rightNumber);
      if (numberCompare != 0) return numberCompare;
      return text.length.compareTo(other.text.length);
    }
    return text.compareTo(other.text);
  }
}
