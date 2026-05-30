import 'package:flutter_test/flutter_test.dart';
import 'package:villabooks/core/utils/room_helpers.dart';
import 'package:villabooks/domain/models/room.dart';

void main() {
  test('room dropdown label includes tenant or occupancy status', () {
    expect(
      getRoomDropdownLabel(_room(
        roomName: 'Room 1',
        status: RoomStatuses.occupied,
        tenantName: 'Jini',
      )),
      'Room 1 - Jini',
    );
    expect(
      getRoomDropdownLabel(_room(
        roomName: 'Room 1',
        status: RoomStatuses.occupied,
        tenantName: '',
      )),
      'Room 1 - Occupied',
    );
    expect(
      getRoomDropdownLabel(_room(
        roomName: 'Room 1',
        status: 'VACANT',
        tenantName: 'Jini',
      )),
      'Room 1 - Vacant',
    );
  });

  test('rooms sort naturally by room name', () {
    final rooms = [
      _room(roomName: 'Room 11'),
      _room(roomName: 'Room 1'),
      _room(roomName: 'Room 10'),
      _room(roomName: 'Room 2'),
    ]..sort(compareRoomsNaturally);

    expect(
      rooms.map((room) => room.roomName),
      ['Room 1', 'Room 2', 'Room 10', 'Room 11'],
    );
  });
}

Room _room({
  required String roomName,
  String status = RoomStatuses.occupied,
  String tenantName = '',
}) {
  return Room(
    id: roomName,
    villaId: 'villa-1',
    villaName: 'Villa 1',
    roomName: roomName,
    tenantName: tenantName,
    tenantPhone: '',
    monthlyRent: 1000,
    contractStartDate: null,
    contractEndDate: null,
    paymentDueDay: 1,
    status: status,
    createdAt: DateTime(2026, 5, 30),
    updatedAt: null,
  );
}
