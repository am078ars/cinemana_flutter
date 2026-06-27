import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1a0a0a), AppTheme.background],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? '---',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '@${user?.username ?? ''}',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                          label: 'متابِع', value: '${user?.followers ?? 0}'),
                      Container(width: 1, height: 32, color: AppTheme.divider),
                      _StatItem(
                          label: 'متابَع', value: '${user?.following ?? 0}'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Menu items
            _MenuItem(
              icon: Icons.favorite_border,
              title: 'المفضلة',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.history,
              title: 'سجل المشاهدة',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.download_outlined,
              title: 'التنزيلات',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.notifications_outlined,
              title: 'الإشعارات',
              onTap: () {},
            ),

            const Divider(color: AppTheme.divider, height: 32),

            _MenuItem(
              icon: Icons.logout,
              title: 'تسجيل الخروج',
              color: Colors.redAccent,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.surface,
                    title: const Text('تسجيل الخروج',
                        style: TextStyle(color: AppTheme.textPrimary)),
                    content: const Text('هل تريد تسجيل الخروج؟',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('خروج',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await auth.logout();
                }
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label,
            style:
                const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem(
      {required this.icon,
      required this.title,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.textSecondary),
      title: Text(title,
          style: TextStyle(color: color ?? AppTheme.textPrimary, fontSize: 15)),
      trailing: color == null
          ? const Icon(Icons.chevron_left, color: AppTheme.textMuted)
          : null,
      onTap: onTap,
    );
  }
}
