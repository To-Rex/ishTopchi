import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sarlavha
            Text(
              post['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Ish haqi
            Row(
              children: [
                Icon(Icons.monetization_on_outlined, size: 18, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text("${post['salary_from']} – ${post['salary_to']} so'm", style: TextStyle(color: Colors.green.shade700)),
              ],
            ),
            const SizedBox(height: 6),
            // Kategoriya va Hudud
            Wrap(
              spacing: 12,
              children: [
                Chip(label: Text(post['category']?['title'] ?? '', style: const TextStyle(fontSize: 12))),
                Chip(label: Text(post['district']?['name'] ?? '', style: const TextStyle(fontSize: 12))),
              ],
            ),
            const SizedBox(height: 6),
            // Foydalanuvchi
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post['user']?['profile_picture'] ?? ''),
                  radius: 14,
                ),
                const SizedBox(width: 8),
                Text("${post['user']?['first_name'] ?? ''} ${post['user']?['last_name'] ?? ''}", style: const TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
