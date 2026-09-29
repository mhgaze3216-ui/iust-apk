// ─────────────────────────────────────────────────────────────────────────────
// OFFICIAL DENTISTRY STUDY PLAN
// studyPlanId: study-plan-dentistry
// majorId:     major-dentistry
// facultyId:   faculty-dentistry
// totalYears:  5   |   requiredCreditHours: 180
//
// Rules applied:
//  • courseCode = null when no official code was provided in the plan.
//  • secondaryCourseCode used where the plan lists two codes (theory + practical).
//  • credits = numeric total; rawCreditsLabel preserves "1+2" notation for display.
//  • Completion status is NOT derived here — it must come from Hamza's Grade records.
//  • Existing course codes from kHistoricalGrades are reused (no duplicates).
// ─────────────────────────────────────────────────────────────────────────────

import '../models/student_models.dart';

// ── convenience shorthand ──────────────────────────────────────────────────
const _plan = 'study-plan-dentistry';
const _major = 'major-dentistry';

// ── confirmed code → internal courseId mappings (from existing records) ─────
// These reuse existing Grade/Course records — no new course objects created.
const _cMolBio   = 'course-201102';   // 201102 علم الحياة الجزيئية
const _cTeethAna = 'course-701122';   // 701122 تشريح ورسم الأسنان
const _cPhysio   = 'course-701113';   // 701113 علم وظائف الأعضاء (theory)
const _cHisto1   = 'course-701251';   // 701251 علم النسج (1)
const _cOrgChem  = 'course-201123';   // 201123/201127 كيمياء عضوية
const _cComp1    = 'course-401101';   // 401101 مهارات حاسوب (1)
const _cComp2    = 'course-401201';   // 401201 مهارات حاسوب (2)
const _cDentMat1 = 'course-101201';   // 101201 المواد السنية (1)
const _cPrevDent = 'course-101221';   // 101221 طب الأسنان الوقائي
const _cGenAnat  = 'course-701221';   // 701221 التشريح العام
const _cMicro    = 'course-701281';   // 701281 علم الأحياء الدقيقة
const _cEmbryol  = 'course-701241';   // 701241 علم الجنين الخاص بالفم والأسنان
const _cBioChem1 = 'course-602108';   // 602108/602109 كيمياء حيوية (1)
const _cOralHist = 'course-701272';   // 701272 علم النسج الفموي (2)
const _cRadiol   = 'course-101231';   // 101231 علم الأشعة السنية
const _cCons1    = 'course-101234';   // 101234 مداواة الأسنان المحافظة (1)
const _cBioChem2 = 'course-701212';   // 701212 كيمياء حيوية (2)
const _cCons2    = 'course-101334';   // 101334 مداواة الأسنان المحافظة (2)
const _cExtrac1  = 'course-101381';   // 101381 التخدير والقلع (1)
const _cPathol   = 'course-701351';   // 701351 التشريح المرضي العام

// ── full study plan course list ───────────────────────────────────────────────
final kDentistryStudyPlanCourses = <StudyPlanCourse>[

  // ══════════════════════════════════════════════════════════════════════════
  // YEAR 1 — SEMESTER 1
  // ══════════════════════════════════════════════════════════════════════════
  StudyPlanCourse(
    id: 'spc-$_plan-y1s1-1', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 1,
    courseId: null, courseCode: null,              // code not supplied in plan
    courseNameAr: 'فيزياء عامة للعلوم الطبية',
    credits: 3, rawCreditsLabel: '1+2',
    prerequisiteText: 'لا يوجد',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y1s1-2', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 1,
    courseId: null, courseCode: null,
    courseNameAr: 'كيمياء عامة للعلوم الطبية',
    credits: 3, rawCreditsLabel: '1+2',
    prerequisiteText: 'لا يوجد',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y1s1-3', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 1,
    courseId: _cMolBio, courseCode: '201102',
    courseNameAr: 'علم الحياة الجزيئية',
    credits: 3,
    prerequisiteText: 'لا يوجد',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y1s1-4', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 1,
    courseId: null, courseCode: null,
    courseNameAr: 'مهارات اللغة العربية',
    credits: 3,
    prerequisiteText: 'لا يوجد',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y1s1-5', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 1,
    courseId: _cTeethAna, courseCode: '701122',
    courseNameAr: 'تشريح ورسم الأسنان',
    credits: 3,
    prerequisiteText: 'لا يوجد',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y1s1-6', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 1,
    courseId: _cComp1, courseCode: '401101',
    courseNameAr: 'مهارات الحاسوب (1)',
    credits: 3,
    prerequisiteText: 'لا يوجد',
  ),

  // ══════════════════════════════════════════════════════════════════════════
  // YEAR 1 — SEMESTER 2
  // ══════════════════════════════════════════════════════════════════════════
  StudyPlanCourse(
    id: 'spc-$_plan-y1s2-1', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 2,
    courseId: _cOrgChem, courseCode: '201123',
    secondaryCourseCode: '201127',
    courseNameAr: 'كيمياء عضوية',
    credits: 3, rawCreditsLabel: '1+2',
    prerequisiteText: 'كيمياء عامة للعلوم الطبية',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y1s2-2', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 2,
    courseId: _cComp2, courseCode: '401201',
    courseNameAr: 'مهارات الحاسوب (2)',
    credits: 3,
    prerequisiteCourseIds: [_cComp1],
    prerequisiteText: 'مهارات الحاسوب (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y1s2-3', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 2,
    courseId: null, courseCode: null,
    courseNameAr: 'مهارات اللغة الإنكليزية (1)',
    credits: 3,
    prerequisiteText: 'لا يوجد',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y1s2-4', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 2,
    courseId: _cPhysio, courseCode: '701113',
    secondaryCourseCode: '701119',
    courseNameAr: 'علم وظائف الأعضاء',
    credits: 3, rawCreditsLabel: '1+2',
    prerequisiteCourseIds: [_cMolBio],
    prerequisiteText: 'علم الحياة الجزيئية',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y1s2-5', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 2,
    courseId: _cHisto1, courseCode: '701251',
    courseNameAr: 'علم النسج (1)',
    credits: 3,
    prerequisiteCourseIds: [_cMolBio],
    prerequisiteText: 'علم الحياة الجزيئية',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y1s2-6', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 2,
    courseId: null, courseCode: '701111',
    courseNameAr: 'علم الوراثة',
    credits: 1,
    prerequisiteCourseIds: [_cMolBio],
    prerequisiteText: 'علم الحياة الجزيئية',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y1s2-7', studyPlanId: _plan, majorId: _major,
    yearNumber: 1, semesterNumber: 2,
    courseId: null, courseCode: null,
    courseNameAr: 'متطلب جامعة اختياري',
    credits: 3,
    prerequisiteText: 'لا يوجد',
  ),

  // ══════════════════════════════════════════════════════════════════════════
  // YEAR 2 — SEMESTER 1
  // ══════════════════════════════════════════════════════════════════════════
  StudyPlanCourse(
    id: 'spc-$_plan-y2s1-1', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 1,
    courseId: _cDentMat1, courseCode: '101201',
    courseNameAr: 'المواد السنية (1)',
    credits: 2,
    minimumCompletedCredits: 30,
    prerequisiteText: '30 ساعة معتمدة',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s1-2', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 1,
    courseId: _cPrevDent, courseCode: '101221',
    courseNameAr: 'طب الأسنان الوقائي',
    credits: 2,
    minimumCompletedCredits: 30,
    prerequisiteText: '30 ساعة معتمدة',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s1-3', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 1,
    courseId: _cGenAnat, courseCode: '701221',
    courseNameAr: 'التشريح العام',
    credits: 3,
    prerequisiteCourseIds: [_cMolBio, _cTeethAna],
    prerequisiteText: 'علم الحياة الجزيئية + تشريح ورسم الأسنان',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s1-4', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 1,
    courseId: _cMicro, courseCode: '701281',
    courseNameAr: 'علم الأحياء الدقيقة',
    credits: 3, rawCreditsLabel: '1+2',
    prerequisiteCourseIds: [_cMolBio],
    prerequisiteText: 'علم الحياة الجزيئية',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s1-5', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 1,
    courseId: null, courseCode: '101292',
    courseNameAr: 'قوانين وأخلاقيات ممارسة طب الأسنان',
    credits: 1,
    minimumCompletedCredits: 32,
    prerequisiteText: '32 ساعة معتمدة',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s1-6', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 1,
    courseId: _cEmbryol, courseCode: '701241',
    courseNameAr: 'علم الجنين الخاص بالفم والأسنان',
    credits: 1,
    prerequisiteText: 'لا يوجد',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s1-7', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 1,
    courseId: _cBioChem1, courseCode: '602108',
    secondaryCourseCode: '602109',
    courseNameAr: 'كيمياء حيوية (1)',
    credits: 2, rawCreditsLabel: '1+1',
    prerequisiteCourseIds: [_cOrgChem],
    prerequisiteText: 'كيمياء عضوية',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s1-8', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 1,
    courseId: null, courseCode: null,
    courseNameAr: 'مهارات اللغة الإنكليزية (2)',
    credits: 3,
    prerequisiteText: 'مهارات اللغة الإنكليزية (1)',
  ),

  // ══════════════════════════════════════════════════════════════════════════
  // YEAR 2 — SEMESTER 2
  // ══════════════════════════════════════════════════════════════════════════
  StudyPlanCourse(
    id: 'spc-$_plan-y2s2-1', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 2,
    courseId: _cOralHist, courseCode: '701272',
    courseNameAr: 'علم النسج الفموي (2)',
    credits: 3,
    prerequisiteCourseIds: [_cHisto1],
    prerequisiteText: 'علم النسج (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s2-2', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 2,
    courseId: null, courseCode: '101202',
    courseNameAr: 'المواد السنية (2)',
    credits: 2,
    prerequisiteCourseIds: [_cDentMat1],
    prerequisiteText: 'المواد السنية (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s2-3', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 2,
    courseId: _cRadiol, courseCode: '101231',
    courseNameAr: 'علم الأشعة السنية',
    credits: 2,
    prerequisiteCourseIds: [_cGenAnat],
    prerequisiteText: 'التشريح العام',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s2-4', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 2,
    courseId: _cCons1, courseCode: '101234',
    courseNameAr: 'مداواة الأسنان المحافظة (1)',
    credits: 3,
    prerequisiteCourseIds: [_cDentMat1],
    prerequisiteText: 'المواد السنية (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s2-5', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 2,
    courseId: null, courseCode: '701261',
    courseNameAr: 'علم الأدوية الخاص بالفم والأسنان',
    credits: 2,
    prerequisiteCourseIds: [_cMicro, _cPhysio],
    prerequisiteText: 'علم الأحياء الدقيقة + علم وظائف الأعضاء',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s2-6', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 2,
    courseId: _cBioChem2, courseCode: '701212',
    courseNameAr: 'كيمياء حيوية (2)',
    credits: 2, rawCreditsLabel: '1+1',
    prerequisiteCourseIds: [_cBioChem1],
    prerequisiteText: 'كيمياء حيوية (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s2-7', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 2,
    courseId: null, courseCode: '701291',
    courseNameAr: 'الإحصاء الطبي',
    credits: 1,
    prerequisiteText: 'لا يوجد',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y2s2-8', studyPlanId: _plan, majorId: _major,
    yearNumber: 2, semesterNumber: 2,
    courseId: null, courseCode: '703311',
    courseNameAr: 'الجراحة العامة لطلبة طب الأسنان',
    credits: 3,
    prerequisiteCourseIds: [_cGenAnat],
    prerequisiteText: 'التشريح العام',
  ),

  // ══════════════════════════════════════════════════════════════════════════
  // YEAR 3 — SEMESTER 1
  // ══════════════════════════════════════════════════════════════════════════
  StudyPlanCourse(
    id: 'spc-$_plan-y3s1-1', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 1,
    courseId: null, courseCode: '101241',
    courseNameAr: 'تعويضات الأسنان الثابتة (1)',
    credits: 3,
    prerequisiteText: 'المواد السنية (2) + مداواة الأسنان المحافظة (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s1-2', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 1,
    courseId: _cCons2, courseCode: '101334',
    courseNameAr: 'مداواة الأسنان المحافظة (2)',
    credits: 3,
    prerequisiteCourseIds: [_cCons1],
    prerequisiteText: 'مداواة الأسنان المحافظة (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s1-3', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 1,
    courseId: null, courseCode: '101361',
    courseNameAr: 'علم الإطباق السني',
    credits: 1,
    minimumCompletedCredits: 70,
    prerequisiteText: '70 ساعة معتمدة',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s1-4', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 1,
    courseId: _cPathol, courseCode: '701351',
    courseNameAr: 'علم الأمراض (التشريح المرضي العام)',
    credits: 3,
    prerequisiteCourseIds: [_cOralHist],
    prerequisiteText: 'علم النسج الفموي (2)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s1-5', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 1,
    courseId: null, courseCode: '101344',
    courseNameAr: 'التعويضات السنية الجزئية المتحركة (1)',
    credits: 3,
    prerequisiteText: 'المواد السنية (2)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s1-6', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 1,
    courseId: null, courseCode: '702301',
    courseNameAr: 'الأمراض الجلدية وأمراض العين والأذن والأنف والحنجرة',
    credits: 2,
    minimumCompletedCredits: 70,
    prerequisiteText: '70 ساعة معتمدة',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s1-7', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 1,
    courseId: null, courseCode: '702221',
    courseNameAr: 'طب المجتمع وطب الأسنان الشرعي',
    credits: 2,
    prerequisiteCourseIds: [_cRadiol, _cGenAnat],
    prerequisiteText: 'علم الأشعة + التشريح العام',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s1-8', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 1,
    courseId: null, courseCode: '701371',
    courseNameAr: 'مكافحة العدوى',
    credits: 1,
    prerequisiteText: 'علم الأدوية الخاص بالفم والأسنان',
  ),

  // ══════════════════════════════════════════════════════════════════════════
  // YEAR 3 — SEMESTER 2
  // ══════════════════════════════════════════════════════════════════════════
  StudyPlanCourse(
    id: 'spc-$_plan-y3s2-1', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 2,
    courseId: null, courseCode: '101362',
    courseNameAr: 'تقويم الأسنان (1)',
    credits: 3,
    prerequisiteText: 'علم الإطباق السني',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s2-2', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 2,
    courseId: null, courseCode: '101343',
    courseNameAr: 'تعويضات الأسنان الثابتة (2)',
    credits: 3,
    prerequisiteText: 'تعويضات الأسنان الثابتة (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s2-3', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 2,
    courseId: _cExtrac1, courseCode: '101381',
    courseNameAr: 'التخدير والقلع (1)',
    credits: 3,
    prerequisiteCourseIds: [_cGenAnat],
    prerequisiteText: 'التشريح العام',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s2-4', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 2,
    courseId: null, courseCode: '101371',
    courseNameAr: 'أمراض النسج حول السنية (1)',
    credits: 3,
    minimumCompletedCredits: 70,
    prerequisiteCourseIds: [_cMicro],
    prerequisiteText: 'علم الأحياء الدقيقة + 70 ساعة معتمدة',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s2-5', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 2,
    courseId: null, courseCode: '701352',
    courseNameAr: 'التشريح المرضي الخاص بالفم والأسنان (1)',
    credits: 3,
    prerequisiteCourseIds: [_cPathol],
    prerequisiteText: 'التشريح المرضي العام',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y3s2-6', studyPlanId: _plan, majorId: _major,
    yearNumber: 3, semesterNumber: 2,
    courseId: null, courseCode: '702311',
    courseNameAr: 'الطب الداخلي لطلبة طب الأسنان',
    credits: 2,
    minimumCompletedCredits: 70,
    prerequisiteText: '70 ساعة معتمدة',
  ),

  // ══════════════════════════════════════════════════════════════════════════
  // YEAR 4 — SEMESTER 1
  // ══════════════════════════════════════════════════════════════════════════
  StudyPlanCourse(
    id: 'spc-$_plan-y4s1-1', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 1,
    courseId: null, courseCode: '101453',
    secondaryCourseCode: '101457',
    courseNameAr: 'طب الفم (1)',
    credits: 2, rawCreditsLabel: '1+1',
    minimumCompletedCredits: 100,
    prerequisiteText: '100 ساعة معتمدة',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y4s1-2', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 1,
    courseId: null, courseCode: '101435',
    courseNameAr: 'مداواة الأسنان المحافظة (3)',
    credits: 3,
    prerequisiteCourseIds: [_cCons2],
    prerequisiteText: 'مداواة الأسنان المحافظة (2)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y4s1-3', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 1,
    courseId: null, courseCode: '101441',
    courseNameAr: 'التعويضات السنية الجزئية المتحركة (2)',
    credits: 3,
    prerequisiteText: 'التعويضات السنية الجزئية المتحركة (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y4s1-4', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 1,
    courseId: null, courseCode: '701452',
    courseNameAr: 'التشريح المرضي الخاص بالفم والأسنان (2)',
    credits: 3,
    prerequisiteText: 'التشريح المرضي الخاص بالفم والأسنان (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y4s1-5', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 1,
    courseId: null, courseCode: '101461',
    courseNameAr: 'تقويم الأسنان (2)',
    credits: 3,
    prerequisiteText: 'تقويم الأسنان (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y4s1-6', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 1,
    courseId: null, courseCode: '101431',
    courseNameAr: 'مداواة الأسنان اللبية (1)',
    credits: 3,
    prerequisiteCourseIds: [_cCons2, _cRadiol],
    prerequisiteText: 'مداواة الأسنان المحافظة (2) + علم الأشعة',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y4s1-7', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 1,
    courseId: null, courseCode: '101483',
    courseNameAr: 'التخدير والقلع (2)',
    credits: 3,
    prerequisiteCourseIds: [_cExtrac1],
    prerequisiteText: 'التخدير والقلع (1)',
  ),

  // ══════════════════════════════════════════════════════════════════════════
  // YEAR 4 — SEMESTER 2
  // ══════════════════════════════════════════════════════════════════════════
  StudyPlanCourse(
    id: 'spc-$_plan-y4s2-1', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 2,
    courseId: null, courseCode: '101443',
    courseNameAr: 'تعويضات الأسنان الثابتة (3)',
    credits: 3,
    prerequisiteText: 'التخدير والقلع (2) + مداواة الأسنان المحافظة (3)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y4s2-2', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 2,
    courseId: null, courseCode: '101521',
    courseNameAr: 'التشخيص الشعاعي',
    credits: 2,
    prerequisiteText: 'التشريح المرضي الخاص بالفم والأسنان (2) + علم الأشعة',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y4s2-3', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 2,
    courseId: null, courseCode: '101472',
    courseNameAr: 'طب أسنان الأطفال (1)',
    credits: 3,
    prerequisiteText: 'مداواة الأسنان المحافظة (3) + التخدير والقلع (2)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y4s2-4', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 2,
    courseId: null, courseCode: '101473',
    courseNameAr: 'أمراض النسج حول السنية (2)',
    credits: 3,
    prerequisiteText: 'أمراض النسج حول السنية (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y4s2-5', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 2,
    courseId: null, courseCode: '101436',
    courseNameAr: 'مداواة الأسنان اللبية (2)',
    credits: 4,
    prerequisiteText: 'مداواة الأسنان اللبية (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y4s2-6', studyPlanId: _plan, majorId: _major,
    yearNumber: 4, semesterNumber: 2,
    courseId: null, courseCode: '101484',
    courseNameAr: 'التخدير والقلع (3)',
    credits: 3,
    prerequisiteText: 'التخدير والقلع (2)',
  ),

  // ══════════════════════════════════════════════════════════════════════════
  // YEAR 5 — SEMESTER 1
  // ══════════════════════════════════════════════════════════════════════════
  StudyPlanCourse(
    id: 'spc-$_plan-y5s1-1', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 1,
    courseId: null, courseCode: '101544',
    courseNameAr: 'تعويضات الأسنان الثابتة (4)',
    credits: 3,
    prerequisiteText: 'تعويضات الأسنان الثابتة (3)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s1-2', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 1,
    courseId: null, courseCode: '101442',
    courseNameAr: 'التعويضات السنية الكاملة المتحركة (1)',
    credits: 3,
    prerequisiteText: 'التعويضات السنية الجزئية المتحركة (2)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s1-3', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 1,
    courseId: null, courseCode: '101573',
    courseNameAr: 'زرع الأسنان',
    credits: 2,
    minimumCompletedCredits: 130,
    prerequisiteText: '130 ساعة معتمدة',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s1-4', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 1,
    courseId: null, courseCode: '101574',
    courseNameAr: 'أمراض النسج حول السنية (3)',
    credits: 3,
    prerequisiteText: 'أمراض النسج حول السنية (2)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s1-5', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 1,
    courseId: null, courseCode: '101557',
    courseNameAr: 'طب الفم (2)',
    credits: 2, rawCreditsLabel: '1+1',
    prerequisiteText: 'طب الفم (1) نظري + عملي',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s1-6', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 1,
    courseId: null, courseCode: '701575',
    courseNameAr: 'طب الأسنان الشيخوخي',
    credits: 1,
    minimumCompletedCredits: 100,
    prerequisiteText: '100 ساعة معتمدة',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s1-7', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 1,
    courseId: null, courseCode: '101556',
    courseNameAr: 'مداواة الأسنان اللبية (3)',
    credits: 4,
    prerequisiteText: 'مداواة الأسنان اللبية (2)',
  ),

  // ══════════════════════════════════════════════════════════════════════════
  // YEAR 5 — SEMESTER 2
  // ══════════════════════════════════════════════════════════════════════════
  StudyPlanCourse(
    id: 'spc-$_plan-y5s2-1', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 2,
    courseId: null, courseCode: '101546',
    courseNameAr: 'التعويضات السنية الكاملة المتحركة (2)',
    credits: 3,
    prerequisiteText: 'التعويضات السنية الكاملة المتحركة (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s2-2', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 2,
    courseId: null, courseCode: '101537',
    courseNameAr: 'مداواة الأسنان اللبية (4)',
    credits: 1,
    prerequisiteText: 'مداواة الأسنان اللبية (3)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s2-3', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 2,
    courseId: null, courseCode: '101545',
    courseNameAr: 'تعويضات الأسنان الثابتة (5)',
    credits: 1,
    prerequisiteText: 'تعويضات الأسنان الثابتة (4)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s2-4', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 2,
    courseId: null, courseCode: '101575',
    courseNameAr: 'أمراض النسج حول السنية (4)',
    credits: 1,
    prerequisiteText: 'أمراض النسج حول السنية (3)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s2-5', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 2,
    courseId: null, courseCode: '101586',
    courseNameAr: 'جراحة الفم والوجه والفكين',
    credits: 4,
    prerequisiteText: 'التخدير والقلع (3)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s2-6', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 2,
    courseId: null, courseCode: '101571',
    courseNameAr: 'طب أسنان الأطفال (2)',
    credits: 3,
    prerequisiteText: 'طب أسنان الأطفال (1)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s2-7', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 2,
    courseId: null, courseCode: '101535',
    courseNameAr: 'مداواة الأسنان المحافظة (4)',
    credits: 1,
    prerequisiteText: 'مداواة الأسنان المحافظة (3)',
  ),
  StudyPlanCourse(
    id: 'spc-$_plan-y5s2-8', studyPlanId: _plan, majorId: _major,
    yearNumber: 5, semesterNumber: 2,
    courseId: null, courseCode: '101585',
    courseNameAr: 'إعادة تأهيل الفم',
    credits: 2,
    minimumCompletedCredits: 140,
    prerequisiteText: '140 ساعة معتمدة',
  ),
];

// ── helper: set of course codes Hamza has passed ──────────────────────────────
// Derived from kHistoricalGrades. Used to compute completion status in UI.
// Do NOT use yearNumber to infer completion.
const kHamzaPassedCourseCodes = <String>{
  '101201', '101234', '201102', '602108', '602109',
  '701113', '701119', '701251', '701241', '701351',
  '101221', '201123', '201127', '401201', '701122',
  '701221', '101231', '101334', '101381', '701212',
  '701272', '701281', '401101', '601110', '602103',
  '602105', '603101', '608103',
};

/// Returns true if the plan row's primary or secondary code is in Hamza's
/// confirmed passed courses.
bool hamzaHasPassed(StudyPlanCourse row) {
  if (row.courseCode != null &&
      kHamzaPassedCourseCodes.contains(row.courseCode)) {
    return true;
  }
  if (row.secondaryCourseCode != null &&
      kHamzaPassedCourseCodes.contains(row.secondaryCourseCode)) {
    return true;
  }
  return false;
}
