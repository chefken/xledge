import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:xledge/providers/theme_provider.dart';
import 'package:xledge/services/user_prefs_service.dart';
import 'package:xledge/utils/void_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
        text: UserPrefsService.username);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    await UserPrefsService.setUsername(_nameCtrl.text);
    if (mounted) {
      setState(() {});
      FocusScope.of(context).unfocus();
      _showSnack('Name updated');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.bricolageGrotesque(
              color: Colors.white,
              fontSize: 13,
            )),
        backgroundColor: VoidColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? VoidColors.darkBg     : VoidColors.background;
    final card   = isDark ? VoidColors.darkCard    : VoidColors.surface;
    final border = isDark ? VoidColors.darkBorder  : VoidColors.outline;
    final txPri  = isDark ? VoidColors.darkTextPrimary   : VoidColors.textPrimary;
    final txSec  = isDark ? VoidColors.darkTextSecondary : VoidColors.textSecondary;
    final txHint = isDark ? VoidColors.darkTextHint      : VoidColors.textHint;
    final fill   = isDark ? VoidColors.darkCard    : VoidColors.outlineVariant;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: card,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                isDark ? 0.3 : 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: txSec, size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Settings',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: txPri,
                        letterSpacing: -0.6,
                      )),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _SectionLabel(
                  label: 'PROFILE', color: txHint),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: _SettingsCard(
                color: card,
                border: border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Display Name',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: txHint,
                          letterSpacing: 0.2,
                        )),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameCtrl,
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: txPri,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              hintStyle:
                                  GoogleFonts.bricolageGrotesque(
                                fontSize: 15,
                                color: txHint,
                              ),
                              filled: true,
                              fillColor: fill,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: VoidColors.primary,
                                    width: 1.5),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _saveName,
                          child: Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFA78BFA),
                                  Color(0xFF5B3FD4),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: VoidColors.primary
                                      .withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: _SectionLabel(label: 'APPEARANCE', color: txHint),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return _SettingsCard(
                    color: card,
                    border: border,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Theme',
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: txHint,
                              letterSpacing: 0.2,
                            )),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ThemePill(
                                label: 'Light',
                                icon:  Icons.light_mode_outlined,
                                active: themeProvider.themeIndex == 0,
                                isDark: isDark,
                                onTap: () =>
                                    themeProvider.setTheme(0),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ThemePill(
                                label: 'Dark',
                                icon:  Icons.dark_mode_outlined,
                                active: themeProvider.themeIndex == 1,
                                isDark: isDark,
                                onTap: () =>
                                    themeProvider.setTheme(1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ThemePill(
                                label: 'System',
                                icon:  Icons.phone_android_outlined,
                                active: themeProvider.themeIndex == 2,
                                isDark: isDark,
                                onTap: () =>
                                    themeProvider.setTheme(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: _SectionLabel(label: 'ABOUT', color: txHint),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: _SettingsCard(
                color: card,
                border: border,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('xledge',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: txPri,
                        )),
                    Text('v1.0.0',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 13,
                          color: txHint,
                        )),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.bricolageGrotesque(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 1.6,
        ));
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color border;

  const _SettingsCard({
    required this.child,
    required this.color,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ThemePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemePill({
    required this.label,
    required this.icon,
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: active
              ? VoidColors.primary
              : (isDark
                  ? VoidColors.darkBg
                  : VoidColors.outlineVariant),
          borderRadius: BorderRadius.circular(14),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: VoidColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 18,
                color: active
                    ? Colors.white
                    : (isDark
                        ? VoidColors.darkTextSecondary
                        : VoidColors.textSecondary)),
            const SizedBox(height: 5),
            Text(label,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: active
                      ? Colors.white
                      : (isDark
                          ? VoidColors.darkTextSecondary
                          : VoidColors.textSecondary),
                )),
          ],
        ),
      ),
    );
  }
}