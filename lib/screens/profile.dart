import 'package:flutter/material.dart';
import '../dashboard.dart';

class ProfilePage extends StatefulWidget {
  final int ecoActions;
  final int weeklyChallengesDone;
  final List<String> earnedBadges;

  const ProfilePage({
    Key? key,
    required this.ecoActions,
    required this.weeklyChallengesDone,
    required this.earnedBadges,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  bool _isEditingName = false;
  String _userName = 'Your Name';

  @override
  void initState() {
    super.initState();
    _nameController.text = _userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      if (_isEditingName) {
        _userName = _nameController.text.trim();
      }
      _isEditingName = !_isEditingName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Info with editable name
              Row(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _isEditingName
                              ? TextField(
                            controller: _nameController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : Text(
                            _nameController.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_isEditingName ? Icons.check : Icons.edit, color: Colors.green),
                          onPressed: _toggleEditing,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Eco Warrior 🌍'),

              const SizedBox(height: 24),

              // Stats
              const Text(
                'Your Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(label: 'Eco Actions', value: widget.ecoActions.toString()),
                      _StatItem(label: 'Challenges', value: widget.weeklyChallengesDone.toString()),
                      _StatItem(label: 'Badges', value: widget.earnedBadges.length.toString()),
                    ],
                  ),
                ),
              ),

              const Spacer(),

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
                            MaterialPageRoute(builder: (context) => DashboardPage()), // Make sure to import this!
                          );
                        },
                      ),
                      _NavIcon(
                        icon: Icons.person,
                        label: 'Profile',
                        onTap: () {
                          // Already on Profile page, maybe add feedback or no-op
                        },
                      ),
                    ],
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
