import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── palette ────────────────────────────────────────────────────────────────
const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

class StudentAssistantScreen extends StatefulWidget {
  const StudentAssistantScreen({super.key});
  @override
  State<StudentAssistantScreen> createState() =>
      _StudentAssistantScreenState();
}

class _StudentAssistantScreenState
    extends State<StudentAssistantScreen> {
  final _ctrl = TextEditingController();

  static const _chips = [
    'أين قاعة 4209؟',
    'ما محاضراتي اليوم؟',
    'ما متطلبات هذا المقرر؟',
    'كيف أصل إلى دائرة التسجيل؟',
    'ما موعد الامتحانات النهائية؟',
    'كيف أسحب مقرراً؟',
  ];

  // Mock conversation placeholder
  final _messages = const <_ChatMsg>[
    _ChatMsg(
      isBot: true,
      text: 'مرحباً! أنا مساعدك الذكي في IUST.\n'
          'يمكنني مساعدتك في الإجابة عن أي سؤال '
          'يتعلق بالجامعة، المواد، القاعات، والخدمات.',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // ── header ───────────────────────────────────────────────
              Container(
                color: _white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: _blue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المساعد الذكي',
                            style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _textMain)),
                        Text('اسأل عن الجامعة، المواد، القاعات والخدمات.',
                            style: GoogleFonts.cairo(
                                fontSize: 11, color: _textSub)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDFAF1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('قريباً',
                        style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E9B5F))),
                  ),
                ]),
              ),
              const Divider(height: 1, color: _border),

              // ── messages area ─────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // bot greeting
                    for (final msg in _messages) _BubbleCard(msg: msg),

                    const SizedBox(height: 16),

                    // suggestion chips title
                    Text('اقتراحات سريعة:',
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textSub)),
                    const SizedBox(height: 10),

                    // chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _chips.map((c) => _ChipBtn(
                            label: c,
                            onTap: () => setState(
                                () => _ctrl.text = c),
                          )).toList(),
                    ),

                    const SizedBox(height: 24),

                    // placeholder notice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _lightBlue,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _blue.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: _blue, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'المساعد الذكي قيد التطوير. '
                              'سيتم تفعيل الردود الفعلية بمجرد الاتصال '
                              'بالنظام الخلفي.',
                              style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: _blue,
                                  height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── input bar ─────────────────────────────────────────────
              Container(
                color: _white,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 0),
                      decoration: BoxDecoration(
                        color: _lightBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _border),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'اكتب سؤالك هنا...',
                          hintStyle: GoogleFonts.cairo(
                              fontSize: 13, color: _textSub),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('المساعد الذكي قيد التطوير. '
                              'سيتم تفعيله عند الاتصال بالنظام الخلفي.',
                              style: GoogleFonts.cairo()),
                          backgroundColor: _navy,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    child: Container(
                      width: 42, height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _navy,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: _white, size: 18),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── data + widgets ─────────────────────────────────────────────────────────
class _ChatMsg {
  final bool isBot;
  final String text;
  const _ChatMsg({required this.isBot, required this.text});
}

class _BubbleCard extends StatelessWidget {
  const _BubbleCard({required this.msg});
  final _ChatMsg msg;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isBot
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: msg.isBot ? _white : _navy,
          borderRadius: BorderRadius.circular(16),
          border: msg.isBot ? Border.all(color: _border) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(msg.text,
            style: GoogleFonts.cairo(
                fontSize: 13,
                color: msg.isBot ? _textMain : Colors.white,
                height: 1.6)),
      ),
    );
  }
}

class _ChipBtn extends StatelessWidget {
  const _ChipBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
          ),
          child: Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _navy)),
        ),
      );
}
