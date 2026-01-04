/// Consistent spacing system
/// Based on 4px grid for precision
class AppSpacing {
  AppSpacing._();

  // Base unit
  static const double unit = 4.0;

  // Standard spacing
  static const double xxs = 2.0; // 0.5 unit
  static const double xs = 4.0; // 1 unit
  static const double sm = 8.0; // 2 units
  static const double md = 12.0; // 3 units
  static const double lg = 16.0; // 4 units
  static const double xl = 20.0; // 5 units
  static const double xxl = 24.0; // 6 units
  static const double xxxl = 32.0; // 8 units

  // Section spacing
  static const double sectionSmall = 24.0;
  static const double sectionMedium = 40.0;
  static const double sectionLarge = 64.0;

  // Page margins
  static const double pagePadding = 24.0;
  static const double pagePaddingMobile = 16.0;

  // Card/Component internal padding
  static const double cardPadding = 20.0;
  static const double cardPaddingSmall = 16.0;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  // Sidebar
  static const double sidebarWidth = 260.0;
  static const double sidebarCollapsedWidth = 72.0;

  // Top bar
  static const double topBarHeight = 64.0;

  // Max content width
  static const double maxContentWidth = 1200.0;
  static const double maxFormWidth = 560.0;

  // Breakpoints
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;
  static const double breakpointLarge = 1440.0;
}
