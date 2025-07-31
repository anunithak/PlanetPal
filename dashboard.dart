import 'package:flutter/material.dart';
import 'lib/daily_challenge.dart'; // Create this later if needed

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int get ecoPoints => habitChecked.where((c) => c).length * 10;

  final List<String> habits = [
    'Used a reusable bottle',
    'Took public transport',
    'Meat-free meal',
  ];

  final Map<String, Map<String, double>> habitImpact = {
    'Used a reusable bottle': {'co2': 0.5, 'water': 1.0},
    'Took public transport': {'co2': 2.0, 'water': 0.0},
    'Meat-free meal': {'co2': 3.0, 'water': 2.0},
  };

  List<bool> habitChecked = [false, false, false];

  Map<String, double> get totalImpact {
    double co2 = 0;
    double water = 0;
    for (int i = 0; i < habits.length; i++) {
      if (habitChecked[i]) {
        co2 += habitImpact[habits[i]]!['co2']!;
        water += habitImpact[habits[i]]!['water']!;
      }
    }
    return {'co2': co2, 'water': water};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eco Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text('Today\'s Impact:', style: TextStyle(fontSize: 18)),
            Text('🌬️ CO₂ saved: ${totalImpact['co2']} kg'),
            Text('💧 Water saved: ${totalImpact['water']} L'),

            Text('Today\'s Habits:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            ...List.generate(habits.length, (index) {
              return CheckboxListTile(
                title: Text(habits[index]),
                value: habitChecked[index],
                onChanged: (bool? value) {
                  setState(() {
                    habitChecked[index] = value ?? false;
                  });
                },
              );
            }),
            Text('🔥 Current Streak: 5 days', style: TextStyle(fontSize: 18)),

            SizedBox(height: 30),
            Text('Weekly Challenge:', style: TextStyle(fontSize: 18)),
            ListTile(
              leading: Icon(Icons.local_florist),
              title: Text('🌍 No Plastic Week'),
              subtitle: Text('Avoid single-use plastic all week.'),
            ),
            Text('🏅 Badges Earned:', style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 10,
              children: [
                Chip(label: Text('7-Day Streak')),
                Chip(label: Text('Plastic-Free Pro')),
              ],
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/daily');
              },
              child: Text('🗓️ Daily Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}
