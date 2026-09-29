import 'package:flutter/material.dart';

/// Data models for the University Campus Map system.
/// Ready for new university campus datasets.

class Building {
  final String id;
  final String name;
  final String code;
  final String description;
  final List<Floor> floors;
  final Rect? bounds;

  const Building({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
    this.floors = const [],
    this.bounds,
  });
}

class Floor {
  final String id;
  final String name;
  final int floorNumber;
  final List<Room> rooms;

  const Floor({
    required this.id,
    required this.name,
    required this.floorNumber,
    this.rooms = const [],
  });
}

class Room {
  final String id;
  final String name;
  final String roomNumber;
  final String type; // 'classroom', 'office', 'lab', 'hall', etc.
  final String? occupant;

  const Room({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.type,
    this.occupant,
  });
}

class MapLocation {
  final String id;
  final String name;
  final String category;
  final String? buildingId;
  final String? floorId;
  final Offset coordinates;

  const MapLocation({
    required this.id,
    required this.name,
    required this.category,
    this.buildingId,
    this.floorId,
    required this.coordinates,
  });
}

class MapMarker {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final Offset position;

  const MapMarker({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.position,
  });
}
