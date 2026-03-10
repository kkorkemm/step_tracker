import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/step_service.dart';
import 'data/services/storage_service.dart';
import 'data/repositories/tracker_repository.dart';
import 'data/repositories/challenge_repository.dart';
import 'ui/viewmodels/home_viewmodel/main_screen_viewmodel.dart';
import 'ui/viewmodels/friends_viewmodel/friends_achievement_viewmodel.dart';
import 'ui/viewmodels/challenge_viewmodel/challenge_list_viewmodel.dart';
import 'ui/viewmodels/profile_viewmodel/user_viewmodel.dart';
import 'ui/views/home_screen/main_screen.dart';
import 'ui/views/friends_screen/friends_achievements_screen.dart';
import 'ui/views/challenge_screen/challenge_list_screen.dart';
import 'ui/views/profile_screen/user_screen.dart';

// Флаг для переключения между моками и реальностью
const bool USE_MOCKS = true; // false - реальные данные

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (USE_MOCKS) {
    print('Используем МОК-данные для тестирования');
    runApp(MyApp());
  } else {
    // Реальная инициализация
    final storageService = StorageService();
    await storageService.init();
    final stepService = StepService();
    await stepService.startListening();
    runApp(MyApp(
      storageService: storageService,
      stepService: stepService,
    ));
  }
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final StepService stepService;

  const MyApp({
    super.key,
    required this.storageService,
    required this.stepService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Сервисы
        Provider.value(value: storageService),
        Provider.value(value: stepService),

        // Репозитории
        ProxyProvider2<StorageService, StepService, TrackerRepository>(
          update: (_, storage, step, __) => TrackerRepository(
            storage: storage,
            stepService: step,
          ),
        ),
        ProxyProvider<StorageService, ChallengeRepository>(
          update: (_, storage, __) => ChallengeRepository(storage: storage),
        ),

        // ViewModels
        ChangeNotifierProxyProvider2<TrackerRepository, ChallengeRepository, HomeViewModel>(
          create: (context) => HomeViewModel(
            trackerRepository: context.read<TrackerRepository>(),
            challengeRepository: context.read<ChallengeRepository>(),
          ),
          update: (_, tracker, challenge, __) => HomeViewModel(
            trackerRepository: tracker,
            challengeRepository: challenge,
          ),
        ),
        ChangeNotifierProvider(create: (_) => FriendsViewModel()),
        ChangeNotifierProvider(create: (_) => ChallengeViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'Foot Crew - трекер шагов с друзьями',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
        ),
        home: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    MainScreen(),
    FriendsListScreen(),
    ChallengeListScreen(),
    UserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Друзья',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events),
            label: 'Челленджи',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
