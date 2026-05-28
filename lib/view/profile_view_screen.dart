import 'package:flutter/material.dart';

import '../utils/app_colors.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryOrange.withOpacity(0.4), Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 30),
              child: Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white10,
                      child: Icon(Icons.person, size: 60, color: Colors.white54),
                    ),
                    const SizedBox(height: 16),
                    const Text("Rahul Kumar", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text("11th • NEET UG", style: TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Text("Edit profile", style: TextStyle(color: Colors.white, fontSize: 12)),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- STATS ROW ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("0d", "Streak"),
                _buildStatItem("0h", "Hours"),
                _buildStatItem("0", "Tests"),
              ],
            ),

            const SizedBox(height: 20),

            // --- SUBSCRIPTION BOX ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3))
              ),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text("Subscription plan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primaryOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text("FREE", style: TextStyle(color: AppColors.primaryOrange, fontSize: 10))
                    )
                  ]),
                  const SizedBox(height: 10),
                  _buildListRow("Current Plan", "Free user"),
                  _buildListRow("Autopay Status", "Paused"),
                  _buildListRow("Manage Subscription", ">"),
                  const SizedBox(height: 10),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(),
                        child: const Text("Upgrade to Pro", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("Learning"),
            _buildMenuItem(Icons.bookmark_border, "Saved reels"),
            _buildMenuItem(Icons.history, "Attempt history"),

            _buildMenuItem(Icons.lock_rounded, "Security & Privacy"),

            // --- PREFERENCES ---
            _buildSectionTitle("Preferences"),
            SwitchListTile(
              title: const Text("Dark mode", style: TextStyle(color: Colors.white)),
              value: true,
              activeColor: AppColors.primaryOrange,
              onChanged: (val) {},
            ),
            ListTile(
              title: const Text("Language", style: TextStyle(color: Colors.white)),
              trailing: Container(
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), color: AppColors.primaryOrange, child: const Text("EN", style: TextStyle(color: Colors.white))),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Text("HI", style: TextStyle(color: Colors.white54))),
                  ],
                ),
              ),
            ),

            // --- LOGOUT CENTERED ---
            const SizedBox(height: 15),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: AppColors.primaryOrange),
                label: const Text("Logout", style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildListRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(value, style: TextStyle(color: value == "Paused" ? AppColors.primaryOrange : Colors.white, fontSize: 13))
      ]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
      onTap: () {},
    );
  }
}