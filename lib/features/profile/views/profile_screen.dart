import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medinear_app/features/alarm/views/alarm_view.dart';
import 'package:medinear_app/features/support/presentation/screen/support_screen.dart';
import 'package:medinear_app/features/wallet/views/wallet_view.dart';
import 'package:provider/provider.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import '../view_models/profile_provider.dart';
import 'widgets/profile_widgets.dart';
import 'package:medinear_app/features/auth/presentation/auth_provider.dart';

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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (stateCtx, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? Theme.of(context).cardColor : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Edit $title', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isPhoneField
                    ? Row(
                        children: [
                          Container(
                            height: 55,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: errorMessage != null ? Colors.red : (isDark ? Theme.of(context).dividerColor : Colors.grey.shade300), width: errorMessage != null ? 1.5 : 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Map<String, dynamic>>(
                                dropdownColor: isDark ? Theme.of(context).cardColor : Colors.white,
                                value: selectedCountry,
                                items: countries
                                    .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text('${c['flag']} ${c['code']}', style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87))))
                                    .toList(),
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedCountry = val!;
                                    controller.clear();
                                    errorMessage = null;
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
                                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(selectedCountry['maxLength'])
                                ],
                                onChanged: (v) => setDialogState(() => errorMessage = null),
                                decoration: InputDecoration(
                                  hintText: selectedCountry['code'] == '+20' ? "01xxxxxxxxx" : "Enter number",
                                  hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: errorMessage != null ? Colors.red : (isDark ? Theme.of(context).dividerColor : Colors.grey.shade300), width: errorMessage != null ? 1.5 : 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        onChanged: (v) => setDialogState(() => errorMessage = null),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: errorMessage != null ? Colors.red : (isDark ? Theme.of(context).dividerColor : Colors.grey.shade300), width: errorMessage != null ? 1.5 : 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: errorMessage != null ? Colors.red : AppColors.primaryLight, width: 2),
                          ),
                        ),
                      ),
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
                  style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
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

  void _showLogoutDialog(BuildContext parentContext, bool isDark) {
    showDialog(
      context: parentContext,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
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
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              Navigator.pop(dialogCtx); 
                              parentContext.read<ProfileProvider>().clearProfile();
                              await parentContext.read<AuthProvider>().logout(parentContext);
                            },
                            child: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -32, 
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        spreadRadius: 5,
                        blurRadius: 0,
                      ),
                      BoxShadow(
                        color: const Color(0xFFD32F2F).withOpacity(0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4.0), // لضبط تمركز الأيقونة بصرياً
                    child: Icon(Icons.logout_rounded, color: Colors.white, size: 30),
                  ), 
                ),
              ),
            ],
          ),
        );
      },
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
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        if (provider.isLoading || user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight)),
          );
        }

        ImageProvider? getProfileImage() {
          if (user.profileImage != null) {
            return FileImage(user.profileImage!);
          } else if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
            return NetworkImage(user.photoUrl!);
          } else if (user.avatar != null && user.avatar!.isNotEmpty) {
            return NetworkImage(user.avatar!);
          }
          return null;
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // Subtle translucent header background
                    Container(
                      height: 155,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.15) : const Color(0xFF00965E).withOpacity(0.06),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top + 10),
                        Text(
                          'Profile', 
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.w800, 
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF00965E)
                          )
                        ),
                        const SizedBox(height: 15),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: GestureDetector(
                            onTap: () => provider.pickImage(context),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  )
                                ]
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 105,
                                    height: 105,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? theme.cardColor : AppColors.primaryLight.withOpacity(0.1),
                                      border: Border.all(color: isDark ? theme.dividerColor.withOpacity(0.1) : Colors.grey.shade100, width: 1.5),
                                      image: getProfileImage() != null
                                          ? DecorationImage(
                                              image: getProfileImage()!,
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: getProfileImage() == null
                                        ? const Icon(Icons.person_rounded, size: 55, color: AppColors.primaryLight)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0EA5E9),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isDark ? theme.scaffoldBackgroundColor : Colors.white, width: 3.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0EA5E9).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3)
                                          )
                                        ]
                                      ),
                                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Column(
                  children: [
                    Text(user.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? theme.textTheme.bodyLarge?.color : const Color(0xFF1E293B), letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text(user.email, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500)),
                  ]
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: PremiumProfileGroup(
                          title: 'Personal Information',
                          children: [
                            PremiumProfileTile(
                              title: 'Full Name',
                              subtitle: user.name,
                              icon: Icons.person_outline_rounded,
                              iconColor: const Color(0xFF0EA5E9),
                              onTap: () => _showEditDialog('Name', user.name, provider),
                              trailing: Icon(Icons.edit_rounded, size: 18, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                            ),
                            PremiumProfileTile(
                              title: 'Phone Number',
                              subtitle: user.phone,
                              icon: Icons.phone_in_talk_outlined,
                              iconColor: const Color(0xFF10B981),
                              onTap: () => _showEditDialog('Phone', user.phone, provider),
                              trailing: Icon(Icons.edit_rounded, size: 18, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                            ),
                            PremiumProfileTile(
                              title: 'Email Address',
                              subtitle: user.email,
                              icon: Icons.email_outlined,
                              iconColor: const Color(0xFF8B5CF6),
                              trailing: Icon(Icons.lock_rounded, size: 16, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                              onTap: () {},
                            ),
                          ]
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: PremiumProfileGroup(
                          title: 'Features',
                          children: [
                            PremiumProfileTile(
                              title: 'My Orders',
                              icon: Icons.shopping_bag_outlined,
                              iconColor: const Color(0xFFF59E0B),
                              onTap: () => _navigateTo(const MyOrdersScreen()),
                            ),
                            PremiumProfileTile(
                              title: 'Packet (Wallet)',
                              icon: Icons.account_balance_wallet_outlined,
                              iconColor: const Color(0xFF0EA5E9),
                              onTap: () => _navigateTo(const WalletView()),
                            ),
                            PremiumProfileTile(
                              title: 'Family Members',
                              icon: Icons.family_restroom_rounded,
                              iconColor: const Color(0xFFF43F5E),
                              onTap: () {},
                            ),
                            PremiumProfileTile(
                              title: 'Medicine Reminder',
                              icon: Icons.alarm_rounded,
                              iconColor: const Color(0xFF8B5CF6),
                              onTap: () => _navigateTo(const AlarmView()),
                            ),
                          ]
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: PremiumProfileGroup(
                          title: 'Support & Settings',
                          children: [
                            PremiumProfileTile(
                              title: 'Help & Support',
                              icon: Icons.headset_mic_rounded,
                              iconColor: const Color(0xFF10B981),
                              onTap: () => _navigateTo(const SupportScreen()),
                            ),
                            PremiumProfileTile(
                              title: 'About Us',
                              icon: Icons.info_outline_rounded,
                              iconColor: const Color(0xFF0EA5E9),
                              onTap: () => _navigateTo(const AboutSupportScreen()),
                            ),
                            PremiumProfileTile(
                              title: 'Logout',
                              icon: Icons.logout_rounded,
                              iconColor: const Color(0xFFEF4444),
                              isDestructive: true,
                              trailing: const SizedBox(), 
                              onTap: () => _showLogoutDialog(context, isDark),
                            ),
                          ]
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
