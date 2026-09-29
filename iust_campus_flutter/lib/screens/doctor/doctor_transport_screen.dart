import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/transport_data.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _gold = Color(0xFFF5B82E);
const _goldLight = Color(0xFFFFF4D6);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorTransportScreen extends StatefulWidget {
  const DoctorTransportScreen({super.key});

  @override
  State<DoctorTransportScreen> createState() => _DoctorTransportScreenState();
}

class _DoctorTransportScreenState extends State<DoctorTransportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabs.dispose();
    super.dispose();
  }

  List<TransportStop> _filterStops(List<TransportStop> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((s) {
      final areaMatches = s.area.toLowerCase().contains(_searchQuery);
      final pointMatches = s.pickupPoint?.toLowerCase().contains(_searchQuery) ?? false;
      return areaMatches || pointMatches;
    }).toList();
  }

  List<ReturnTrip> _filterReturnTrips(List<ReturnTrip> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((r) {
      final areaMatches = r.areas.any((a) => a.toLowerCase().contains(_searchQuery));
      final noteMatches = r.note?.toLowerCase().contains(_searchQuery) ?? false;
      return areaMatches || noteMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final nearest = getNearestTrip();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: _white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: const DoctorBackButton(),
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'النقل الجامعي',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              Text(
                'مواعيد الرحلات وأقرب انطلاق',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: _blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(49),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1, color: _border),
                  TabBar(
                    controller: _tabs,
                    labelStyle: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: GoogleFonts.cairo(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    labelColor: _navy,
                    unselectedLabelColor: _textSub,
                    indicatorColor: _navy,
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'الصباحي الأول'),
                      Tab(text: 'الصباحي الثاني'),
                      Tab(text: 'الصباحي الثالث'),
                      Tab(text: 'العودة من الجامعة'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // ── Nearest Trip Card & Search Bar ───────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                child: Column(
                  children: [
                    _buildNearestTripCard(nearest),
                    const SizedBox(height: 10),
                    _buildSearchBar(),
                  ],
                ),
              ),

              // ── Tab View Content ─────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _buildStopListView(_filterStops(kMorning1)),
                    _buildStopListView(_filterStops(kMorning2)),
                    _buildStopListView(_filterStops(kMorning3)),
                    _buildReturnListView(_filterReturnTrips(kReturnTrips)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearestTripCard(NearestTripInfo nearest) {
    if (!nearest.hasTripsLeft) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.no_transfer_rounded,
                color: _textSub,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لا توجد رحلات متبقية اليوم',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                  ),
                  Text(
                    'انتهت مواعيد رحلات اليوم. تفضل بمراجعة جدول الغد.',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: _textSub,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, _blue],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_bus_rounded,
              color: _gold,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'أقرب رحلة',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nearest.waveName,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${nearest.tripType} · ${nearest.stopsCount} نقطة / مسار',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              nearest.departureTime,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchCtrl,
      style: GoogleFonts.cairo(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'ابحث عن منطقة أو نقطة انطلاق...',
        hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: _navy),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () => _searchCtrl.clear(),
              )
            : null,
        filled: true,
        fillColor: _white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
      ),
    );
  }

  Widget _buildStopListView(List<TransportStop> stops) {
    if (stops.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مناطق تطابق البحث',
          style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      itemCount: stops.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _buildProposedBanner();
        final stop = stops[i - 1];
        final timeStr = stop.endTime != null
            ? '${stop.departureTime} – ${stop.endTime}'
            : stop.departureTime;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: _blue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.area,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textMain,
                      ),
                    ),
                    if (stop.pickupPoint != null)
                      Text(
                        stop.pickupPoint!,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: _textSub,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  timeStr,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReturnListView(List<ReturnTrip> trips) {
    if (trips.isEmpty) {
      return Center(
        child: Text(
          'لا توجد رحلات تطابق البحث',
          style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      itemCount: trips.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _buildProposedBanner();
        final trip = trips[i - 1];
        return _DoctorReturnCard(trip: trip);
      },
    );
  }

  Widget _buildProposedBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _goldLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _gold, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'هذه مواعيد مقترحة وشاملة لكافة كوادر وطلاب الجامعة.',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFFB78103),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorReturnCard extends StatefulWidget {
  final ReturnTrip trip;
  const _DoctorReturnCard({required this.trip});

  @override
  State<_DoctorReturnCard> createState() => _DoctorReturnCardState();
}

class _DoctorReturnCardState extends State<_DoctorReturnCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _goldLight,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: _gold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'انطلاق العودة من الجامعة',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: _textSub,
                            ),
                          ),
                          Text(
                            t.departureTime,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: _textSub,
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: _border),
                  const SizedBox(height: 10),
                  if (t.note != null)
                    Text(
                      t.note!,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: _navy,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: t.areas
                          .map((a) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _lightBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _border),
                                ),
                                child: Text(
                                  a,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    color: _textMain,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
