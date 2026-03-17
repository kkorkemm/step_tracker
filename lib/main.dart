import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'data/services/step_service.dart';
import 'data/services/storage_service.dart';
import 'data/repositories/tracker_repository.dart';
import 'data/repositories/mock_challenge_repository.dart';
import 'data/repositories/mock_tracker_repository.dart';
import 'data/repositories/challenge_repository.dart';
import 'ui/viewmodels/home_viewmodel/main_screen_viewmodel.dart';
import 'ui/viewmodels/friends_viewmodel/friends_achievement_viewmodel.dart';
import 'ui/viewmodels/challenge_viewmodel/challenge_list_viewmodel.dart';
import 'ui/viewmodels/profile_viewmodel/user_viewmodel.dart';
import 'ui/views/home_screen/main_screen.dart';
import 'ui/views/friends_screen/friends_achievements_screen.dart';
import 'ui/views/challenge_screen/challenge_list_screen.dart';
import 'ui/views/profile_screen/user_screen.dart';
const bool USE_MOCKS = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 // Инициализация Hive
  await Hive.initFlutter();
  
  // Флаг первого запуска
  final firstRun = await _isFirstRun();
  
  if (firstRun) {
    print('Первый запуск, очищаем старые данные');
    await Hive.deleteBoxFromDisk('steps');
    await Hive.deleteBoxFromDisk('challenges');
    await Hive.deleteBoxFromDisk('streak');
  }
  
  // Открываем боксы
  await Hive.openBox<int>('steps');
  await Hive.openBox<Map>('challenges');
  await Hive.openBox<Map>('streak');
  
  // Если первый запуск, устанавливаем шаги в 0
  if (firstRun) {
    final stepsBox = Hive.box<int>('steps');
    final today = DateTime.now().toIso8601String().split('T')[0];
    await stepsBox.put(today, 0);
    await _saveFirstRunFlag(false);
  }

  final storageService = StorageService();
  final stepService = StepService();
  await stepService.startListening();

  runApp(MyApp(
    storageService: storageService,
    stepService: stepService,
  ));
}

Future<bool> _isFirstRun() async {
  final box = await Hive.openBox<bool>('settings');
  final firstRun = box.get('firstRun', defaultValue: true);
  return firstRun == true;
}

Future<void> _saveFirstRunFlag(bool value) async {
  final box = await Hive.openBox<bool>('settings');
  await box.put('firstRun', value);
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
      if (USE_MOCKS) ...[
        // МОК-РЕПОЗИТОРИИ (для тестирования)
        Provider<TrackerRepository>(
          create: (_) => MockTrackerRepository(),
        ),
        Provider<ChallengeRepository>(
          create: (_) => MockChallengeRepository(),
        ),
      ] else ...[
        // РЕАЛЬНЫЕ РЕПОЗИТОРИИ (с Hive и шагомером)
        ProxyProvider2<StorageService, StepService, TrackerRepository>(
          update: (_, storage, step, __) => TrackerRepository(
            storage: storage,
            stepService: step,
          ),
        ),
        ProxyProvider<StorageService, ChallengeRepository>(
          update: (_, storage, __) => ChallengeRepository(storage: storage),
        ),
      ],

      // ========== VIEWMODELS ==========
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
      ChangeNotifierProvider(create: (_) => ChallengeViewModel(
      challengeRepository: MockChallengeRepository())),
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
