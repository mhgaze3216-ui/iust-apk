// ─────────────────────────────────────────────────────────────────────────────
// University Transport Schedule Data
// Source: Proposed/suggested schedule poster from IUST.
// IMPORTANT: These are proposed schedules (مواعيد مقترحة), not officially
// confirmed university data. Label accordingly in all UI.
// TODO: Replace with real API when backend transport module is ready.
// ─────────────────────────────────────────────────────────────────────────────

/// Direction of travel.
enum TransportDirection { toUniversity, fromUniversity }

/// A single area pickup entry.
class TransportStop {
  final String transportScheduleId;
  final TransportDirection direction;
  final String wave;          // e.g. 'morning1' | 'return_1045'
  final String area;          // e.g. 'برزة / حاميش / الحياة'
  final String? pickupPoint;  // optional extra detail
  final String departureTime; // earliest departure 'HH:MM'
  final String? endTime;      // latest pickup window 'HH:MM' (null = single time)
  final bool isProposed;      // always true for this dataset

  const TransportStop({
    required this.transportScheduleId,
    required this.direction,
    required this.wave,
    required this.area,
    this.pickupPoint,
    required this.departureTime,
    this.endTime,
    this.isProposed = true,
  });

  /// Minutes from midnight for the departure time — used for nearest-trip logic.
  int get departureMinutes {
    final p = departureTime.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// MORNING WAVE 1 — الصباحي الأول
// ════════════════════════════════════════════════════════════════════════════
const kMorning1 = <TransportStop>[
  TransportStop(transportScheduleId: 'tm1-01', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'برزة / حاميش / الحياة',      departureTime: '06:40', endTime: '07:00'),
  TransportStop(transportScheduleId: 'tm1-02', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'الميسات / 29 أيار',           departureTime: '06:45', endTime: '07:00'),
  TransportStop(transportScheduleId: 'tm1-03', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'عدوي',                         departureTime: '06:40', endTime: '06:50'),
  TransportStop(transportScheduleId: 'tm1-04', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'الزاهرة',                      departureTime: '06:50', endTime: '07:05'),
  TransportStop(transportScheduleId: 'tm1-05', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'شارع بغداد',                   departureTime: '06:35', endTime: '06:45'),
  TransportStop(transportScheduleId: 'tm1-06', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'مجتهد / باب مصلى',            departureTime: '06:40', endTime: '07:00'),
  TransportStop(transportScheduleId: 'tm1-07', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'بيلا',                         departureTime: '06:35', endTime: '06:40'),
  TransportStop(transportScheduleId: 'tm1-08', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'كفرسوسة',                      departureTime: '06:45', endTime: '06:55'),
  TransportStop(transportScheduleId: 'tm1-09', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'أبو رمانة / الجاحظ',          departureTime: '06:40', endTime: '07:00'),
  TransportStop(transportScheduleId: 'tm1-10', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'مزة استراد',                   departureTime: '06:40', endTime: '06:55'),
  TransportStop(transportScheduleId: 'tm1-11', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'مزة / المواساة',               departureTime: '06:30', endTime: '06:45'),
  TransportStop(transportScheduleId: 'tm1-12', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'الهامة / قدسيا',               departureTime: '06:30', endTime: '06:40'),
  TransportStop(transportScheduleId: 'tm1-13', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'قرى الشام',                    departureTime: '06:40', endTime: '06:50'),
  TransportStop(transportScheduleId: 'tm1-14', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'ضاحية قدسيا',                  departureTime: '06:40', endTime: '06:50'),
  TransportStop(transportScheduleId: 'tm1-15', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'مشروع دمر',                    departureTime: '06:45', endTime: '06:55'),
  TransportStop(transportScheduleId: 'tm1-16', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'صحنايا',                       departureTime: '06:40', endTime: '07:25'),
  TransportStop(transportScheduleId: 'tm1-17', direction: TransportDirection.toUniversity, wave: 'morning1', area: 'جديدة عرطوز',                  departureTime: '06:50', endTime: '07:00'),
];

// ════════════════════════════════════════════════════════════════════════════
// MORNING WAVE 2 — الصباحي الثاني
// ════════════════════════════════════════════════════════════════════════════
const kMorning2 = <TransportStop>[
  TransportStop(transportScheduleId: 'tm2-01', direction: TransportDirection.toUniversity, wave: 'morning2', area: 'ضاحية قدسيا',                  departureTime: '08:25', endTime: '08:30'),
  TransportStop(transportScheduleId: 'tm2-02', direction: TransportDirection.toUniversity, wave: 'morning2', area: 'مشروع دمر',                    departureTime: '08:35', endTime: '08:45'),
  TransportStop(transportScheduleId: 'tm2-03', direction: TransportDirection.toUniversity, wave: 'morning2', area: 'مزة / المواساة',               departureTime: '08:30', endTime: '08:45'),
  TransportStop(transportScheduleId: 'tm2-04', direction: TransportDirection.toUniversity, wave: 'morning2', area: 'مزة استراد',                   departureTime: '08:50', endTime: '08:55'),
  TransportStop(transportScheduleId: 'tm2-05', direction: TransportDirection.toUniversity, wave: 'morning2', area: 'كفرسوسة',                      departureTime: '08:50', endTime: '08:55'),
  TransportStop(transportScheduleId: 'tm2-06', direction: TransportDirection.toUniversity, wave: 'morning2', area: 'أبو رمانة / الجاحظ',          departureTime: '08:30', endTime: '08:35'),
  TransportStop(transportScheduleId: 'tm2-07', direction: TransportDirection.toUniversity, wave: 'morning2', area: 'باب مصلى',                     departureTime: '08:30', endTime: '08:45'),
  TransportStop(transportScheduleId: 'tm2-08', direction: TransportDirection.toUniversity, wave: 'morning2', area: 'دار الشفاء / عدوي',            departureTime: '08:30', endTime: '08:50'),
  TransportStop(transportScheduleId: 'tm2-09', direction: TransportDirection.toUniversity, wave: 'morning2', area: 'برزة / الميسات',               departureTime: '08:15', endTime: '08:50'),
  TransportStop(transportScheduleId: 'tm2-10', direction: TransportDirection.toUniversity, wave: 'morning2', area: 'جديدة عرطوز',                  departureTime: '08:25', endTime: '08:30'),
  TransportStop(transportScheduleId: 'tm2-11', direction: TransportDirection.toUniversity, wave: 'morning2', area: 'صحنايا',                       departureTime: '08:40', endTime: '08:45'),
];

// ════════════════════════════════════════════════════════════════════════════
// MORNING WAVE 3 — الصباحي الثالث
// ════════════════════════════════════════════════════════════════════════════
const kMorning3 = <TransportStop>[
  TransportStop(transportScheduleId: 'tm3-01', direction: TransportDirection.toUniversity, wave: 'morning3', area: 'عدوي',                         departureTime: '09:30', endTime: '09:45'),
  TransportStop(transportScheduleId: 'tm3-02', direction: TransportDirection.toUniversity, wave: 'morning3', area: 'الزاهرة',                      departureTime: '09:50', endTime: '10:10'),
  TransportStop(transportScheduleId: 'tm3-03', direction: TransportDirection.toUniversity, wave: 'morning3', area: 'برزة / الميسات',               departureTime: '09:15', endTime: '09:50'),
  TransportStop(transportScheduleId: 'tm3-04', direction: TransportDirection.toUniversity, wave: 'morning3', area: 'أبو رمانة / الجاحظ',          departureTime: '09:30', endTime: '09:35'),
  TransportStop(transportScheduleId: 'tm3-05', direction: TransportDirection.toUniversity, wave: 'morning3', area: 'مزة / شام سنتر',              departureTime: '09:40', endTime: '10:10'),
  TransportStop(transportScheduleId: 'tm3-06', direction: TransportDirection.toUniversity, wave: 'morning3', area: 'ضاحية قدسيا / مشروع دمر',    departureTime: '09:25', endTime: '10:05'),
];

// All morning stops combined — for nearest-trip logic
final kAllMorningStops = [...kMorning1, ...kMorning2, ...kMorning3];

// ════════════════════════════════════════════════════════════════════════════
// RETURN TRIPS — العودة من الجامعة
// ════════════════════════════════════════════════════════════════════════════

/// A return departure with its set of areas.
class ReturnTrip {
  final String departureTime; // 'HH:MM'
  final List<String> areas;
  final String? note;         // for the last trip "جميع مراكز الانطلاق الصباحي الأول"
  const ReturnTrip({required this.departureTime, required this.areas, this.note});

  int get departureMinutes {
    final p = departureTime.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }
}

const kReturnTrips = <ReturnTrip>[
  ReturnTrip(departureTime: '10:45', areas: ['نهر عيشة', 'فحامة', 'سانا', 'مزة']),
  ReturnTrip(departureTime: '11:45', areas: ['مزة', 'الجاحظ', 'شام سنتر', 'الميسات', 'برزة', 'عدوي', 'باب مصلى', 'مشروع دمر', 'ضاحية قدسيا']),
  ReturnTrip(departureTime: '13:00', areas: ['مزة', 'الجاحظ', 'شام سنتر', 'الميسات', 'عدوي', 'باب مصلى', 'برزة', 'مشروع دمر', 'ضاحية قدسيا', 'قرى الشام', 'صحنايا']),
  ReturnTrip(departureTime: '14:00', areas: ['مزة', 'الجاحظ', 'كفرسوسة', 'الميسات', 'عدوي', 'باب مصلى', 'برزة', 'مشروع دمر', 'ضاحية قدسيا']),
  ReturnTrip(departureTime: '15:45', areas: [], note: 'جميع مراكز الانطلاق الصباحي الأول'),
];

// ════════════════════════════════════════════════════════════════════════════
// Nearest-trip helpers
// ════════════════════════════════════════════════════════════════════════════

/// Returns the earliest morning stop departing at or after [nowMinutes].
TransportStop? nearestMorningStop(int nowMinutes) {
  final upcoming = kAllMorningStops
      .where((s) => s.departureMinutes >= nowMinutes)
      .toList()
    ..sort((a, b) => a.departureMinutes.compareTo(b.departureMinutes));
  return upcoming.isEmpty ? null : upcoming.first;
}

/// Returns the next return trip at or after [nowMinutes].
ReturnTrip? nearestReturnTrip(int nowMinutes) {
  final upcoming = kReturnTrips
      .where((r) => r.departureMinutes >= nowMinutes)
      .toList()
    ..sort((a, b) => a.departureMinutes.compareTo(b.departureMinutes));
  return upcoming.isEmpty ? null : upcoming.first;
}

/// Current time as minutes from midnight.
int get currentMinutes {
  final now = DateTime.now();
  return now.hour * 60 + now.minute;
}

/// Structured information about the nearest upcoming transport trip.
class NearestTripInfo {
  final String waveName;       // e.g. 'الصباحي الأول', 'الصباحي الثاني', 'الصباحي الثالث', 'العودة من الجامعة'
  final String departureTime;  // e.g. '06:30', '08:15', '14:00'
  final String tripType;       // 'انطلاق نحو الجامعة' | 'رحلة عودة من الجامعة'
  final int stopsCount;        // number of stops or areas
  final List<String> areas;
  final bool hasTripsLeft;

  const NearestTripInfo({
    required this.waveName,
    required this.departureTime,
    required this.tripType,
    this.stopsCount = 0,
    this.areas = const [],
    required this.hasTripsLeft,
  });

  const NearestTripInfo.none()
      : waveName = '',
        departureTime = '',
        tripType = '',
        stopsCount = 0,
        areas = const [],
        hasTripsLeft = false;
}

/// Calculates the nearest future trip dynamically from the current time and global dataset.
NearestTripInfo getNearestTrip([DateTime? time]) {
  final now = time ?? DateTime.now();
  final nowMinutes = now.hour * 60 + now.minute;

  // 1. Morning 1 (starts at 06:30, last stop departs at 06:50)
  final m1Upcoming = kMorning1.where((s) => s.departureMinutes >= nowMinutes).toList();
  if (m1Upcoming.isNotEmpty) {
    m1Upcoming.sort((a, b) => a.departureMinutes.compareTo(b.departureMinutes));
    return NearestTripInfo(
      waveName: 'الصباحي الأول',
      departureTime: m1Upcoming.first.departureTime,
      tripType: 'انطلاق نحو الجامعة',
      stopsCount: kMorning1.length,
      areas: kMorning1.map((s) => s.area).toList(),
      hasTripsLeft: true,
    );
  }

  // 2. Morning 2 (starts at 08:15, last stop departs at 08:50)
  final m2Upcoming = kMorning2.where((s) => s.departureMinutes >= nowMinutes).toList();
  if (m2Upcoming.isNotEmpty) {
    m2Upcoming.sort((a, b) => a.departureMinutes.compareTo(b.departureMinutes));
    return NearestTripInfo(
      waveName: 'الصباحي الثاني',
      departureTime: m2Upcoming.first.departureTime,
      tripType: 'انطلاق نحو الجامعة',
      stopsCount: kMorning2.length,
      areas: kMorning2.map((s) => s.area).toList(),
      hasTripsLeft: true,
    );
  }

  // 3. Morning 3 (starts at 09:15, last stop departs at 09:50)
  final m3Upcoming = kMorning3.where((s) => s.departureMinutes >= nowMinutes).toList();
  if (m3Upcoming.isNotEmpty) {
    m3Upcoming.sort((a, b) => a.departureMinutes.compareTo(b.departureMinutes));
    return NearestTripInfo(
      waveName: 'الصباحي الثالث',
      departureTime: m3Upcoming.first.departureTime,
      tripType: 'انطلاق نحو الجامعة',
      stopsCount: kMorning3.length,
      areas: kMorning3.map((s) => s.area).toList(),
      hasTripsLeft: true,
    );
  }

  // 4. Return trips (10:45, 11:45, 13:00, 14:00, 15:45)
  final returnUpcoming = kReturnTrips.where((r) => r.departureMinutes >= nowMinutes).toList();
  if (returnUpcoming.isNotEmpty) {
    returnUpcoming.sort((a, b) => a.departureMinutes.compareTo(b.departureMinutes));
    final nextReturn = returnUpcoming.first;
    return NearestTripInfo(
      waveName: 'العودة من الجامعة',
      departureTime: nextReturn.departureTime,
      tripType: 'رحلة عودة من الجامعة',
      stopsCount: nextReturn.areas.isNotEmpty ? nextReturn.areas.length : kMorning1.length,
      areas: nextReturn.areas,
      hasTripsLeft: true,
    );
  }

  // 5. Finished for today
  return const NearestTripInfo.none();
}
