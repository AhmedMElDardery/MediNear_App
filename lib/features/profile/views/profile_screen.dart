import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import '../view_models/profile_provider.dart';
import 'widgets/profile_widgets.dart';
import 'package:medinear_app/features/auth/presentation/auth_provider.dart';

// استدعاء الصفحات
import 'package:medinear_app/features/about_us/presentation/screens/about_support_screen.dart';
import 'package:medinear_app/features/orders/presentation/screens/my_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  void _showEditDialog(String title, String currentVal, ProfileProvider provider) {
    if (currentVal == 'No Phone' || currentVal == 'No Name' || currentVal == 'No Email') {
      currentVal = '';
    }
    TextEditingController controller = TextEditingController(text: currentVal);
    bool isPhoneField = title == 'Phone';
    
    // 🚀 1. متغير لتخزين رسالة الخطأ وعرضها داخل النافذة
    String? errorMessage; 

    final List<Map<String, dynamic>> countries = [
      {'name': 'Egypt', 'flag': '🇪🇬', 'code': '+20', 'maxLength': 11},
      {'name': 'Saudi Arabia', 'flag': '🇸🇦', 'code': '+966', 'maxLength': 9},
      {'name': 'UAE', 'flag': '🇦🇪', 'code': '+971', 'maxLength': 9},
      {'name': 'Kuwait', 'flag': '🇰🇼', 'code': '+965', 'maxLength': 8},
    ];

    Map<String, dynamic> selectedCountry = countries[0];

    if (isPhoneField) {
      String cleanPhone = currentVal;
      for (var country in countries) {
        if (currentVal.startsWith(country['code'])) {
          selectedCountry = country;
          cleanPhone = currentVal.replaceFirst(country['code'], '').trim();
          break;
        }
      }
      controller.text = cleanPhone;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (stateCtx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text('Edit $title', style: const TextStyle(fontWeight: FontWeight.bold)),
            // 🚀 2. غيرنا الـ Content لـ Column عشان نقدر نحط مربع الإدخال وتحته رسالة الخطأ
            content: Column(
              mainAxisSize: MainAxisSize.min, // عشان مياخدش طول الشاشة كلها
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isPhoneField
                    ? Row(
                        children: [
                          Container(
                            height: 55,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              // لو في خطأ، نخلي حواف المربع حمراء
                              border: Border.all(color: errorMessage != null ? Colors.red : Colors.grey.shade400, width: errorMessage != null ? 1.5 : 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Map<String, dynamic>>(
                                value: selectedCountry,
                                items: countries
                                    .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text('${c['flag']} ${c['code']}', style: const TextStyle(fontSize: 14))))
                                    .toList(),
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedCountry = val!;
                                    controller.clear();
                                    errorMessage = null; // نشيل الخطأ لو غير الدولة
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 55,
                              child: TextField(
                                controller: controller,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(selectedCountry['maxLength'])
                                ],
                                onChanged: (v) => setDialogState(() => errorMessage = null), // نشيل الخطأ أول ما يكتب حاجة
                                decoration: InputDecoration(
                                  hintText: selectedCountry['code'] == '+20' ? "01xxxxxxxxx" : "Enter number",
                                  // لو في خطأ، نخلي حواف المربع حمراء
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: errorMessage != null ? Colors.red : Colors.grey.shade400, width: errorMessage != null ? 1.5 : 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: errorMessage != null ? Colors.red : AppColors.primaryLight, width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : TextField(
                        controller: controller,
                        onChanged: (v) => setDialogState(() => errorMessage = null), // نشيل الخطأ أول ما يكتب حاجة
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: errorMessage != null ? Colors.red : Colors.grey.shade400, width: errorMessage != null ? 1.5 : 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: errorMessage != null ? Colors.red : AppColors.primaryLight, width: 2),
                          ),
                        ),
                      ),
                
                // 🚀 3. عرض رسالة الخطأ بشكل شيك داخل النافذة نفسها تحت المربع مباشرة
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 16),
                      const SizedBox(width: 6),
                      Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ]
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    String finalValue = controller.text.trim();

                    if (isPhoneField) {
                      finalValue = finalValue.replaceAll(' ', '');
                      if (finalValue.startsWith('0')) {
                        finalValue = finalValue.substring(1);
                      }
                      finalValue = '${selectedCountry['code']}$finalValue';
                    }

                    Navigator.pop(dialogCtx);
                    provider.updateData(context, title, finalValue);
                  } else {
                    // 🚀 4. نحدث النافذة من جوه ونعرض رسالة الخطأ
                    setDialogState(() {
                      errorMessage = isPhoneField 
                          ? 'Please enter your phone number!' 
                          : 'Please enter your name!';
                    });
                  }
                },
                child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        final user = provider.user;

        if (provider.isLoading || user == null) {
          return const Scaffold(
            body: Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryLight)),
          );
        }

        // 🚀 اللوجيك الذكي لتحديد الصورة (الأولويات)
        ImageProvider? getProfileImage() {
          // 1. لو مختار صورة من المعرض دلوقتي
          if (user.profileImage != null) {
            return FileImage(user.profileImage!);
          }
          // 2. لو رافع صورة مخصصة في السيرفر
          else if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
            return NetworkImage(user.photoUrl!);
          }
          // 3. لو مفيش مخصصة، نجيب صورة جوجل/فيسبوك
          else if (user.avatar != null && user.avatar!.isNotEmpty) {
            return NetworkImage(user.avatar!);
          }
          // 4. مفيش حاجة خالص
          return null;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.primaryLight,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            title: const Text('Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 25, left: 20, right: 20, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                     onTap: () => provider.pickImage(context),
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.2),
                              shape: BoxShape.circle,
                              // 🚀 بننادي الدالة الذكية هنا
                              image: getProfileImage() != null
                                  ? DecorationImage(
                                      image: getProfileImage()!,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            // 🚀 لو الدالة رجعت null، نعرض الأيقونة الافتراضية
                            child: getProfileImage() == null
                                ? const Icon(Icons.person,
                                    size: 40, color: AppColors.primaryLight)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.edit,
                                  color: AppColors.primaryLight, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(user.email,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text('Account Info',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                InfoCard(
                  label: 'Name :',
                  value: user.name,
                  icon: Icons.person_outline,
                  onEdit: () => _showEditDialog('Name', user.name, provider),
                ),
                const SizedBox(height: 10),
                InfoCard(
                    label: 'Email :',
                    value: user.email,
                    icon: Icons.email_outlined),
                const SizedBox(height: 10),
                InfoCard(
                  label: 'Phone :',
                  value: user.phone,
                  icon: Icons.phone_in_talk_outlined,
                  onEdit: () => _showEditDialog('Phone', user.phone, provider),
                ),
                const SizedBox(height: 25),
                const Center(
                    child: Text('Features',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                        child: FeatureCard(
                            title: 'My Orders',
                            icon: Icons.assignment,
                            onTap: () => _navigateTo(const MyOrdersScreen()))),
                    const SizedBox(width: 15),
                    const Expanded(
                        child: FeatureCard(
                            title: 'Packet', icon: Icons.inventory_2_rounded)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: const [
                    Expanded(
                        child: FeatureCard(
                            title: 'Family', icon: Icons.family_restroom)),
                    SizedBox(width: 15),
                    Expanded(
                        child: FeatureCard(
                            title: 'Reminder', icon: Icons.access_alarm)),
                  ],
                ),
                const SizedBox(height: 25),
                MaterialButton(
                  height: 55,
                  minWidth: double.infinity,
                  color: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  // 🚀 التعديل الاحترافي الجديد والمريح للعين
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogCtx) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        elevation: 10,
                        backgroundColor: Colors.transparent, // لجعل الخلفية شفافة
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            // 1️⃣ جسم النافذة الرئيسي (بعد تعديل المسافة العلوية)
                            Container(
                              width: double.infinity,
                              // 🚀 قللنا المسافة العلوية من 60 لـ 50 عشان العنوان يرتفع ويكون مريح
                              padding: const EdgeInsets.fromLTRB(25, 50, 25, 25), 
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 10, offset: const Offset(0, 10))
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Logout',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'Are you sure you want to log out? You will need to sign in again to access your account.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade400 : Colors.grey, height: 1.4),
                                  ),
                                  const SizedBox(height: 30),
                                  Row(
                                    children: [
                                      // Cancel Button
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          onPressed: () => Navigator.pop(dialogCtx),
                                          child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      // Logout Button
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFD32F2F),
                                            elevation: 3,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(dialogCtx); // إغلاق النافذة
                                            
                                            // تنفيذ كود تسجيل الخروج
                                            context.read<ProfileProvider>().clearProfile();
                                            await context.read<AuthProvider>().logout(context);
                                          },
                                          child: const Text('Yes, Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: -24, 
                              child: CircleAvatar(
                                radius: 24, 
                                backgroundColor: const Color(0xFFD32F2F),
                                child: Container(
                                  // إضافة حدود بيضاء أنعم وأنحف
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isDark ? const Color(0xFF121212) : Colors.white, width: 2.5), 
                                  ),
                                  // تصغير الأيقونة لتناسب الحجم الجديد
                                  child: const Icon(Icons.logout, color: Colors.white, size: 24), 
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Logout',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.logout, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                        child: SmallCard(
                            title: 'Support', icon: Icons.headset_mic)),
                    const SizedBox(width: 15),
                    Expanded(
                        child: SmallCard(
                            title: 'About Us',
                            icon: Icons.info,
                            onTap: () =>
                                _navigateTo(const AboutSupportScreen()))),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}
