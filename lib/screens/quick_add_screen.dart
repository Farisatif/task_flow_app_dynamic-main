import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';

class QuickAddScreen extends StatelessWidget {
  const QuickAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('مهمة', Icons.check_box_outlined, AppColors.primary, '/task-form'),
      ('مشروع', Icons.folder_outlined, AppColors.accentBlue, '/projects'),
      ('تذكير', Icons.notifications_outlined, AppColors.priorityHigh, '/reminders'),
      ('ملاحظة', Icons.sticky_note_2_outlined, AppColors.accentOrange, '/notes'),
      ('هدف', Icons.flag_outlined, AppColors.accentGreen, '/goals'),
      ('عادة', Icons.repeat, AppColors.accentPink, '/habits'),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('إضافة سريعة', style: TextStyle(color: Colors.white))),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.95),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final it = items[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(it.$4);
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: it.$3.withValues(alpha: 0.15), shape: BoxShape.circle),
                            child: Icon(it.$2, color: it.$3),
                          ),
                          const SizedBox(height: 8),
                          Text(it.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'أو اكتب عنوان مهمة مباشرة...',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primary),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/task-form');
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
