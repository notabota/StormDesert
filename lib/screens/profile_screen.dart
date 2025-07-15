import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'john.doe@email.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Cài đặt',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.notifications,
              title: 'Thông báo',
              subtitle: 'Nhắc nhở kiểm tra và cảnh báo',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.dark_mode,
              title: 'Chế độ Tối',
              subtitle: 'Chuyển đổi chế độ tối/sáng',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.language,
              title: 'Ngôn ngữ',
              subtitle: 'Cài đặt ngôn ngữ ứng dụng',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.privacy_tip,
              title: 'Riêng tư',
              subtitle: 'Cài đặt riêng tư và dữ liệu',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.backup,
              title: 'Sao lưu Dữ liệu',
              subtitle: 'Sao lưu kết quả kiểm tra của bạn',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const Text(
              'Giới thiệu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.info,
              title: 'Thông tin Ứng dụng',
              subtitle: 'Phiên bản 1.0.0',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.help,
              title: 'Trợ giúp & Hỗ trợ',
              subtitle: 'Nhận trợ giúp về ứng dụng',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.feedback,
              title: 'Gửi Phản hồi',
              subtitle: 'Báo cáo sự cố hoặc đề xuất',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Đăng xuất'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đăng xuất thành công')),
              );
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}