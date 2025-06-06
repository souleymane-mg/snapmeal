import 'package:animate_do/animate_do.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../LoginScreen.dart';
import 'CustomOutlinedButton.dart';

class AppAssets {
  static const kOnboardingFirst = 'assets/images/autres/splashScreen/Splash2sante.png';
  static const kOnboardingSecond = 'assets/images/autres/splashScreen/splash3sante.png';
  static const kOnboardingThird = 'assets/images/autres/splashScreen/splash4sante.png';
}

class AppColors {
  static const kPrimary = Color(0xFF5ae4a8);
  static const kSecondary = Colors.black;
  static const kBackground = Color(0xFFFFFFFF);
}

class FoochiOnboardingView extends StatefulWidget {
  const FoochiOnboardingView({Key? key}) : super(key: key);

  @override
  State<FoochiOnboardingView> createState() => _FoochiOnboardingViewState();
}

class _FoochiOnboardingViewState extends State<FoochiOnboardingView> {
  final PageController pageController = PageController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (seenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginscreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Expanded(
              flex: 3,
              child: PageView.builder(
                itemCount: onboardingList.length,
                controller: pageController,
                onPageChanged: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                itemBuilder: (context, index) {
                  return OnBoardingCard(
                    index: index,
                    onBoarding: onboardingList[index],
                  );
                },
              ),
            ),
            CustomIndicator(position: currentIndex),
            const SizedBox(height: 83),
            CustomOutlinedButton(
              width: 130,
              onTap: () async {
                if (currentIndex == (onboardingList.length - 1)) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seenOnboarding', true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Loginscreen()),
                  );
                } else {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }
              },
              text: currentIndex == (onboardingList.length - 1)
                  ? 'Commencer'
                  : 'Suivant',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class OnBoardingCard extends StatelessWidget {
  final Onboarding onBoarding;
  final int index;
  const OnBoardingCard({
    required this.onBoarding,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 1400),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(onBoarding.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: onBoarding.title1,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w400,
                  color: AppColors.kSecondary,
                ),
                children: [
                  TextSpan(
                    text: onBoarding.title2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                      color: AppColors.kPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              onBoarding.description,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.kSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class Onboarding {
  final String title1;
  final String title2;
  final String description;
  final String image;

  Onboarding({
    required this.title1,
    required this.title2,
    required this.description,
    required this.image,
  });
}

final List<Onboarding> onboardingList = [
  Onboarding(
    title1: 'Nous  ',
    title2: 'Prenons soin de vous',
    description: 'Faite vous suivre à domicile par nos spécialistes.',
    image: AppAssets.kOnboardingFirst,
  ),
  Onboarding(
    title1: 'Présent  ',
    title2: 'Et à votre disposition',
    description: 'Votre bien-être et votre santé sont notre priorité.',
    image: AppAssets.kOnboardingSecond,
  ),
  Onboarding(
    title1: 'Obtenez ',
    title2: 'De précieux conseils',
    description: 'Recevez des newsletters sur l\'actualité dans le domaine du bien-être et de la santé en général.',
    image: AppAssets.kOnboardingThird,
  ),
];

class CustomIndicator extends StatelessWidget {
  final int position;
  const CustomIndicator({required this.position, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: onboardingList.length,
      position: position,
      decorator: DotsDecorator(
        color: Colors.grey.withOpacity(0.5),
        size: const Size.square(8.0),
        activeSize: const Size(20.0, 8.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        activeColor: AppColors.kPrimary,
      ),
    );
  }
}
