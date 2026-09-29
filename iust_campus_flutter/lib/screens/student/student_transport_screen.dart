import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/transport_data.dart';

const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _gold      = Color(0xFFF5B82E);
const _goldLight = Color(0xFFFFF4D6);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

class StudentTransportScreen extends StatefulWidget {
  const StudentTransportScreen({super.key});
  @override
  State<StudentTransportScreen> createState() => _StudentTransportScreenState();
}

class _StudentTransportScreenState extends State<StudentTransportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('النقل الجامعي',
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain)),
          Text('مواعيد مقترحة',
              style: GoogleFonts.cairo(fontSize: 11, color: _gold, fontWeight: FontWeight.w600)),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Divider(height: 1, color: _border),
              TabBar(
                controller: _tabs,
                labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 12),
                unselectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w500, fontSize: 12),
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
            ]),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TabBarView(
          controller: _tabs,
          children: [
            _StopList(stops: kMorning1, waveLabel: 'الصباحي الأول'),
            _StopList(stops: kMorning2, waveLabel: 'الصباحي الثاني'),
            _StopList(stops: kMorning3, waveLabel: 'الصباحي الثالث'),
            _ReturnList(trips: kReturnTrips),
          ],
        ),
      ),
    );
  }
}

// ── Morning stop list ──────────────────────────────────────────────────────
class _StopList extends StatelessWidget {
  const _StopList({required this.stops, required this.waveLabel});
  final List<TransportStop> stops;
  final String waveLabel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: stops.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _ProposedBanner();
        final s = stops[i - 1];
        return _MorningCard(stop: s);
      },
    );
  }
}

class _MorningCard extends StatelessWidget {
  const _MorningCard({required this.stop});
  final TransportStop stop;

  @override
  Widget build(BuildContext context) {
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(11)),
          child: const Icon(Icons.directions_bus_rounded, color: _blue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(stop.area,
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
          if (stop.pickupPoint != null)
            Text(stop.pickupPoint!, style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(10)),
          child: Text(timeStr,
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: _navy)),
        ),
      ]),
    );
  }
}

// ── Return trip list ───────────────────────────────────────────────────────
class _ReturnList extends StatelessWidget {
  const _ReturnList({required this.trips});
  final List<ReturnTrip> trips;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: trips.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _ProposedBanner();
        return _ReturnCard(trip: trips[i - 1]);
      },
    );
  }
}

class _ReturnCard extends StatefulWidget {
  const _ReturnCard({required this.trip});
  final ReturnTrip trip;
  @override
  State<_ReturnCard> createState() => _ReturnCardState();
}

class _ReturnCardState extends State<_ReturnCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 42, height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _goldLight,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.directions_bus_rounded, color: _gold, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('انطلاق العودة',
                      style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
                  Text(t.departureTime,
                      style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800, color: _navy)),
                ])),
                Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: _textSub),
              ]),
              if (_expanded) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: _border),
                const SizedBox(height: 10),
                if (t.note != null)
                  Text(t.note!,
                      style: GoogleFonts.cairo(fontSize: 13, color: _textSub, fontStyle: FontStyle.italic))
                else
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: t.areas.map((a) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _lightBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: Text(a, style: GoogleFonts.cairo(fontSize: 12, color: _textMain)),
                    )).toList(),
                  ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class _ProposedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _goldLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _gold.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, color: _gold, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'هذه مواعيد مقترحة وليست رسمية مؤكدة من الجامعة.',
            style: GoogleFonts.cairo(fontSize: 12, color: _gold, fontWeight: FontWeight.w600),
          )),
        ]),
      );
}
