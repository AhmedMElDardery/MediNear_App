// import 'package:flutter/material.dart';
// import 'package:medinear_app/core/components/animated_dots.dart';
// import 'package:medinear_app/core/components/primary_button.dart';
// import 'package:medinear_app/core/theme/app_colors.dart';
// import 'package:medinear_app/features/onboarding/onboarding_provider.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';
// import 'package:medinear_app/features/onboarding/onboarding_page.dart';

// class OnboardingScreen extends ConsumerStatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
//   final PageController _controller =PageController();

//   @override
//   Widget build(BuildContext context) {
//     final Provider = ref.watch(onboardingProvider);

//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: PageView(
//                 controller: _controller,
//                 onPageChanged: Provider.changePage,
//                 children: [
//                   OnboardingPage(
//                     image : "assets/images/onboarding_1.jpg",
//                     title : "Welcome to \n MediNear",
//                     desc : "Your trusted health partner for easy \n and fast medication delivery.",
//                   ),
//                   OnboardingPage(
//                     image : "assets/images/onboarding_2.jpg",
//                     title : "Manage Your Health",
//                     desc : "Keep track of all your medications \n with smart remiders and \n easy-acces health records.",
//                   ),
//                   OnboardingPage(
//                     image : "assets/images/onboarding_3.jpg",
//                     title : "Care for your Family",
//                     desc : "Easily magange your familys medications, \n set remidnders, and find the neaarest \n Pharmacies with the drugs you need.",
//                   )
//                 ],
//               ),
//             ),
//             AnimatedDots(
//               currentIdex: Provider.currentIndex ,
//               count: 3,
//               ),
//             const SizedBox(height: 20,),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: PrimaryButton(
//               text: Provider.currentIndex == 2
//               ? "Start Using MediNear"
//               : "Next",
//               onPressed: (){
//                 if (Provider.currentIndex == 2) {
//                   Provider.finishOnboarding(context);
//                 } else {
//                   _controller.nextPage(
//                     duration: const Duration(milliseconds: 400),
//                     curve: Curves.easeInOut
//                     );
//                 }
//               },
//             ),
//           ),
//           const SizedBox(height: 10,),
//           TextButton(
//             onPressed: () => Provider.finishOnboarding(context),
//             child: const Text("Skip"),
//             ),
//             const SizedBox(height: 20,)

//           ],
//         )
//         ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:medinear_app/core/components/animated_dots.dart';
import 'package:medinear_app/features/onboarding/onboarding_page.dart';
import 'package:medinear_app/features/onboarding/onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/core/theme/app_colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                physics: const BouncingScrollPhysics(),
                controller: _controller,
                onPageChanged: provider.changePage,
                children: const [
                  OnboardingPage(
                    image: "assets/images/onboarding_1.jpg",
                    title: "Welcome to Medinear",
                    desc:
                        "Your trusted health partner for easy and fast medication delivery.",
                  ),
                  OnboardingPage(
                    image: "assets/images/onboarding_2.jpg",
                    title: "Manage Your Health",
                    desc:
                        "Keep track of all your medications with smart reminders and easy-access health records.",
                  ),
                  OnboardingPage(
                    image: "assets/images/onboarding_3.jpg",
                    title: "Care for your family",
                    desc:
                        "Easily manage your family's medications, set reminders, and find the nearest pharmacies with the drugs you need.",
                  ),
                ],
              ),
            ),
            AnimatedDots(
              currentIndex: provider.currentIndex,
              count: 3,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    provider.currentIndex == 2
                        ? "Start Using Medinear"
                        : "Next",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    if (provider.currentIndex == 2) {
                      provider.finishOnboarding(context);
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => provider.finishOnboarding(context),
              child: const Text(
                "Skip",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
