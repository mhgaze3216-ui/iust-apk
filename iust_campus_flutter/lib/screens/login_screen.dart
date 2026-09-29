import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_auth_service.dart';
import '../services/api_client.dart';
import '../services/mock_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _rememberMe  = false;
  bool _loading     = false;
  String? _errorMessage;

  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() { _loading = true; _errorMessage = null; });

    late final AuthResult result;
    try {
      result = await ApiAuthService.login(_userCtrl.text, _passCtrl.text);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = error.statusCode == 401
            ? 'اسم المستخدم أو كلمة المرور غير صحيحة'
            : 'تعذر تسجيل الدخول. تحقق من الاتصال وحاول مرة أخرى.';
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'تعذر الاتصال بالخادم. حاول مرة أخرى لاحقاً.';
      });
      return;
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      final route = MockAuthService.homeRouteForRole(result.role!);
      Navigator.of(context).pushNamedAndRemoveUntil(
        route,
        (r) => false,
        arguments: result.studentId ?? result.doctorId ?? result.staffId,
      );
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 992;
            if (isDesktop) {
              return Row(
                children: [
                  Expanded(child: _buildHeroSection()),
                  Expanded(child: _buildFormSection(isDesktop: true)),
                ],
              );
            } else {
              return Stack(
                children: [
                  SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: _buildFormSection(isDesktop: false),
                      ),
                    ),
                  ),
                  // ── back button ────────────────────────────────────
                  SafeArea(
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(context)
                                    .pushReplacementNamed('/welcome');
                              }
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF073B4C)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF073B4C)
                                      .withValues(alpha: 0.18),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF073B4C),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // ── Desktop hero (unchanged) ─────────────────────────────────────────────
  Widget _buildHeroSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0f172a), Color(0xFF1e3a8a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(48),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Row(
            children: const [
              Icon(Icons.memory, color: Colors.cyanAccent, size: 32),
              SizedBox(width: 8),
              Text('EduGuide AI',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('مرحباً بك في EduGuide AI',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                'مساعدك الجامعي الذكي الذي يساعد الطلاب في تنقلهم داخل الحرم '
                'الجامعي، العثور على القاعات، أستاذة المواد، والخدمات الجامعية '
                'المختلفة باستخدام الذكاء الاصطناعي.',
                style:
                    TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 18),
              ),
              const SizedBox(height: 48),
              _buildFeatureItem(
                  Icons.chat_bubble, 'المساعد الذكي (AI Chat Assistant)'),
              const SizedBox(height: 16),
              _buildFeatureItem(
                  Icons.map, 'الخريطة التفاعلية للحرم الجامعي'),
              const SizedBox(height: 16),
              _buildFeatureItem(Icons.badge, 'دليل أعضاء هيئة التدريس'),
              const SizedBox(height: 16),
              _buildFeatureItem(Icons.book, 'مستكشف المواد الدراسية'),
            ],
          ),
            Text('© 2026 EduGuide AI. جميع الحقوق محفوظة.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.2),
                shape: BoxShape.circle),
            child: Icon(icon, color: Colors.cyanAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // ── Form section – role selector removed ────────────────────────────────
  Widget _buildFormSection({bool isDesktop = false}) {
    return Container(
      color: Colors.white,
      padding: isDesktop
          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 32)
          : const EdgeInsets.fromLTRB(24, 12, 24, 24),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isDesktop) ...[
              // ── University Logo (Centered, Original Colors, 66x66) ──
              Center(
                child: Image.asset(
                  'assets/img/logo iust.webp',
                  height: 66,
                  width: 66,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Image.asset(
                    'assets/img/logo_iust.png',
                    height: 66,
                    width: 66,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.school_rounded,
                      color: AppTheme.darkBlue,
                      size: 66,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Header ──────────────────────────────────────────────────
            const Text(
              'مرحباً بك مجدداً',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'الرجاء إدخال بياناتك الأكاديمية للوصول إلى حسابك',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isDesktop ? 32 : 24),

            // ── Email ────────────────────────────────────────────────────
            const Text('البريد الإلكتروني الجامعي',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                    fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _userCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.email, color: AppTheme.textMuted),
                hintText: 'username@iust.edu.sy',
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0))),
              ),
            ),
            const SizedBox(height: 24),

            // ── Password ─────────────────────────────────────────────────
            const Text('كلمة المرور',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                    fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _passCtrl,
              obscureText: _obscureText,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.lock, color: AppTheme.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureText
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppTheme.textMuted),
                  onPressed: () =>
                      setState(() => _obscureText = !_obscureText),
                ),
                hintText: '••••••••',
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0))),
              ),
            ),
            const SizedBox(height: 16),

            // ── Remember me + Forgot password ────────────────────────────
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('تذكرني',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 13)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('استعادة كلمة المرور ستتوفر قريباً'),
                        backgroundColor: const Color(0xFF073B4C),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: const Text('نسيت كلمة المرور؟',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Error message ─────────────────────────────────────────
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF9A9A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Color(0xFFD32F2F), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Login button ─────────────────────────────────────────────
            ElevatedButton(
              onPressed: _loading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('تسجيل الدخول'),
            ),
            const SizedBox(height: 24),

            // ── Create account ───────────────────────────────────────────
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('ليس لديك حساب؟ ',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 13)),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('إنشاء الحساب سيتوفر قريباً'),
                        backgroundColor: const Color(0xFF073B4C),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: const Text('إنشاء حساب جديد',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ],
            ),

            // ── Guest button ─────────────────────────────────────────────
            const Divider(height: 24),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/welcome');
              },
              icon: const Icon(Icons.explore_outlined,
                  color: AppTheme.textMuted, size: 18),
              label: const Text(
                'تصفح كضيف',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
