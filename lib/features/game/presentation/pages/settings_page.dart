/**
 * SETTINGS_PAGE.DART
 * ==================
 * 
 * TỔNG QUAN:
 * Màn hình Cài đặt - nơi người chơi có thể tùy chỉnh các thiết lập game và giao diện.
 * Sử dụng SettingsService để lưu/load các cài đặt vào SharedPreferences.
 * 
 * TÍNH NĂNG CHÍNH:
 * - Cài đặt Game:
 *   + Âm thanh (soundEffects): Bật/tắt hiệu ứng âm thanh
 *   + Hiển thị đồng hồ (timerDisplay): Hiển thị/ẩn đồng hồ đếm giờ
 *   + Giới hạn sai (mistakesLimit): Giới hạn số lần sai tối đa (3 lần)
 *   + Đánh dấu trùng (highlightDuplicates): Highlight các số trùng nhau
 * 
 * - Giao diện:
 *   + Theme: Chọn giữa Sáng (light) và Tối (dark)
 * 
 * - Tài khoản & Hỗ trợ:
 *   + Khôi phục mua hàng (chưa implement)
 *   + Liên hệ hỗ trợ (chưa implement)
 *   + Chính sách bảo mật (chưa implement)
 *   + Giới thiệu (chưa implement)
 * 
 * LUỒNG HOẠT ĐỘNG:
 * 1. Load settings từ SettingsService thông qua Consumer
 * 2. Hiển thị các toggle switches và buttons với giá trị hiện tại
 * 3. Khi người dùng thay đổi setting, gọi method tương ứng trong SettingsService
 * 4. SettingsService lưu vào SharedPreferences và notify listeners
 * 5. UI tự động cập nhật nhờ Consumer
 * 
 * CẤU TRÚC UI:
 * - AppBar: Tiêu đề + nút back
 * - Section 1: CÀI ĐẶT GAME
 *   + 4 toggle settings trong một group
 * - Section 2: GIAO DIỆN
 *   + 2 theme buttons (Sáng/Tối)
 * - Section 3: TÀI KHOẢN & HỖ TRỢ
 *   + 4 action buttons
 * - Footer: Version info
 * 
 * NOTES:
 * - Đã xóa các setting: System theme, Font size, Language
 * - Sử dụng Consumer để tự động cập nhật UI khi settings thay đổi
 * - Tất cả settings được lưu vào SharedPreferences
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/settings_service.dart';

/// Widget chính của màn hình Cài đặt
/// Sử dụng Consumer để lắng nghe thay đổi từ SettingsService
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer lắng nghe SettingsService và rebuild khi có thay đổi
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return _SettingsPageContent(settings: settings);
      },
    );
  }
}

/// Widget nội dung của màn hình Cài đặt
/// Nhận SettingsService từ parent để truy cập và cập nhật settings
class _SettingsPageContent extends StatelessWidget {
  final SettingsService settings;

  const _SettingsPageContent({required this.settings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Settings
            _buildSectionHeader('CÀI ĐẶT GAME', isDark),
            const SizedBox(height: 12),
            _buildSettingsGroup(isDark, [
              _buildToggleSetting(
                icon: Icons.volume_up,
                title: 'Âm thanh',
                value: settings.soundEffects,
                onChanged: (value) async {
                  await settings.setSoundEffects(value);
                },
                isDark: isDark,
              ),
              _buildToggleSetting(
                icon: Icons.timer,
                title: 'Hiển thị đồng hồ',
                value: settings.timerDisplay,
                onChanged: (value) async {
                  await settings.setTimerDisplay(value);
                },
                isDark: isDark,
              ),
              _buildToggleSetting(
                icon: Icons.heart_broken,
                title: 'Giới hạn sai',
                value: settings.mistakesLimit,
                onChanged: (value) async {
                  await settings.setMistakesLimit(value);
                },
                isDark: isDark,
              ),
              _buildToggleSetting(
                icon: Icons.content_copy,
                title: 'Đánh dấu trùng',
                value: settings.highlightDuplicates,
                onChanged: (value) async {
                  await settings.setHighlightDuplicates(value);
                },
                isDark: isDark,
                isLast: true,
              ),
            ]),
            
            const SizedBox(height: 32),
            
            // Visual Settings
            _buildSectionHeader('GIAO DIỆN', isDark),
            const SizedBox(height: 12),
            
            // Theme Selection
            Row(
              children: [
                Expanded(
                  child: _buildThemeButton(
                    icon: Icons.light_mode,
                    label: 'Sáng',
                    value: 'light',
                    currentTheme: settings.theme,
                    onTap: () => settings.setTheme('light'),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeButton(
                    icon: Icons.dark_mode,
                    label: 'Tối',
                    value: 'dark',
                    currentTheme: settings.theme,
                    onTap: () => settings.setTheme('dark'),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Account & Support
            _buildSectionHeader('TÀI KHOẢN & HỖ TRỢ', isDark),
            const SizedBox(height: 12),
            
            _buildActionButton(
              icon: Icons.restore,
              title: 'Khôi phục mua hàng',
              onTap: () {},
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              icon: Icons.mail,
              title: 'Liên hệ hỗ trợ',
              onTap: () {},
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              icon: Icons.verified_user,
              title: 'Chính sách bảo mật',
              onTap: () {},
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              icon: Icons.info,
              title: 'Giới thiệu',
              onTap: () {},
              isDark: isDark,
            ),
            
            const SizedBox(height: 48),
            
            // Version
            Center(
              child: Column(
                children: [
                  Text(
                    'SUDOKU PUZZLE ENGINE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: isDark ? Colors.grey[400] : const Color(0xFF596064),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleSetting({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF005BC1),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: (newValue) {
                print('Switch changed: $title = $newValue');
                onChanged(newValue);
              },
              activeColor: const Color(0xFF005BC1),
              activeTrackColor: const Color(0xFF005BC1).withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton({
    required IconData icon,
    required String label,
    required String value,
    required String currentTheme,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final isSelected = currentTheme == value;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF005BC1)
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : const Color(0xFF596064)),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[400] : const Color(0xFF596064)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeSetting(SettingsService settings, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.format_size,
              color: Color(0xFF49636F),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Cỡ chữ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildFontSizeButton('A', 'small', 12, settings, isDark),
                _buildFontSizeButton('A', 'medium', 14, settings, isDark),
                _buildFontSizeButton('A', 'large', 18, settings, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeButton(String label, String value, double size, SettingsService settings, bool isDark) {
    final isSelected = settings.fontSize == value;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => settings.setFontSize(value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF334155) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSetting(SettingsService settings, bool isDark) {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _showLanguageDialog(context, settings);
              },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Color(0xFF49636F),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Ngôn ngữ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  settings.language,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF005BC1),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.expand_more,
                  size: 20,
                  color: Color(0xFF005BC1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDark ? Colors.grey[400] : const Color(0xFF596064),
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[600] : const Color(0xFFD4DBDF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsService settings) {
    final languages = ['Tiếng Việt', 'English', '中文', '日本語', '한국어'];
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: settings.language,
              onChanged: (value) async {
                if (value != null) {
                  await settings.setLanguage(value);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
