import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './widgets/habit_tile.dart';
import 'dart:convert';
import './screens/profile.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int ecoActions = 0;
  int weeklyChallengesDone = 0;

  // Badge tracking
  Set<String> earnedBadges = {};
  Map<String, int> lifetimeCompletions = {};


  // Habit counts for badges
  int publicTransportCount = 0;
  int meatFreeMealCount = 0;
  int reusableBottleCount = 0;

  // Weekly Challenges - now structured as a single current challenge with progress
  List<Map<String, dynamic>> weeklyChallenges = [
    {
      'name': 'Walk or bike to work',
      'icon': Icons.directions_bike,
      'description': 'Choose eco-friendly transport this week!',
      'totalDays': 7,
    },
    {
      'name': 'Pick up 5 pieces of litter',
      'icon': Icons.cleaning_services,
      'description': 'Help clean the environment by picking litter.',
      'totalDays': 7,
    },
    {
      'name': 'Avoid plastic packaging',
      'icon': Icons.no_drinks,
      'description': 'Try to reduce plastic packaging in your purchases.',
      'totalDays': 7,
    },
  ];

  int currentChallengeIndex = 0;

  // Track daily completion count per challenge (simulate progress)
  Map<String, int> dailyProgress = {}; // e.g., {challengeName: daysCompleted}
  Set<String> didToday = {}; // track if "Did it today" checked for current challenge

  Set<String> completedChallenges = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now();
    final todayKey = "${today.year}-${today.month}-${today.day}";

    final List<String> jsonList = prefs.getStringList('weeklyChallenges') ?? [];
    final List<Map<String, dynamic>> decodedChallenges =
    jsonList.isNotEmpty
        ? jsonList.map((e) => json.decode(e) as Map<String, dynamic>).toList()
        : weeklyChallenges; // fallback to default

    setState(() {
      weeklyChallenges = decodedChallenges;


      ecoActions = prefs.getInt('ecoActions') ?? 0;
      weeklyChallengesDone = prefs.getInt('weeklyChallengesDone') ?? 0;

      earnedBadges = (prefs.getStringList('earnedBadges') ?? []).toSet();

      publicTransportCount = prefs.getInt('publicTransportCount') ?? 0;
      meatFreeMealCount = prefs.getInt('meatFreeMealCount') ?? 0;
      reusableBottleCount = prefs.getInt('reusableBottleCount') ?? 0;

      completedChallenges = (prefs.getStringList('completedChallenges') ?? []).toSet();

      // Load dailyProgress and didToday for current challenge
      for (var challenge in weeklyChallenges) {
        final name = challenge['name'];
        dailyProgress[name] = prefs.getInt('progress_$name') ?? 0;
        lifetimeCompletions[name] = prefs.getInt('lifetime_$name') ?? 0;
      }


      String todayDoneKey = 'didToday_${todayKey}_${weeklyChallenges[currentChallengeIndex]['name']}';
      bool doneToday = prefs.getBool(todayDoneKey) ?? false;
      if (doneToday) {
        didToday.add(weeklyChallenges[currentChallengeIndex]['name']);
      }
    });

    _checkForBadges(prefs);
  }

  Future<void> _saveBadges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('earnedBadges', earnedBadges.toList());
  }

  Future<void> updateFootprint(String habitKey, bool checked) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = "${today.year}-${today.month}-${today.day}";

    int currentEcoActions = prefs.getInt('ecoActions') ?? 0;
    currentEcoActions += checked ? 1 : -1;
    if (currentEcoActions < 0) currentEcoActions = 0;
    await prefs.setInt('ecoActions', currentEcoActions);


    int habitCount = prefs.getInt(habitKey) ?? 0;
    habitCount += checked ? 1 : -1;
    if (habitCount < 0) habitCount = 0;
    await prefs.setInt(habitKey, habitCount);

    setState(() {
      ecoActions = currentEcoActions;
      if (habitKey == 'publicTransportCount') publicTransportCount = habitCount;
      if (habitKey == 'meatFreeMealCount') meatFreeMealCount = habitCount;
      if (habitKey == 'reusableBottleCount') reusableBottleCount = habitCount;
    });

    _checkForBadges(prefs);
  }

  Future<void> toggleChallengeToday(bool checked) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = "${today.year}-${today.month}-${today.day}";

    String challengeName = weeklyChallenges[currentChallengeIndex]['name'];
    int totalDays = weeklyChallenges[currentChallengeIndex]['totalDays'];

    String todayDoneKey = 'didToday_${todayKey}_$challengeName';

    setState(() {
      if (checked) {
        didToday.add(challengeName);
        dailyProgress[challengeName] = (dailyProgress[challengeName] ?? 0) + 1;
        if (dailyProgress[challengeName]! > totalDays) {
          dailyProgress[challengeName] = totalDays;
        }
      } else {
        didToday.remove(challengeName);
        dailyProgress[challengeName] = (dailyProgress[challengeName] ?? 1) - 1;
        if (dailyProgress[challengeName]! < 0) {
          dailyProgress[challengeName] = 0;
        }
      }
    });

    await prefs.setBool(todayDoneKey, checked);
    await prefs.setInt('progress_$challengeName', dailyProgress[challengeName]!);
  }
  int startingEcoActions = 10; // set this to the current count when you want to "start" the plant growth
  int maxStage = 6; // total stages you have (number of seed images)

  String _getPlantImage() {
    int relativeGrowth = ecoActions - startingEcoActions;
    int level = (relativeGrowth + 1).clamp(1, maxStage); // always start from seed1_t.png
    return 'assets/seed${level}_c.png';
  }

  void _checkForBadges(SharedPreferences prefs) {
    bool newBadge = false;

    if (publicTransportCount >= 4 && !earnedBadges.contains('Green Mover')) {
      earnedBadges.add('Green Mover');
      newBadge = true;
      _showBadgeEarnedDialog('Green Mover');
    }
    if (meatFreeMealCount >= 10 && !earnedBadges.contains('Meat Free Hero')) {
      earnedBadges.add('Meat Free Hero');
      newBadge = true;
      _showBadgeEarnedDialog('Meat Free Hero');
    }
    if (reusableBottleCount >= 14 && !earnedBadges.contains('Bottle Boss')) {
      earnedBadges.add('Bottle Boss');
      newBadge = true;
      _showBadgeEarnedDialog('Bottle Boss');
    }

    if (newBadge) {
      _saveBadges();
      setState(() {});
    }
  }

  void _showBadgeEarnedDialog(String badgeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Badge Earned! 🎉'),
        content: Text('You earned the "$badgeName" badge!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _nextChallenge() {
    setState(() {
      currentChallengeIndex = (currentChallengeIndex + 1) % weeklyChallenges.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentChallenge = weeklyChallenges[currentChallengeIndex];
    final progressCount = dailyProgress[currentChallenge['name']] ?? 0;
    final totalDays = currentChallenge['totalDays'];
    final progressPercent = totalDays == 0 ? 0 : progressCount / totalDays;
    final didItToday = didToday.contains(currentChallenge['name']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PlanetPal'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top panels
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              color: Colors.green.shade100,
                              alignment: Alignment.center,
                              child:Padding(
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  _getPlantImage(),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: EcoSummaryPanel(
                              ecoActions: ecoActions,
                              weeklyChallengesDone: weeklyChallengesDone,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Habits
                    const Text(
                      "Today's Habits:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    HabitTile(
                      title: 'Took public transport',
                      onChanged: (checked) => updateFootprint('publicTransportCount', checked),
                    ),
                    HabitTile(
                      title: 'Meat-free meal',
                      onChanged: (checked) => updateFootprint('meatFreeMealCount', checked),
                    ),
                    HabitTile(
                      title: 'Used a reusable bottle',
                      onChanged: (checked) => updateFootprint('reusableBottleCount', checked),
                    ),

                    const SizedBox(height: 24),

                    // *** NEW Weekly Challenge Section - shows only current challenge ***
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Weekly Challenge:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: _nextChallenge,
                          child: const Text('Next Challenge'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(currentChallenge['icon'], size: 28, color: Colors.green),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    currentChallenge['name'],
                                    style: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentChallenge['description'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: progressPercent.toDouble(),
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.green,
                              minHeight: 10,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$progressCount / $totalDays days complete',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Did it today?'),
                              value: didItToday,
                              onChanged: (checked) {
                                if (checked != null) {
                                  toggleChallengeToday(checked);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Badges
                    const Text(
                      'Badges Earned:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: earnedBadges.map((badge) {
                        String emoji = '';
                        if (badge == 'Green Mover') emoji = '🚲';
                        else if (badge == 'Meat Free Hero') emoji = '🥦';
                        else if (badge == 'Bottle Boss') emoji = '💧';
                        return Chip(label: Text('$emoji $badge'));
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom nav island
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavIcon(
                    icon: Icons.dashboard_customize,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DashboardPage()),
                      );
                    },
                  ),
                  _NavIcon(
                    icon: Icons.person,
                    label: 'Profile',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            ecoActions: ecoActions,
                            weeklyChallengesDone: weeklyChallengesDone,
                            earnedBadges: earnedBadges.toList()
                          ),
                        ),
                      );

                    }
                  )

                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;  // We add this to handle taps

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.onTap,  // new required param
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(                  // Wrap with InkWell to detect taps
      onTap: onTap,                 // Call the passed in onTap function
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}


class EcoSummaryPanel extends StatefulWidget {
  final int ecoActions;
  final int weeklyChallengesDone;

  const EcoSummaryPanel({
    required this.ecoActions,
    required this.weeklyChallengesDone,
    super.key,
  });

  @override
  State<EcoSummaryPanel> createState() => _EcoSummaryPanelState();
}

class _EcoSummaryPanelState extends State<EcoSummaryPanel> {
  int _currentIndex = 0;

  void _nextItem(int totalItems) {
    setState(() {
      _currentIndex = (_currentIndex + 1) % totalItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    final panels = [
      "${widget.ecoActions} Eco Actions ",
      "🏅 ${widget.weeklyChallengesDone} Challenges Done",
    ];

    final icons = [
      Icons.eco,
      Icons.emoji_events,
    ];

    return GestureDetector(
      onTap: () => _nextItem(panels.length),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icons[_currentIndex], size: 40, color: Colors.green),
              const SizedBox(height: 12),
              Text(
                panels[_currentIndex],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8)
            ],
          ),
        ),
      )
    );
  }
}
