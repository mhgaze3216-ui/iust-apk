import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _blue     = Color(0xFF0d6efd);
const _lightBg  = Color(0xFFF4F7FE);
const _white    = Colors.white;
const _gold     = Color(0xFFc9a84c);
const _goldBg   = Color(0xFFFFF8E1);
const _blueBg   = Color(0xFFEEF4FF);
const _textDark = Color(0xFF0a2540);
const _textMute = Color(0xFF64748B);
const _border   = Color(0xFFE2E8F4);

class FinancialProceduresScreen extends StatelessWidget {
  const FinancialProceduresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _appBar(context, 'الرسوم والإجراءات المالية'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [

            // ── Deferral fees ─────────────────────────────────────────
            _SectionTitle('رسوم تأجيل الدراسة'),
            _FeeCard(
              label: 'كليتا طب الأسنان والصيدلة',
              fee: '30,000 ليرة سورية',
              note: 'عن كل فصل دراسي',
              featured: true,
            ),
            const SizedBox(height: 10),
            _FeeCard(
              label: 'بقية الكليات',
              fee: '15,000 ليرة سورية',
              note: 'عن كل فصل دراسي',
              featured: false,
            ),

            // ── Deferral conditions ───────────────────────────────────
            _SectionTitle('شروط التأجيل'),
            _BulletCard(items: const [
              'تقديم طلب التأجيل قبل انتهاء فترة الإضافة والحذف.',
              'إذا كان الطالب قد سجل مقررات دراسية، يجب عليه سحب جدوله الدراسي أولًا.',
            ]),

            // ── Required signatures ───────────────────────────────────
            _SectionTitle('التواقيع المطلوبة'),
            _NumberedCard(items: const [
              'مدير القبول والتسجيل.',
              'عميد الكلية.',
              'المدير المالي.',
              'رئيس الجامعة.',
            ]),

            // ── Return after absence ──────────────────────────────────
            _SectionTitle('العودة بعد الانقطاع'),
            _StepCard(
              title: 'بعد فصل دراسي واحد',
              steps: const [
                'تعبئة استمارة عودة إلى الدوام.',
                'دفع 25,000 ليرة سورية.',
                'إعادة التسجيل.',
              ],
            ),
            const SizedBox(height: 10),
            _StepCard(
              title: 'بعد فصلين دراسيين',
              steps: const [
                'تعبئة استمارة إعادة تسجيل.',
                'يُعامل الطالب ماليًا معاملة الطالب المستجد.',
              ],
            ),

            // ── Transfer between specializations ─────────────────────
            _SectionTitle('الانتقال بين التخصصات'),
            _FeeCard(
              label: 'الانتقال بين كليتين مختلفتين',
              fee: '5,000 ليرة سورية',
              note: '',
              featured: false,
            ),
            const SizedBox(height: 10),
            _FeeCard(
              label: 'الانتقال بين تخصصين ضمن الكلية نفسها',
              fee: 'مجانًا',
              note: '',
              featured: false,
            ),

            // ── Withdrawal ────────────────────────────────────────────
            _SectionTitle('الانسحاب'),
            _BulletCard(items: const [
              'يمكن للطالب الانسحاب من الجامعة أو من الفصل الدراسي قبل انتهاء فترة الإضافة والحذف.',
              'إذا لم ينسحب قبل انتهاء هذه الفترة، تبقى الرسوم الدراسية مستحقة عليه.',
            ]),

            // ── Refund ────────────────────────────────────────────────
            _SectionTitle('استرداد الرصيد الإضافي'),
            _BulletCard(items: const [
              'تسديد جميع رسوم الفصل الدراسي.',
              'تقديم طلب لاسترداد الرصيد.',
              'الحصول على موافقة رئيس الجامعة.',
            ]),

            // ── Bank accounts ─────────────────────────────────────────
            _SectionTitle('الحسابات المصرفية'),
            _BankCard(
                bankName: 'بنك سورية والخليج',
                accountNumber: '24024/1'),
            const SizedBox(height: 10),
            _BankCard(
                bankName: 'بنك الشرق',
                accountNumber: '200111'),
            const SizedBox(height: 10),
            _BankCard(
                bankName: 'المصرف الدولي للتجاري والتمويل',
                accountNumber: '23203'),

            // ── Deposit note ──────────────────────────────────────────
            const SizedBox(height: 20),
            _NoteCard(
              text:
                  'عند إيداع أي مبلغ يجب كتابة الاسم الكامل والرقم الجامعي.',
            ),
          ],
        ),
      ),
    );
  }
}

// ── shared widgets ────────────────────────────────────────────────────────

PreferredSizeWidget _appBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: _white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded,
          color: _textDark, size: 20),
      onPressed: () => Navigator.of(context).pop(),
    ),
    centerTitle: true,
    title: Text(title,
        style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textDark)),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: _border),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4, height: 20,
            decoration: BoxDecoration(
                color: _blue, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textDark)),
          ),
        ],
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({required this.items});
  final List<String> items;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 7),
                        child: Icon(Icons.circle, size: 7, color: _blue),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(e,
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: _textMute,
                                  height: 1.6))),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _NumberedCard extends StatelessWidget {
  const _NumberedCard({required this.items});
  final List<String> items;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24, height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: _blueBg, shape: BoxShape.circle),
                  child: Text('${i + 1}',
                      style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _blue)),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(items[i],
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: _textMute,
                            height: 1.6))),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Highlighted fee card
class _FeeCard extends StatelessWidget {
  const _FeeCard({
    required this.label,
    required this.fee,
    required this.note,
    required this.featured,
  });
  final String label, fee, note;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textDark)),
                if (note.isNotEmpty)
                  Text(note,
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: _textMute)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: featured ? _goldBg : _blueBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              fee,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: featured ? _gold : _blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Steps card with a title
class _StepCard extends StatelessWidget {
  const _StepCard({required this.title, required this.steps});
  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textDark)),
          const SizedBox(height: 10),
          ...List.generate(steps.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22, height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: _blueBg, shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _blue)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(steps[i],
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: _textMute,
                              height: 1.6))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Bank account card
class _BankCard extends StatelessWidget {
  const _BankCard(
      {required this.bankName, required this.accountNumber});
  final String bankName, accountNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _blueBg,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.account_balance_rounded,
                color: _blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bankName,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textDark)),
                const SizedBox(height: 2),
                Text('رقم الحساب: $accountNumber',
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _goldBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: _gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _gold,
                    height: 1.6)),
          ),
        ],
      ),
    );
  }
}
