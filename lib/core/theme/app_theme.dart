import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Central theme definition for the AI Video Editor.
///
/// Provides [ThemeData] for both dark (primary) and light modes,
/// plus helper extensions for quick access from context.
abstract final class AppTheme {
  AppTheme._();

  // =========================================================================
  // DARK THEME (Primary)
  // =========================================================================

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _darkColorScheme,
        textTheme: AppTypography.darkTextTheme,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.backgroundPrimary,

        // ----- AppBar -----
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundPrimary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: null, // inherit from textTheme
        ),

        // ----- NavigationBar / BottomNav -----
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.backgroundSecondary,
          indicatorColor: AppColors.accent.withOpacity(0.15),
          elevation: 0,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTypography.labelSmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.accent,
                size: AppSpacing.iconMd,
              );
            }
            return const IconThemeData(
              color: AppColors.textTertiary,
              size: AppSpacing.iconMd,
            );
          }),
        ),

        // ----- Bottom Navigation Bar (legacy compat) -----
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.backgroundSecondary,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // ----- Card -----
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        // ----- ListTile -----
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          selectedTileColor: AppColors.surfaceActive,
          iconColor: AppColors.textSecondary,
          textColor: AppColors.textPrimary,
        ),

        // ----- ElevatedButton -----
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.gray700,
            disabledForegroundColor: AppColors.textDisabled,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingH,
              vertical: AppSpacing.buttonPaddingV,
            ),
            minimumSize: const Size(0, AppSpacing.heightButton),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            textStyle: AppTypography.labelLarge.copyWith(color: AppColors.white),
          ),
        ),

        // ----- TextButton -----
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            disabledForegroundColor: AppColors.textDisabled,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            minimumSize: const Size(0, AppSpacing.heightButton),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // ----- OutlinedButton -----
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            disabledForegroundColor: AppColors.textDisabled,
            side: const BorderSide(color: AppColors.borderStrong, width: 1),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingH,
              vertical: AppSpacing.buttonPaddingV,
            ),
            minimumSize: const Size(0, AppSpacing.heightButton),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // ----- IconButton -----
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.all(AppSpacing.sm),
            minimumSize: const Size(
              AppSpacing.touchTargetMin,
              AppSpacing.touchTargetMin,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),

        // ----- InputDecoration (TextField / SearchBar) -----
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide:
                const BorderSide(color: AppColors.error, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          prefixIconColor: AppColors.textTertiary,
          suffixIconColor: AppColors.textTertiary,
        ),

        // ----- Chip -----
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.accent.withOpacity(0.15),
          disabledColor: AppColors.surface,
          labelStyle: AppTypography.labelMedium,
          secondaryLabelStyle: AppTypography.labelMedium,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            side: const BorderSide(color: AppColors.border),
          ),
          side: const BorderSide(color: AppColors.border),
          checkmarkColor: AppColors.accent,
        ),

        // ----- Dialog -----
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.backgroundTertiary,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            side: const BorderSide(color: AppColors.border),
          ),
          titleTextStyle: AppTypography.titleLarge,
          contentTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        // ----- BottomSheet -----
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.backgroundTertiary,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          showDragHandle: true,
          dragHandleColor: AppColors.textTertiary,
          modalBarrierColor: AppColors.surfaceOverlay,
        ),

        // ----- SnackBar -----
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.backgroundQuaternary,
          contentTextStyle:
              AppTypography.bodyMedium.copyWith(color: AppColors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 8,
        ),

        // ----- Divider -----
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 0,
          indent: 0,
          endIndent: 0,
        ),

        // ----- Tooltip -----
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: AppColors.gray800,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: AppTypography.labelSmall.copyWith(color: AppColors.white),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        ),

        // ----- ProgressIndicator -----
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.accent,
          linearTrackColor: AppColors.progressTrack,
          circularTrackColor: AppColors.progressTrack,
        ),

        // ----- TabBar -----
        tabBarTheme: TabBarTheme(
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: AppTypography.labelLarge,
          unselectedLabelStyle: AppTypography.labelLarge,
          indicatorColor: AppColors.accent,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.divider,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accent.withOpacity(0.08);
            }
            return Colors.transparent;
          }),
        ),

        // ----- Switch -----
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.white;
            }
            return AppColors.gray400;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accent;
            }
            return AppColors.gray700;
          }),
        ),

        // ----- Slider -----
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.accent,
          inactiveTrackColor: AppColors.progressTrack,
          thumbColor: AppColors.white,
          overlayColor: AppColors.accent.withOpacity(0.12),
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        ),

        // ----- PopupMenu -----
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.backgroundTertiary,
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: const BorderSide(color: AppColors.border),
          ),
          textStyle: AppTypography.bodyMedium,
        ),

        // ----- DropdownMenu -----
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: const InputDecorationTheme(),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(
              AppColors.backgroundTertiary,
            ),
            elevation: const WidgetStatePropertyAll(16),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),

        // ----- Scrollbar -----
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(AppColors.gray600),
          trackColor: WidgetStateProperty.all(Colors.transparent),
          trackBorderColor: WidgetStateProperty.all(Colors.transparent),
          radius: const Radius.circular(4),
          thickness: WidgetStateProperty.all(6),
        ),

        // ----- Drawer -----
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.backgroundSecondary,
          elevation: 16,
          scrimColor: AppColors.surfaceOverlay,
        ),

        // ----- Checkbox -----
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accent;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(AppColors.white),
          side: const BorderSide(color: AppColors.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          ),
        ),

        // ----- Radio -----
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accent;
            }
            return AppColors.textTertiary;
          }),
        ),

        // ----- FloatingActionButton -----
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          elevation: 4,
          focusElevation: 6,
          hoverElevation: 8,
          shape: CircleBorder(),
        ),

        // ----- DatePicker -----
        datePickerTheme: DatePickerThemeData(
          backgroundColor: AppColors.backgroundTertiary,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            side: const BorderSide(color: AppColors.border),
          ),
          headerBackgroundColor: AppColors.backgroundQuaternary,
          headerForegroundColor: AppColors.textPrimary,
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accent;
            }
            return Colors.transparent;
          }),
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.white;
            }
            return AppColors.textPrimary;
          }),
          todayBackgroundColor: WidgetStateProperty.all(
            AppColors.accent.withOpacity(0.15),
          ),
          todayForegroundColor: WidgetStateProperty.all(AppColors.accent),
        ),

        // ----- TimePicker -----
        timePickerTheme: TimePickerThemeData(
          backgroundColor: AppColors.backgroundTertiary,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            side: const BorderSide(color: AppColors.border),
          ),
          dialHandColor: AppColors.accent,
          dialBackgroundColor: AppColors.surface,
          entryModeIconColor: AppColors.textSecondary,
        ),
      );

  // =========================================================================
  // LIGHT THEME (Optional)
  // =========================================================================

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: _lightColorScheme,
        textTheme: AppTypography.lightTextTheme,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.gray50,

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.gray50,
          foregroundColor: AppColors.gray950,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.blue500.withOpacity(0.12),
          elevation: 0,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTypography.labelSmall.copyWith(
                color: AppColors.blue600,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTypography.labelSmall
                .copyWith(color: AppColors.gray500);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.blue600,
                size: AppSpacing.iconMd,
              );
            }
            return const IconThemeData(
              color: AppColors.gray500,
              size: AppSpacing.iconMd,
            );
          }),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.blue600,
          unselectedItemColor: AppColors.gray500,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        cardTheme: CardTheme(
          color: AppColors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: BorderSide(color: AppColors.gray200),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          hintStyle: AppTypography.bodyMedium
              .copyWith(color: AppColors.gray400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide(color: AppColors.gray300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide(color: AppColors.gray300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(
                color: AppColors.blue500, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.red500),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(
                color: AppColors.red500, width: 1.5),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue600,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.gray200,
            disabledForegroundColor: AppColors.gray400,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingH,
              vertical: AppSpacing.buttonPaddingV,
            ),
            minimumSize: const Size(0, AppSpacing.heightButton),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            textStyle:
                AppTypography.labelLarge.copyWith(color: AppColors.white),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.blue600,
            disabledForegroundColor: AppColors.gray400,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            minimumSize: const Size(0, AppSpacing.heightButton),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            textStyle: AppTypography.labelLarge
                .copyWith(color: AppColors.blue600),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gray800,
            disabledForegroundColor: AppColors.gray400,
            side: BorderSide(color: AppColors.gray300, width: 1),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingH,
              vertical: AppSpacing.buttonPaddingV,
            ),
            minimumSize: const Size(0, AppSpacing.heightButton),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            textStyle: AppTypography.labelLarge
                .copyWith(color: AppColors.gray800),
          ),
        ),

        dividerTheme: DividerThemeData(
          color: AppColors.gray200,
          thickness: 1,
          space: 0,
        ),

        dialogTheme: DialogTheme(
          backgroundColor: AppColors.white,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          titleTextStyle: AppTypography.titleLarge
              .copyWith(color: AppColors.gray950),
          contentTextStyle: AppTypography.bodyMedium
              .copyWith(color: AppColors.gray600),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.gray900,
          contentTextStyle: AppTypography.bodyMedium
              .copyWith(color: AppColors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        chipTheme: ChipThemeData(
          backgroundColor: AppColors.gray100,
          selectedColor: AppColors.blue100,
          labelStyle: AppTypography.labelMedium
              .copyWith(color: AppColors.gray800),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            side: BorderSide(color: AppColors.gray200),
          ),
          checkmarkColor: AppColors.blue600,
        ),

        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.blue600,
          linearTrackColor: AppColors.gray200,
          circularTrackColor: AppColors.gray200,
        ),

        tabBarTheme: TabBarTheme(
          labelColor: AppColors.blue600,
          unselectedLabelColor: AppColors.gray500,
          labelStyle: AppTypography.labelLarge,
          unselectedLabelStyle: AppTypography.labelLarge,
          indicatorColor: AppColors.blue600,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.gray200,
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.white;
            }
            return AppColors.gray400;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.blue600;
            }
            return AppColors.gray300;
          }),
        ),

        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.blue600,
          inactiveTrackColor: AppColors.gray200,
          thumbColor: AppColors.white,
          overlayColor: AppColors.blue600.withOpacity(0.12),
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.blue600,
          foregroundColor: AppColors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),

        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.white,
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: BorderSide(color: AppColors.gray200),
          ),
          textStyle: AppTypography.bodyMedium
              .copyWith(color: AppColors.gray800),
        ),
      );

  // =========================================================================
  // COLOR SCHEMES
  // =========================================================================

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    surface: AppColors.backgroundPrimary,
    surfaceContainer: AppColors.backgroundSecondary,
    surfaceContainerHigh: AppColors.backgroundTertiary,
    surfaceContainerHighest: AppColors.backgroundQuaternary,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    primary: AppColors.accent,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.blue800,
    onPrimaryContainer: AppColors.blue100,
    secondary: AppColors.accentSecondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.purple800,
    onSecondaryContainer: AppColors.purple100,
    tertiary: AppColors.green500,
    onTertiary: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    errorContainer: AppColors.red900,
    onErrorContainer: AppColors.red100,
    outline: AppColors.border,
    outlineVariant: AppColors.borderSubtle,
    shadow: Colors.black,
    inverseSurface: AppColors.gray100,
    onInverseSurface: AppColors.gray950,
    inversePrimary: AppColors.blue400,
    surfaceTint: AppColors.accent,
  );

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    surface: AppColors.gray50,
    surfaceContainer: AppColors.white,
    surfaceContainerHigh: AppColors.gray100,
    surfaceContainerHighest: AppColors.gray200,
    onSurface: AppColors.gray950,
    onSurfaceVariant: AppColors.gray600,
    primary: AppColors.blue600,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.blue100,
    onPrimaryContainer: AppColors.blue900,
    secondary: AppColors.purple600,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.purple100,
    onSecondaryContainer: AppColors.purple900,
    tertiary: AppColors.green600,
    onTertiary: AppColors.white,
    error: AppColors.red600,
    onError: AppColors.white,
    errorContainer: AppColors.red100,
    onErrorContainer: AppColors.red900,
    outline: AppColors.gray300,
    outlineVariant: AppColors.gray200,
    shadow: Colors.black,
    inverseSurface: AppColors.gray800,
    onInverseSurface: AppColors.gray50,
    inversePrimary: AppColors.blue200,
    surfaceTint: AppColors.blue600,
  );
}
