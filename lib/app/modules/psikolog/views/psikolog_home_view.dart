import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/theme_toggle_action.dart';
import '../controllers/psikolog_controller.dart';
import 'psikolog_student_detail_view.dart';

class PsikologHomeView extends GetView<PsikologController> {
  const PsikologHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = _PsikologPalette.of(context);

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: _buildHeader(context, palette),
            ),
            Obx(() => _buildTabBar(palette)),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final tab = controller.selectedTab.value;
                Widget content;
                switch (tab) {
                  case 1:
                    content = _buildScheduleContent(context, palette);
                    break;
                  case 2:
                    content = _buildMessagesContent(context, palette);
                    break;
                  default:
                    content = _buildDashboardContent(context, palette);
                    break;
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: content,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, _PsikologPalette palette) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: palette.headerGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Psikolog',
                style: TextStyle(
                  color: palette.onPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Monitor progres mahasiswa dan kelola sesi konseling.',
                style: TextStyle(
                  color: palette.onPrimary.withValues(alpha: 0.82),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Halo, ${controller.username}',
                style: TextStyle(
                  color: palette.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeToggleAction(iconColor: palette.onPrimary),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Logout',
                onPressed: () => controller.logout(context),
                icon: const Icon(Icons.logout_rounded),
                color: palette.onPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(_PsikologPalette palette) {
    const labels = ['Dashboard', 'Jadwal', 'Pesan'];
    const icons = [
      Icons.bar_chart_rounded,
      Icons.calendar_month_rounded,
      Icons.chat_bubble_outline_rounded,
    ];
    final selected = controller.selectedTab.value;
    final unread = controller.unreadMessages;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = selected == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isActive ? palette.menuActiveBackground : palette.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isActive ? palette.menuActiveBorder : palette.border,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: palette.shadow,
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : const [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          icons[index],
                          color: isActive
                              ? palette.menuActiveIcon
                              : palette.menuInactiveIcon,
                        ),
                        if (index == 2 && unread > 0)
                          Positioned(
                            top: -4,
                            right: -8,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4D67),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? palette.menuActiveText
                            : palette.menuInactiveText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    _PsikologPalette palette,
  ) {
    final clients = controller.filteredClientSummaries;
    return ListView(
      key: const ValueKey('dashboard'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildStatsRow(palette),
        const SizedBox(height: 20),
        _buildFilterRow(palette),
        const SizedBox(height: 20),
        if (clients.isEmpty)
          _buildEmptyState(
            palette,
            icon: Icons.search_off_rounded,
            title: 'Tidak ada data klien',
            subtitle: 'Ubah filter untuk melihat daftar mahasiswa lainnya.',
          )
        else
          ...clients.map(
            (client) => _buildClientCard(context, palette, client),
          ),
      ],
    );
  }

  Widget _buildStatsRow(_PsikologPalette palette) {
    return Row(
      children: [
        _buildStatCard(
          palette,
          icon: Icons.group_rounded,
          label: 'Klien Aktif',
          value: controller.activeClientCount.toString(),
          accent: palette.primary,
        ),
        _buildStatCard(
          palette,
          icon: Icons.emoji_emotions_outlined,
          label: 'Mood Rata-rata',
          value: controller.averageMood.toStringAsFixed(1),
          accent: const Color(0xFF3CC896),
        ),
        _buildStatCard(
          palette,
          icon: Icons.warning_amber_rounded,
          label: 'Risiko Tinggi',
          value: controller.highRiskCount.toString(),
          accent: const Color(0xFFFF6B6B),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    _PsikologPalette palette, {
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 16,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: palette.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(_PsikologPalette palette) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            palette,
            label: 'Program Studi',
            value: controller.selectedProgram.value,
            options: controller.programOptions,
            onChanged: controller.updateProgram,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown(
            palette,
            label: 'Status Risiko',
            value: controller.selectedRisk.value,
            options: controller.riskOptions,
            onChanged: controller.updateRisk,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    _PsikologPalette palette, {
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: palette.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: palette.card,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: palette.menuInactiveIcon,
              ),
              items: options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (selected) {
                if (selected != null) onChanged(selected);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard(
    BuildContext context,
    _PsikologPalette palette,
    ClientSummary client,
  ) {
    final riskColor = _riskColor(client.riskLevel);
    final riskSurface = _riskBackground(client.riskLevel, palette.isDark);
    final riskText = _riskTextColor(client.riskLevel, palette.isDark);
    final progress = (client.moodScore / 5).clamp(0.0, 1.0);
    final user = controller.userByUsername(client.username);

    return GestureDetector(
      onTap: user == null
          ? null
          : () {
              controller.viewStudentProfile(user);
              Get.to(
                () => const PsikologStudentDetailView(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 280),
              );
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 20,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(client.name),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client.program,
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: riskSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    client.riskLevel.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: riskText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: palette.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(riskColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: palette.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    client.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.access_time, size: 16, color: palette.textSecondary),
                const SizedBox(width: 4),
                Text(
                  client.lastActive,
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: riskSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_emotions, size: 14, color: riskText),
                      const SizedBox(width: 4),
                      Text(
                        client.moodScore.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: riskText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleContent(BuildContext context, _PsikologPalette palette) {
    final schedules = controller.schedules;
    return ListView(
      key: const ValueKey('schedule'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildScheduleSummary(palette),
        const SizedBox(height: 20),
        if (schedules.isEmpty)
          _buildEmptyState(
            palette,
            icon: Icons.event_busy,
            title: 'Belum ada jadwal',
            subtitle: 'Jadwal sesi Anda akan muncul di sini.',
          )
        else
          ...schedules.map(
            (schedule) => _buildScheduleCard(context, palette, schedule),
          ),
      ],
    );
  }

  Widget _buildScheduleSummary(_PsikologPalette palette) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 18,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ScheduleMetric(
              title: 'Sesi Hari Ini',
              value: controller.sessionsToday.toString(),
              palette: palette,
              icon: Icons.schedule_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ScheduleMetric(
              title: 'Sesi Selesai',
              value: controller.sessionsCompleted.toString(),
              palette: palette,
              icon: Icons.check_circle_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    _PsikologPalette palette,
    ConsultationSchedule schedule,
  ) {
    final riskSurface = _riskBackground(schedule.riskLevel, palette.isDark);
    final riskText = _riskTextColor(schedule.riskLevel, palette.isDark);
    final user = controller.userByUsername(schedule.username);

    return GestureDetector(
      onTap: user == null
          ? null
          : () {
              controller.viewStudentProfile(user);
              Get.to(
                () => const PsikologStudentDetailView(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 280),
              );
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(schedule.name),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.topic,
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    schedule.mode.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.access_time_filled,
                  size: 16,
                  color: palette.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  schedule.time,
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
                const SizedBox(width: 12),
                Icon(Icons.numbers, size: 16, color: palette.textSecondary),
                const SizedBox(width: 6),
                Text(
                  schedule.sessionId,
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
                const Spacer(),
                Icon(
                  schedule.isCompleted
                      ? Icons.check_circle
                      : Icons.pending_actions_rounded,
                  color: schedule.isCompleted
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFFA726),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Durasi ${schedule.durationMinutes} menit',
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: riskSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_emotions, size: 14, color: riskText),
                      const SizedBox(width: 4),
                      Text(
                        schedule.moodScore.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: riskText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesContent(BuildContext context, _PsikologPalette palette) {
    final messages = controller.filteredMessages;
    return ListView(
      key: const ValueKey('messages'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildMessageSearch(palette),
        const SizedBox(height: 16),
        if (messages.isEmpty)
          _buildEmptyState(
            palette,
            icon: Icons.mark_chat_unread_outlined,
            title: 'Tidak ada pesan',
            subtitle: 'Pesan terbaru dari mahasiswa akan muncul di sini.',
          )
        else
          ...messages.map(
            (message) => _buildMessageCard(context, palette, message),
          ),
      ],
    );
  }

  Widget _buildMessageSearch(_PsikologPalette palette) {
    return TextField(
      onChanged: controller.updateMessageQuery,
      decoration: InputDecoration(
        hintText: 'Cari pesan mahasiswa...',
        prefixIcon: Icon(Icons.search, color: palette.menuInactiveIcon),
        filled: true,
        fillColor: palette.card,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.menuActiveBorder, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildMessageCard(
    BuildContext context,
    _PsikologPalette palette,
    ClientMessage message,
  ) {
    final riskSurface = _riskBackground(message.riskLevel, palette.isDark);
    final riskText = _riskTextColor(message.riskLevel, palette.isDark);
    final user = controller.userByUsername(message.username);

    return GestureDetector(
      onTap: user == null
          ? null
          : () {
              controller.viewStudentProfile(user);
              Get.to(
                () => const PsikologStudentDetailView(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 280),
              );
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 16,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(message.name),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: message.isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        message.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.snippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: riskSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_emotions,
                              size: 14,
                              color: riskText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              message.moodScore.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: riskText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (message.isUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4D67),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Belum dibaca',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0] : '?';
    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFF4A90E2).withValues(alpha: 0.18),
      child: Text(
        initial.toUpperCase(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2468C9),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    _PsikologPalette palette, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: palette.menuInactiveIcon),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: palette.textSecondary),
          ),
        ],
      ),
    );
  }

  Color _riskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return const Color(0xFF3CC896);
      case RiskLevel.medium:
        return const Color(0xFFFFA726);
      case RiskLevel.high:
        return const Color(0xFFFF6B6B);
    }
  }

  Color _riskBackground(RiskLevel level, bool isDark) {
    final base = _riskColor(level);
    return base.withValues(alpha: isDark ? 0.24 : 0.12);
  }

  Color _riskTextColor(RiskLevel level, bool isDark) {
    if (isDark) return Colors.white;
    switch (level) {
      case RiskLevel.low:
        return const Color(0xFF0E6A46);
      case RiskLevel.medium:
        return const Color(0xFF8A4A00);
      case RiskLevel.high:
        return const Color(0xFF912121);
    }
  }
}

class _ScheduleMetric extends StatelessWidget {
  const _ScheduleMetric({
    required this.title,
    required this.value,
    required this.palette,
    required this.icon,
  });

  final String title;
  final String value;
  final _PsikologPalette palette;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: palette.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PsikologPalette {
  _PsikologPalette._({
    required this.isDark,
    required this.scaffold,
    required this.card,
    required this.border,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.headerGradient,
    required this.onPrimary,
    required this.primary,
    required this.menuActiveBackground,
    required this.menuActiveBorder,
    required this.menuActiveText,
    required this.menuInactiveText,
    required this.menuActiveIcon,
    required this.menuInactiveIcon,
    required this.shadow,
  });

  factory _PsikologPalette.of(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return _PsikologPalette._(
      isDark: isDark,
      scaffold: isDark ? const Color(0xFF0F141C) : const Color(0xFFF3F6FB),
      card: isDark ? const Color(0xFF1F2735) : Colors.white,
      border: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : const Color(0xFFE2E7F1),
      surfaceVariant: isDark
          ? const Color(0xFF2B3545)
          : const Color(0xFFE9EEF6),
      textPrimary: colors.onSurface,
      textSecondary: colors.onSurface.withValues(alpha: 0.65),
      headerGradient: isDark
          ? [const Color(0xFF3C4F71), const Color(0xFF222F43)]
          : [colors.primary, colors.primaryContainer],
      onPrimary: colors.onPrimary,
      primary: colors.primary,
      menuActiveBackground: colors.primary.withValues(
        alpha: isDark ? 0.22 : 0.12,
      ),
      menuActiveBorder: colors.primary.withValues(alpha: isDark ? 0.5 : 0.4),
      menuActiveText: colors.primary,
      menuInactiveText: colors.onSurface.withValues(alpha: 0.65),
      menuActiveIcon: colors.primary,
      menuInactiveIcon: colors.onSurface.withValues(alpha: 0.55),
      shadow: isDark
          ? Colors.black.withValues(alpha: 0.35)
          : const Color(0x1A1C2838),
    );
  }

  final bool isDark;
  final Color scaffold;
  final Color card;
  final Color border;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final List<Color> headerGradient;
  final Color onPrimary;
  final Color primary;
  final Color menuActiveBackground;
  final Color menuActiveBorder;
  final Color menuActiveText;
  final Color menuInactiveText;
  final Color menuActiveIcon;
  final Color menuInactiveIcon;
  final Color shadow;
}
