import 'dart:async';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'), // Arabic - primary
    Locale('en'), // English - secondary
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // App
      'app_name': 'لويا',
      'app_tagline': 'تتبع الزيارات. كافئ الولاء.',

      // Auth
      'welcome_back': 'مرحباً بعودتك',
      'sign_in_to_continue': 'سجل الدخول للمتابعة',
      'phone_number': 'رقم الجوال',
      'enter_phone': 'أدخل رقم جوالك',
      'continue_btn': 'متابعة',
      'verification_code': 'رمز التحقق',
      'enter_otp': 'أدخل الرمز المرسل إلى',
      'resend_code': 'إعادة إرسال الرمز',
      'resend_in': 'إعادة الإرسال خلال',
      'seconds': 'ثانية',
      'verify': 'تحقق',
      'wrong_number': 'رقم خاطئ؟',
      'change_number': 'تغيير الرقم',

      // Navigation
      'overview': 'نظرة عامة',
      'programs': 'البرامج',
      'customers': 'العملاء',
      'activity': 'النشاط',
      'analytics': 'التحليلات',
      'settings': 'الإعدادات',

      // Overview
      'good_morning': 'صباح الخير',
      'good_afternoon': 'مساء الخير',
      'good_evening': 'مساء الخير',
      'today_summary': 'ملخص اليوم',
      'total_customers': 'إجمالي العملاء',
      'active_programs': 'البرامج النشطة',
      'stamps_today': 'الطوابع اليوم',
      'rewards_issued': 'المكافآت الممنوحة',
      'quick_actions': 'إجراءات سريعة',
      'add_stamp': 'إضافة طابع',
      'new_customer': 'عميل جديد',
      'recent_activity': 'النشاط الأخير',

      // Programs
      'my_programs': 'برامجي',
      'create_program': 'إنشاء برنامج',
      'edit_program': 'تعديل البرنامج',
      'program_name': 'اسم البرنامج',
      'program_description': 'وصف البرنامج',
      'stamps_required': 'الطوابع المطلوبة',
      'reward_description': 'وصف المكافأة',
      'program_color': 'لون البرنامج',
      'program_icon': 'أيقونة البرنامج',
      'program_status': 'حالة البرنامج',
      'active': 'نشط',
      'paused': 'متوقف',
      'save_program': 'حفظ البرنامج',
      'delete_program': 'حذف البرنامج',
      'program_preview': 'معاينة البرنامج',
      'program_limit_reached': 'وصلت للحد الأقصى من البرامج',
      'upgrade_to_create': 'قم بالترقية لإنشاء المزيد',
      'no_programs_yet': 'لا توجد برامج بعد',
      'create_first_program':
          'أنشئ برنامج الولاء الأول الخاص بك لبدء مكافأة عملائك.',

      // Customers
      'search_customers': 'ابحث عن عميل...',
      'customer_phone': 'رقم جوال العميل',
      'customer_name': 'اسم العميل (اختياري)',
      'customer_notes': 'ملاحظات (اختياري)',
      'add_customer': 'إضافة عميل',
      'customer_profile': 'ملف العميل',
      'visit_history': 'سجل الزيارات',
      'total_visits': 'إجمالي الزيارات',
      'rewards_earned': 'المكافآت المكتسبة',
      'member_since': 'عضو منذ',
      'last_visit': 'آخر زيارة',
      'add_tag': 'إضافة وسم',
      'tags': 'الوسوم',

      // Stamp Flow
      'stamp_customer': 'ختم للعميل',
      'enter_customer_phone': 'أدخل رقم جوال العميل',
      'customer_found': 'تم العثور على العميل',
      'new_customer_created': 'تم إنشاء عميل جديد',
      'current_progress': 'التقدم الحالي',
      'stamps': 'طوابع',
      'stamp_added': 'تم إضافة الطابع',
      'reward_unlocked': 'تم فتح المكافأة!',
      'congratulations': 'تهانينا!',

      // Analytics
      'this_week': 'هذا الأسبوع',
      'this_month': 'هذا الشهر',
      'last_30_days': 'آخر 30 يوم',
      'visits_chart': 'مخطط الزيارات',
      'returning_customers': 'العملاء المتكررون',
      'new_customers': 'عملاء جدد',
      'avg_visits_per_customer': 'متوسط الزيارات لكل عميل',

      // Settings
      'business_profile': 'الملف التجاري',
      'business_name': 'اسم النشاط التجاري',
      'business_phone': 'رقم جوال النشاط',
      'business_address': 'العنوان',
      'billing_plan': 'الفوترة والباقة',
      'current_plan': 'الباقة الحالية',
      'free_plan': 'مجاني',
      'pro_plan': 'احترافي',
      'business_plan': 'الأعمال',
      'upgrade_plan': 'ترقية الباقة',
      'wallet_settings': 'إعدادات المحفظة',
      'notifications': 'الإشعارات',
      'language': 'اللغة',
      'arabic': 'العربية',
      'english': 'English',
      'logout': 'تسجيل الخروج',
      'logout_confirm': 'هل أنت متأكد من تسجيل الخروج؟',

      // Plans & Billing
      'sar_month': 'ر.س / شهر',
      'free': 'مجاني',
      'features': 'المميزات',
      'program_limit': 'برنامج واحد',
      'programs_limit': 'برامج',
      'unlimited_programs': 'برامج غير محدودة',
      'passes_limit': 'بطاقتان',
      'unlimited_passes': 'بطاقات غير محدودة',
      'branch_limit': 'فرع واحد',
      'branches_limit': 'أفرع',
      'unlimited_branches': 'أفرع غير محدودة',
      'basic_customization': 'تخصيص أساسي',
      'full_customization': 'تخصيص كامل',
      'multi_access': 'وصول متعدد',
      'select_plan': 'اختر الباقة',
      'current': 'الحالية',

      // Common
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'close': 'إغلاق',
      'confirm': 'تأكيد',
      'done': 'تم',
      'next': 'التالي',
      'back': 'رجوع',
      'search': 'بحث',
      'filter': 'تصفية',
      'sort': 'ترتيب',
      'refresh': 'تحديث',
      'loading': 'جاري التحميل...',
      'no_data': 'لا توجد بيانات',
      'error_occurred': 'حدث خطأ',
      'try_again': 'حاول مجدداً',
      'success': 'تم بنجاح',
      'of': 'من',
      'all': 'الكل',
      'today': 'اليوم',
      'yesterday': 'أمس',

      // Activity
      'activity_subtitle': 'تابع جميع الأنشطة في متجرك',
      'rewards': 'المكافآت',

      // Analytics Extended
      'analytics_subtitle': 'تحليلات أداء متجرك',
      'total_stamps': 'إجمالي الطوابع',
      'rewards_given': 'المكافآت الممنوحة',
      'return_rate': 'معدل العودة',
      'stamps_over_time': 'الطوابع عبر الزمن',
      'customer_distribution': 'توزيع العملاء',
      'occasional': 'عرضي',
      'inactive': 'غير نشط',
      'programs_performance': 'أداء البرامج',

      // Settings Extended
      'settings_subtitle': 'إدارة حسابك وتفضيلاتك',
      'account': 'الحساب',
      'business_profile_desc': 'اسم النشاط والشعار ومعلومات الاتصال',
      'billing': 'الفوترة',
      'billing_desc': 'إدارة باقتك وطريقة الدفع',
      'preferences': 'التفضيلات',
      'notifications_desc': 'إشعارات البريد والتنبيهات',
      'integrations': 'التكاملات',
      'apple_wallet': 'Apple Wallet',
      'apple_wallet_desc': 'بطاقات الولاء لأجهزة آبل',
      'google_wallet': 'Google Wallet',
      'google_wallet_desc': 'بطاقات الولاء لأجهزة أندرويد',
      'connected': 'متصل',
      'coming_soon': 'قريباً',
      'support': 'الدعم',
      'help_center': 'مركز المساعدة',
      'help_center_desc': 'الأسئلة الشائعة والأدلة',
      'contact_support': 'تواصل معنا',
      'contact_support_desc': 'تحدث مع فريق الدعم',
      'danger_zone': 'منطقة الخطر',
      'sign_out': 'تسجيل الخروج',
      'sign_out_desc': 'الخروج من حسابك',
      'sign_out_confirm': 'هل أنت متأكد من تسجيل الخروج؟',
      'select_language': 'اختر اللغة',

      // Billing Screen
      'choose_plan': 'اختر باقتك',
      'currency': 'ر.س',
      'month': 'شهر',
      'popular': 'الأكثر شعبية',
      'upgrade': 'ترقية',
      'upgrade_confirm': 'هل تريد الترقية إلى هذه الباقة؟',
      'continue': 'متابعة',
      'faq': 'الأسئلة الشائعة',
      'faq_q1': 'هل يمكنني تغيير باقتي لاحقاً؟',
      'faq_a1': 'نعم، يمكنك الترقية أو التخفيض في أي وقت.',
      'faq_q2': 'ما هي طرق الدفع المتاحة؟',
      'faq_a2': 'نقبل جميع البطاقات الائتمانية عبر Tap Payments.',
      'faq_q3': 'هل هناك فترة تجريبية؟',
      'faq_a3': 'الباقة المجانية متاحة للأبد مع ميزات محدودة.',
      'feature_1_program': 'برنامج واحد',
      'feature_2_passes': 'بطاقتان فقط',
      'feature_basic_analytics': 'تحليلات أساسية',
      'feature_2_programs': 'برنامجان',
      'feature_3_programs': '3 برامج',
      'feature_500_passes': '500 بطاقة',
      'feature_2500_passes': '2,500 بطاقة',
      'feature_unlimited_passes': 'بطاقات غير محدودة',
      'feature_advanced_analytics': 'تحليلات متقدمة',
      'feature_priority_support': 'دعم أولوية',
      'feature_unlimited_programs': 'برامج غير محدودة',
      'feature_full_analytics': 'تحليلات كاملة',
      'feature_api_access': 'وصول API',
      'feature_dedicated_support': 'دعم مخصص',
      'feature_1_branch': 'فرع واحد',
      'feature_3_branches': '3 فروع',
      'feature_unlimited_branches': 'فروع غير محدودة',
      'feature_2_team_members': 'عضوان في الفريق',
      'feature_10_team_members': '10 أعضاء في الفريق',
      'feature_referral_program': 'برنامج الإحالات',
      'feature_automations': 'الأتمتة والتذكيرات',
      'feature_webhooks': 'Webhooks وAPI',
      'feature_email_support': 'دعم عبر البريد',

      // Business Profile
      'business_info': 'معلومات النشاط',
      'business_name_en': 'اسم النشاط (إنجليزي)',
      'business_name_ar': 'اسم النشاط (عربي)',
      'contact_info': 'معلومات الاتصال',
      'phone': 'الجوال',
      'email': 'البريد الإلكتروني',
      'address': 'العنوان',
      'business_id': 'معرف النشاط',
      'your_business_id': 'معرف نشاطك',
      'copied_to_clipboard': 'تم النسخ',
      'business_logo': 'شعار النشاط',
      'logo_requirements': 'PNG أو JPG، 512×512 بكسل',
      'upload_logo': 'رفع الشعار',
      'save_changes': 'حفظ التغييرات',
      'profile_saved': 'تم حفظ الملف الشخصي',

      // Stamp Flow Extended
      'find_customer': 'البحث عن عميل',
      'enter_phone_to_add_stamp': 'أدخل رقم الجوال لإضافة طابع',
      'phone_placeholder': 'رقم الجوال',
      'search_another': 'البحث عن عميل آخر',
      'customer_can_redeem': 'يمكن للعميل استبدال مكافأته',
      'add_another_stamp': 'إضافة طابع آخر',

      // Errors
      'error_invalid_phone': 'رقم جوال غير صالح',
      'error_otp_invalid': 'رمز التحقق غير صحيح',
      'error_otp_expired': 'انتهت صلاحية الرمز',
      'error_network': 'خطأ في الاتصال',
      'error_server': 'خطأ في الخادم',
      'error_unknown': 'خطأ غير معروف',

      // Plan names
      'starter_plan': 'Starter',
      'growth_plan': 'Growth',
      'advanced_plan': 'Advanced',

      // Upgrade prompts
      'upgrade_to_unlock': 'قم بالترقية لفتح هذه الميزة',
      'upgrade_now': 'ترقية الآن',
      'start_free_trial': 'ابدأ التجربة المجانية',
      'maybe_later': 'ربما لاحقاً',
      'available_in': 'متوفر في',
      'per_month_billed_annually': 'شهرياً (تُدفع سنوياً)',

      // Feature names and descriptions
      'feature_unlimited_customers': 'عملاء غير محدودين',
      'feature_unlimited_customers_desc': 'أضف عدد غير محدود من العملاء إلى برامج الولاء الخاصة بك',
      'feature_card_design': 'تصميم البطاقة',
      'feature_card_design_desc': 'صمم بطاقات ولاء احترافية لعملائك',
      'feature_card_customization': 'تخصيص البطاقة',
      'feature_card_customization_desc': 'خصص ألوان وأيقونات وتصميم بطاقات الولاء',
      'feature_multi_language': 'متعدد اللغات',
      'feature_multi_language_desc': 'ادعم عملاءك بلغات متعددة',
      'feature_basic_analytics_desc': 'تتبع أداء برامج الولاء الخاصة بك',
      'feature_review_collection': 'جمع التقييمات',
      'feature_review_collection_desc': 'اجمع تقييمات وآراء العملاء لتحسين خدماتك',
      'feature_location_push': 'إشعارات الموقع',
      'feature_location_push_desc': 'أرسل إشعارات للعملاء عند دخولهم منطقة محددة',
      'feature_custom_fields': 'حقول مخصصة',
      'feature_custom_fields_desc': 'أضف معلومات إضافية لملفات العملاء',
      'feature_tiered_membership': 'مستويات العضوية',
      'feature_tiered_membership_desc': 'أنشئ مستويات VIP مثل برونزي، فضي، ذهبي',
      'feature_referral_program_desc': 'كافئ العملاء على إحالة أصدقائهم',
      'feature_push_marketing': 'التسويق بالإشعارات',
      'feature_push_marketing_desc': 'أرسل عروض وإشعارات تسويقية لعملائك',
      'feature_automated_push': 'إشعارات تلقائية',
      'feature_automated_push_desc': 'أرسل إشعارات تلقائية لأعياد الميلاد والعملاء غير النشطين',
      'feature_email_marketing': 'التسويق بالبريد',
      'feature_email_marketing_desc': 'أرسل حملات بريد إلكتروني لعملائك',
      'feature_sms_marketing': 'التسويق بالرسائل',
      'feature_sms_marketing_desc': 'أرسل رسائل SMS تسويقية لعملائك',
      'feature_integrations': 'التكاملات',
      'feature_integrations_desc': 'اربط مع أنظمة خارجية مثل نقاط البيع وCRM',
      'feature_webhook_api': 'Webhook و API',
      'feature_webhook_api_desc': 'استخدم API لربط أنظمتك مع لويا',
      'feature_priority_support_desc': 'احصل على دعم فني سريع ومخصص',

      // Team Members
      'team_members': 'أعضاء الفريق',
      'team_members_desc': 'إدارة الموظفين والصلاحيات',
      'add_team_member': 'إضافة عضو',
      'member_name': 'اسم العضو',
      'member_role': 'الدور',
      'role_owner': 'مالك',
      'role_manager': 'مدير',
      'role_cashier': 'كاشير',
      'invite_member': 'دعوة عضو',
      'pending_invites': 'الدعوات المعلقة',

      // Referral Program
      'referral_reward': 'مكافأة الإحالة',
      'referrer_bonus': 'مكافأة المُحيل',
      'referee_bonus': 'مكافأة المُحال',
      'referral_link': 'رابط الإحالة',
      'total_referrals': 'إجمالي الإحالات',

      // Automation
      'automation': 'الأتمتة',
      'automation_desc': 'إشعارات تلقائية للعملاء',
      'automation_rules': 'قواعد الأتمتة',
      'add_rule': 'إضافة قاعدة',
      'edit_rule': 'تعديل القاعدة',
      'delete_rule': 'حذف القاعدة',
      'delete_rule_confirm': 'هل أنت متأكد من حذف هذه القاعدة؟',
      'rule_name': 'اسم القاعدة',
      'rule_name_hint': 'مثال: تهنئة عيد الميلاد',
      'message': 'الرسالة',
      'message_hint': 'أدخل نص الرسالة...',
      'no_automation_rules': 'لا توجد قواعد أتمتة',
      'trigger': 'المشغل',
      'action': 'الإجراء',
      'trigger_birthday': 'يوم ميلاد العميل',
      'trigger_inactive': 'عميل غير نشط',
      'trigger_reward_expiring': 'مكافأة ستنتهي',
      'trigger_first_visit': 'أول زيارة',
      'action_send_push': 'إرسال إشعار',
      'action_send_sms': 'إرسال SMS',
      'action_send_email': 'إرسال بريد',
      'action_add_stamps': 'إضافة طوابع',
      'inactive_days': 'أيام عدم النشاط',

      // Branches
      'branches': 'الفروع',
      'branches_desc': 'إدارة فروع نشاطك التجاري',
      'add_branch': 'إضافة فرع',
      'branch_name': 'اسم الفرع',
      'branch_address': 'عنوان الفرع',
      'branch_manager': 'مدير الفرع',
      'main_branch': 'الفرع الرئيسي',
    },
    'en': {
      // App
      'app_name': 'Loya',
      'app_tagline': 'Track visits. Reward loyalty.',

      // Auth
      'welcome_back': 'Welcome back',
      'sign_in_to_continue': 'Sign in to continue',
      'phone_number': 'Phone Number',
      'enter_phone': 'Enter your phone number',
      'continue_btn': 'Continue',
      'verification_code': 'Verification Code',
      'enter_otp': 'Enter the code sent to',
      'resend_code': 'Resend Code',
      'resend_in': 'Resend in',
      'seconds': 'seconds',
      'verify': 'Verify',
      'wrong_number': 'Wrong number?',
      'change_number': 'Change number',

      // Navigation
      'overview': 'Overview',
      'programs': 'Programs',
      'customers': 'Customers',
      'activity': 'Activity',
      'analytics': 'Analytics',
      'settings': 'Settings',

      // Overview
      'good_morning': 'Good morning',
      'good_afternoon': 'Good afternoon',
      'good_evening': 'Good evening',
      'today_summary': 'Today\'s summary',
      'total_customers': 'Total Customers',
      'active_programs': 'Active Programs',
      'stamps_today': 'Stamps Today',
      'rewards_issued': 'Rewards Issued',
      'quick_actions': 'Quick Actions',
      'add_stamp': 'Add Stamp',
      'new_customer': 'New Customer',
      'recent_activity': 'Recent Activity',

      // Programs
      'my_programs': 'My Programs',
      'create_program': 'Create Program',
      'edit_program': 'Edit Program',
      'program_name': 'Program Name',
      'program_description': 'Description',
      'stamps_required': 'Stamps Required',
      'reward_description': 'Reward Description',
      'program_color': 'Program Color',
      'program_icon': 'Program Icon',
      'program_status': 'Status',
      'active': 'Active',
      'paused': 'Paused',
      'save_program': 'Save Program',
      'delete_program': 'Delete Program',
      'program_preview': 'Preview',
      'program_limit_reached': 'Program limit reached',
      'upgrade_to_create': 'Upgrade to create more',
      'no_programs_yet': 'No programs yet',
      'create_first_program':
          'Create your first loyalty program to start rewarding customers.',

      // Customers
      'search_customers': 'Search customers...',
      'customer_phone': 'Customer Phone',
      'customer_name': 'Name (optional)',
      'customer_notes': 'Notes (optional)',
      'add_customer': 'Add Customer',
      'customer_profile': 'Customer Profile',
      'visit_history': 'Visit History',
      'total_visits': 'Total Visits',
      'rewards_earned': 'Rewards Earned',
      'member_since': 'Member Since',
      'last_visit': 'Last Visit',
      'add_tag': 'Add Tag',
      'tags': 'Tags',

      // Stamp Flow
      'stamp_customer': 'Stamp Customer',
      'enter_customer_phone': 'Enter customer phone number',
      'customer_found': 'Customer found',
      'new_customer_created': 'New customer created',
      'current_progress': 'Current Progress',
      'stamps': 'stamps',
      'stamp_added': 'Stamp added',
      'reward_unlocked': 'Reward unlocked!',
      'congratulations': 'Congratulations!',

      // Analytics
      'this_week': 'This Week',
      'this_month': 'This Month',
      'last_30_days': 'Last 30 Days',
      'visits_chart': 'Visits Chart',
      'returning_customers': 'Returning Customers',
      'new_customers': 'New Customers',
      'avg_visits_per_customer': 'Avg visits per customer',

      // Settings
      'business_profile': 'Business Profile',
      'business_name': 'Business Name',
      'business_phone': 'Business Phone',
      'business_address': 'Address',
      'billing_plan': 'Billing & Plan',
      'current_plan': 'Current Plan',
      'free_plan': 'Free',
      'pro_plan': 'Pro',
      'business_plan': 'Business',
      'upgrade_plan': 'Upgrade Plan',
      'wallet_settings': 'Wallet Settings',
      'notifications': 'Notifications',
      'language': 'Language',
      'arabic': 'العربية',
      'english': 'English',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',

      // Plans & Billing
      'sar_month': 'SAR / month',
      'free': 'Free',
      'features': 'Features',
      'program_limit': '1 program',
      'programs_limit': 'programs',
      'unlimited_programs': 'Unlimited programs',
      'passes_limit': '2 passes',
      'unlimited_passes': 'Unlimited passes',
      'branch_limit': '1 branch',
      'branches_limit': 'branches',
      'unlimited_branches': 'Unlimited branches',
      'basic_customization': 'Basic customization',
      'full_customization': 'Full customization',
      'multi_access': 'Multi-access control',
      'select_plan': 'Select Plan',
      'current': 'Current',

      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'confirm': 'Confirm',
      'done': 'Done',
      'next': 'Next',
      'back': 'Back',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'refresh': 'Refresh',
      'loading': 'Loading...',
      'no_data': 'No data',
      'error_occurred': 'An error occurred',
      'try_again': 'Try again',
      'success': 'Success',
      'of': 'of',
      'all': 'All',
      'today': 'Today',
      'yesterday': 'Yesterday',

      // Activity
      'activity_subtitle': 'Track all activities in your store',
      'rewards': 'Rewards',

      // Analytics Extended
      'analytics_subtitle': 'Track your store performance',
      'total_stamps': 'Total Stamps',
      'rewards_given': 'Rewards Given',
      'return_rate': 'Return Rate',
      'stamps_over_time': 'Stamps Over Time',
      'customer_distribution': 'Customer Distribution',
      'occasional': 'Occasional',
      'inactive': 'Inactive',
      'programs_performance': 'Programs Performance',

      // Settings Extended
      'settings_subtitle': 'Manage your account and preferences',
      'account': 'Account',
      'business_profile_desc': 'Business name, logo, and contact info',
      'billing': 'Billing',
      'billing_desc': 'Manage your plan and payment method',
      'preferences': 'Preferences',
      'notifications_desc': 'Email notifications and alerts',
      'integrations': 'Integrations',
      'apple_wallet': 'Apple Wallet',
      'apple_wallet_desc': 'Loyalty cards for Apple devices',
      'google_wallet': 'Google Wallet',
      'google_wallet_desc': 'Loyalty cards for Android devices',
      'connected': 'Connected',
      'coming_soon': 'Coming Soon',
      'support': 'Support',
      'help_center': 'Help Center',
      'help_center_desc': 'FAQs and guides',
      'contact_support': 'Contact Support',
      'contact_support_desc': 'Chat with our support team',
      'danger_zone': 'Danger Zone',
      'sign_out': 'Sign Out',
      'sign_out_desc': 'Log out of your account',
      'sign_out_confirm': 'Are you sure you want to sign out?',
      'select_language': 'Select Language',

      // Billing Screen
      'choose_plan': 'Choose Your Plan',
      'currency': 'SAR',
      'month': 'month',
      'popular': 'Popular',
      'upgrade': 'Upgrade',
      'upgrade_confirm': 'Would you like to upgrade to this plan?',
      'continue': 'Continue',
      'faq': 'Frequently Asked Questions',
      'faq_q1': 'Can I change my plan later?',
      'faq_a1': 'Yes, you can upgrade or downgrade at any time.',
      'faq_q2': 'What payment methods are available?',
      'faq_a2': 'We accept all major credit cards via Tap Payments.',
      'faq_q3': 'Is there a free trial?',
      'faq_a3': 'The free plan is available forever with limited features.',
      'feature_1_program': '1 program',
      'feature_2_passes': '2 passes only',
      'feature_basic_analytics': 'Basic analytics',
      'feature_2_programs': '2 programs',
      'feature_3_programs': '3 programs',
      'feature_500_passes': '500 passes',
      'feature_2500_passes': '2,500 passes',
      'feature_unlimited_passes': 'Unlimited passes',
      'feature_advanced_analytics': 'Advanced analytics',
      'feature_priority_support': 'Priority support',
      'feature_unlimited_programs': 'Unlimited programs',
      'feature_full_analytics': 'Full analytics suite',
      'feature_api_access': 'API access',
      'feature_dedicated_support': 'Dedicated support',
      'feature_1_branch': '1 branch',
      'feature_3_branches': '3 branches',
      'feature_unlimited_branches': 'Unlimited branches',
      'feature_2_team_members': '2 team members',
      'feature_10_team_members': '10 team members',
      'feature_referral_program': 'Referral program',
      'feature_automations': 'Automations & reminders',
      'feature_webhooks': 'Webhooks & API',
      'feature_email_support': 'Email support',

      // Business Profile
      'business_info': 'Business Info',
      'business_name_en': 'Business Name (English)',
      'business_name_ar': 'Business Name (Arabic)',
      'contact_info': 'Contact Info',
      'phone': 'Phone',
      'email': 'Email',
      'address': 'Address',
      'business_id': 'Business ID',
      'your_business_id': 'Your Business ID',
      'copied_to_clipboard': 'Copied to clipboard',
      'business_logo': 'Business Logo',
      'logo_requirements': 'PNG or JPG, 512×512 pixels',
      'upload_logo': 'Upload Logo',
      'save_changes': 'Save Changes',
      'profile_saved': 'Profile saved',

      // Stamp Flow Extended
      'find_customer': 'Find Customer',
      'enter_phone_to_add_stamp': 'Enter phone number to add stamp',
      'phone_placeholder': 'Phone number',
      'search_another': 'Search another customer',
      'customer_can_redeem': 'Customer can redeem their reward',
      'add_another_stamp': 'Add Another Stamp',

      // Errors
      'error_invalid_phone': 'Invalid phone number',
      'error_otp_invalid': 'Invalid verification code',
      'error_otp_expired': 'Code expired',
      'error_network': 'Network error',
      'error_server': 'Server error',
      'error_unknown': 'Unknown error',

      // Plan names
      'starter_plan': 'Starter',
      'growth_plan': 'Growth',
      'advanced_plan': 'Advanced',

      // Upgrade prompts
      'upgrade_to_unlock': 'Upgrade to unlock this feature',
      'upgrade_now': 'Upgrade Now',
      'start_free_trial': 'Start 14-Day Free Trial',
      'maybe_later': 'Maybe Later',
      'available_in': 'Available in',
      'per_month_billed_annually': 'per month (billed annually)',

      // Feature names and descriptions
      'feature_unlimited_customers': 'Unlimited Customers',
      'feature_unlimited_customers_desc': 'Add unlimited customers to your loyalty programs',
      'feature_card_design': 'Card Design',
      'feature_card_design_desc': 'Design professional loyalty cards for your customers',
      'feature_card_customization': 'Card Customization',
      'feature_card_customization_desc': 'Customize colors, icons, and design of your loyalty cards',
      'feature_multi_language': 'Multi-language Support',
      'feature_multi_language_desc': 'Support your customers in multiple languages',
      'feature_basic_analytics_desc': 'Track your loyalty program performance',
      'feature_review_collection': 'Review & Feedback',
      'feature_review_collection_desc': 'Collect customer reviews and feedback to improve your service',
      'feature_location_push': 'Location-based Push',
      'feature_location_push_desc': 'Send notifications when customers enter a specific area',
      'feature_custom_fields': 'Custom Form Fields',
      'feature_custom_fields_desc': 'Add custom information to customer profiles',
      'feature_tiered_membership': 'Tiered Membership',
      'feature_tiered_membership_desc': 'Create VIP tiers like Bronze, Silver, Gold',
      'feature_referral_program_desc': 'Reward customers for referring their friends',
      'feature_push_marketing': 'Push Notification Marketing',
      'feature_push_marketing_desc': 'Send promotional notifications to your customers',
      'feature_automated_push': 'Automated Notifications',
      'feature_automated_push_desc': 'Send automatic notifications for birthdays and inactive customers',
      'feature_email_marketing': 'E-mail Marketing',
      'feature_email_marketing_desc': 'Send email campaigns to your customers',
      'feature_sms_marketing': 'SMS Marketing',
      'feature_sms_marketing_desc': 'Send SMS marketing messages to your customers',
      'feature_integrations': '3rd Party Integrations',
      'feature_integrations_desc': 'Connect with external systems like POS and CRM',
      'feature_webhook_api': 'Webhook & API Access',
      'feature_webhook_api_desc': 'Use API to connect your systems with Loya',
      'feature_priority_support_desc': 'Get fast and dedicated technical support',

      // Team Members
      'team_members': 'Team Members',
      'team_members_desc': 'Manage staff and permissions',
      'add_team_member': 'Add Member',
      'member_name': 'Member Name',
      'member_role': 'Role',
      'role_owner': 'Owner',
      'role_manager': 'Manager',
      'role_cashier': 'Cashier',
      'invite_member': 'Invite Member',
      'pending_invites': 'Pending Invites',

      // Referral Program
      'referral_program': 'Referral Program',
      'referral_program_desc': 'Reward customers for inviting friends',
      'referral_reward': 'Referral Reward',
      'referrer_bonus': 'Referrer Bonus',
      'referee_bonus': 'Referee Bonus',
      'referral_link': 'Referral Link',
      'total_referrals': 'Total Referrals',

      // Automation
      'automation': 'Automation',
      'automation_desc': 'Automated customer notifications',
      'automation_rules': 'Automation Rules',
      'add_rule': 'Add Rule',
      'edit_rule': 'Edit Rule',
      'delete_rule': 'Delete Rule',
      'delete_rule_confirm': 'Are you sure you want to delete this rule?',
      'rule_name': 'Rule Name',
      'rule_name_hint': 'e.g., Birthday Greeting',
      'message': 'Message',
      'message_hint': 'Enter message text...',
      'no_automation_rules': 'No automation rules',
      'trigger': 'Trigger',
      'action': 'Action',
      'trigger_birthday': 'Customer Birthday',
      'trigger_inactive': 'Inactive Customer',
      'trigger_reward_expiring': 'Reward Expiring',
      'trigger_first_visit': 'First Visit',
      'action_send_push': 'Send Push Notification',
      'action_send_sms': 'Send SMS',
      'action_send_email': 'Send Email',
      'action_add_stamps': 'Add Stamps',
      'inactive_days': 'Days of Inactivity',

      // Branches
      'branches': 'Branches',
      'branches_desc': 'Manage your business branches',
      'add_branch': 'Add Branch',
      'branch_name': 'Branch Name',
      'branch_address': 'Branch Address',
      'branch_manager': 'Branch Manager',
      'main_branch': 'Main Branch',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Helper getters for common strings
  String get appName => get('app_name');
  String get appTagline => get('app_tagline');

  // Add more getters as needed for type safety
  bool get isRtl => locale.languageCode == 'ar';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access
extension LocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isRtl => l10n.isRtl;
}
