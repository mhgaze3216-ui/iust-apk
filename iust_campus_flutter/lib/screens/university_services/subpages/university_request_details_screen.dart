import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/university_services_demo_data.dart';
import '../widgets/university_services_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class UniversityRequestDetailsScreen extends StatelessWidget {
  final UniversityRequest request;

  const UniversityRequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              UniversityServicesHeader(
                title: 'تفاصيل الطلب',
                subtitle: request.id,
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    // Main Status & Meta Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: request.statusBgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  request.statusLabel,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: request.statusColor,
                                  ),
                                ),
                              ),
                              Text(
                                request.id,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _textSub,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            request.title,
                            style: GoogleFonts.cairo(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _textMain,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.corporate_fare_rounded, size: 15, color: _textSub),
                              const SizedBox(width: 6),
                              Text(
                                'الجهة: ${request.department}',
                                style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                              ),
                              const Spacer(),
                              Icon(Icons.calendar_today_rounded, size: 14, color: _textSub),
                              const SizedBox(width: 4),
                              Text(
                                request.date,
                                style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(color: Color(0xFFEDF2F7)),
                          const SizedBox(height: 8),
                          Text(
                            'وصف الطلب:',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _navy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request.description,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: _textMain,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Attachments Card
                    if (request.attachments.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.attach_file_rounded, size: 18, color: _blue),
                                const SizedBox(width: 8),
                                Text(
                                  'المرفقات (${request.attachments.length})',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _navy,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...request.attachments.map((file) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F9FC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.insert_drive_file_outlined, size: 16, color: _blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        file,
                                        style: GoogleFonts.cairo(fontSize: 12, color: _textMain),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      'تم إرفاقه',
                                      style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF16A34A)),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Status Timeline Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.history_rounded, size: 18, color: _blue),
                              const SizedBox(width: 8),
                              Text(
                                'سجل التحديثات ومراحل المعالجة',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _navy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...List.generate(request.timeline.length, (index) {
                            final entry = request.timeline[index];
                            final isLast = index == request.timeline.length - 1;

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: entry.isCompleted ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          entry.isCompleted ? Icons.check : Icons.more_horiz,
                                          size: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (!isLast)
                                        Expanded(
                                          child: Container(
                                            width: 2,
                                            color: entry.isCompleted ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.title,
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: entry.isCompleted ? _navy : _textSub,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            entry.date,
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              color: _textSub,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            entry.note,
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: _textMain,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
