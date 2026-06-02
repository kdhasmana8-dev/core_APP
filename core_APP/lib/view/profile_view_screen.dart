import 'dart:convert';
import 'package:core_app/view/drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_colors.dart';
import 'dart:convert';
import 'package:core_app/view/drawer_screen.dart'; // Adjust as per your path
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String profilePic = "";
  bool isLoading = true;
  int savedReelsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchSavedReelsCount();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name") ?? "Student";
      userEmail = prefs.getString("user_email") ?? "student@example.com";
      profilePic = prefs.getString("profile_pic") ?? "";
      isLoading = false;
    });
  }

  Future<void> _fetchSavedReelsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("user_token");
      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://core-backend-38rr.onrender.com/api/save-reels'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['result'] != null) {
          setState(() {
            savedReelsCount = data['result'].length;
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Colors.black],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
            : CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverAppBar(
              backgroundColor: Colors.transparent,
              title: Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              centerTitle: false,
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [AppColors.primaryOrange, Colors.transparent]),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black,
                      backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                      child: profilePic.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.white54) : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(userEmail, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 10),

                  // Menu Options
                  _buildMenuItem(Icons.bookmark_border, 'Saved Reels', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedReelsScreen()))),
                  _buildMenuItem(Icons.download_outlined, 'Downloads', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadsScreen()))),
                  _buildMenuItem(Icons.bookmarks_outlined, 'Bookmarks', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()))),
                  _buildMenuItem(Icons.notes_outlined, 'My Notes', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesScreen()))),
                  _buildMenuItem(Icons.card_giftcard_outlined, 'Refer & Earn', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferEarnScreen()))),
                  _buildMenuItem(Icons.settings_outlined, 'Settings', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                  _buildMenuItem(Icons.help_outline, 'Help & Support', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),

                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                      label: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 48),
                      ),
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
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryOrange, size: 22),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}


class SavedReelsScreen extends StatefulWidget {
  const SavedReelsScreen({super.key});

  @override
  State<SavedReelsScreen> createState() => _SavedReelsScreenState();
}

class _SavedReelsScreenState extends State<SavedReelsScreen> {
  List<dynamic> savedReels = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print("🟢 SavedReelsScreen: initState called");
    _fetchSavedReels();
  }

  @override
  void dispose() {
    print("🔴 SavedReelsScreen: dispose called");
    super.dispose();
  }

  Future<void> _fetchSavedReels() async {
    print("🔄 _fetchSavedReels: Starting to fetch saved reels");

    setState(() {
      loading = true;
      errorMessage = null;
    });
    print("📊 State updated: loading = true, errorMessage = null");

    try {
      print("🔐 Getting token from SharedPreferences...");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("user_token");

      print("🔑 Token: ${token != null ? "Present (${token.substring(0, token.length > 20 ? 20 : token.length)}...)" : "NULL"}");

      if (token == null) {
        print("❌ Token is null - User not logged in");
        setState(() {
          errorMessage = "Please login to view saved reels";
          loading = false;
        });
        print("📊 State updated: errorMessage set, loading = false");
        return;
      }

      final String apiUrl = 'https://core-backend-38rr.onrender.com/api/save-reels';
      print("🌐 Making GET request to: $apiUrl");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Saved Reels API - Status Code: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");
      print("📏 Response Length: ${response.body.length} characters");

      if (response.statusCode == 200) {
        print("✅ API call successful (200)");
        final data = json.decode(response.body);
        print("🔓 Decoded JSON data: $data");

        print("📋 Checking data['success']: ${data['success']}");
        print("📋 Checking data['result']: ${data['result'] != null ? "Present" : "NULL"}");

        if (data['success'] == true && data['result'] != null) {
          final List<dynamic> resultList = data['result'];
          print("✅ Successfully fetched ${resultList.length} saved reels");

          // Print each saved reel details
          for (int i = 0; i < resultList.length; i++) {
            final reel = resultList[i];
            print("📌 Saved Reel #${i + 1}:");
            print("   - ID: ${reel['_id']}");
            print("   - ReelId: ${reel['reelId']}");
            print("   - Title: ${reel['title']}");
            print("   - Type: ${reel['type']}");
            print("   - VideoUrl: ${reel['videoUrl']}");
            print("   - Thumbnail: ${reel['thumbnail']}");
            print("   - Teacher: ${reel['teacherName']}");
          }

          setState(() {
            savedReels = resultList;
            loading = false;
          });
          print("📊 State updated: savedReels count = ${savedReels.length}, loading = false");
        } else {
          print("⚠️ API returned success=false or result is null");
          setState(() {
            errorMessage = "No saved reels found";
            loading = false;
          });
          print("📊 State updated: errorMessage = 'No saved reels found', loading = false");
        }
      } else {
        print("❌ API call failed with status code: ${response.statusCode}");
        print("❌ Error response body: ${response.body}");
        setState(() {
          errorMessage = "Failed to load saved reels (Status: ${response.statusCode})";
          loading = false;
        });
        print("📊 State updated: errorMessage set, loading = false");
      }
    } catch (e) {
      print("🔥 Exception in _fetchSavedReels: $e");
      print("🔥 Stack trace: ${StackTrace.current}");
      setState(() {
        errorMessage = "Network error. Please try again.";
        loading = false;
      });
      print("📊 State updated: errorMessage = 'Network error', loading = false");
    }
  }

  Future<void> _removeSavedReel(String reelId) async {
    print("🗑️ _removeSavedReel called for reelId: $reelId");

    try {
      print("🔐 Getting token for delete operation...");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("user_token");

      if (token == null) {
        print("❌ Cannot remove: Token is null");
        return;
      }
      print("🔑 Token present for delete operation");

      final String deleteUrl = 'https://core-backend-38rr.onrender.com/api/save-reels/$reelId';
      print("🌐 Making DELETE request to: $deleteUrl");

      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 DELETE API - Status Code: ${response.statusCode}");
      print("📦 DELETE Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Successfully removed saved reel: $reelId");

        // Remove from local list
        final int beforeCount = savedReels.length;
        setState(() {
          savedReels.removeWhere((reel) => reel['reelId'] == reelId);
        });
        print("📊 Removed from local list. Before: $beforeCount, After: ${savedReels.length}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from saved'), backgroundColor: Colors.green),
        );
        print("✅ Snackbar shown: 'Removed from saved'");
      } else {
        print("❌ Failed to remove saved reel. Status: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove'), backgroundColor: Colors.red),
        );
        print("❌ Snackbar shown: 'Failed to remove'");
      }
    } catch (e) {
      print("🔥 Exception in _removeSavedReel: $e");
      print("🔥 Stack trace: ${StackTrace.current}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error removing saved reel'), backgroundColor: Colors.red),
      );
    }
  }

  void _navigateToReelPlayer(Map<String, dynamic> reel) {
    print("🎬 _navigateToReelPlayer called for reel: ${reel['title']}");
    print("   - ReelId: ${reel['reelId']}");
    print("   - VideoUrl: ${reel['videoUrl']}");

    Navigator.pop(context);
    print("👈 Navigated back to previous screen");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playing: ${reel['title']}'), backgroundColor: AppColors.primaryOrange),
    );
    print("🍿 Snackbar shown: 'Playing: ${reel['title']}'");
  }

  void _showDeleteAllDialog() {
    print("🗑️ _showDeleteAllDialog called");

    showDialog(
      context: context,
      builder: (context) {
        print("📱 Delete All Dialog shown");
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Delete All', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to remove all saved reels?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                print("❌ User cancelled delete all operation");
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                print("✅ User confirmed delete all operation");
                Navigator.pop(context);
                print("📢 TODO: Implement delete all API call");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon'), backgroundColor: AppColors.primaryOrange),
                );
              },
              child: const Text('Delete All', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("🎨 Building SavedReelsScreen UI");
    print("   - loading: $loading");
    print("   - savedReels count: ${savedReels.length}");
    print("   - errorMessage: $errorMessage");

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () {
            print("👈 Back button pressed");
            Navigator.pop(context);
          },
        ),
        title: const Text('Saved Reels', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          if (savedReels.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              onPressed: () {
                print("🗑️ Delete all button pressed");
                _showDeleteAllDialog();
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border_rounded, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(errorMessage!, style: TextStyle(color: Colors.white.withOpacity(0.3))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("🔄 Retry button pressed");
                _fetchSavedReels();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      )
          : savedReels.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border_rounded, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text("No saved reels yet", style: TextStyle(color: Colors.white.withOpacity(0.3))),
            const SizedBox(height: 8),
            Text(
              "Tap the bookmark icon on reels to save them",
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
            ),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: savedReels.length,
        itemBuilder: (context, index) {
          final reel = savedReels[index];
          print("🎬 Building grid item #$index: ${reel['title']}");

          return GestureDetector(
            onTap: () {
              print("🎯 Grid item #$index tapped: ${reel['title']}");
              _navigateToReelPlayer(reel);
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: reel['thumbnail'] != null && reel['thumbnail'].isNotEmpty
                          ? Image.network(
                        reel['thumbnail'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          print("🖼️ Loading thumbnail for: ${reel['title']}");
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryOrange,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print("❌ Failed to load thumbnail for: ${reel['title']}");
                          print("   Error: $error");
                          return Container(
                            color: Colors.grey[900],
                            child: const Icon(Icons.video_library, color: Colors.white24, size: 40),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.play_circle_outline, color: Colors.white24, size: 40),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reel['title'] ?? 'Untitled',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                reel['type'] ?? 'Reel',
                                style: const TextStyle(color: AppColors.primaryOrange, fontSize: 9),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.bookmark, color: AppColors.primaryOrange, size: 18),
                              onPressed: () {
                                print("🗑️ Remove button pressed for reel: ${reel['title']}");
                                _removeSavedReel(reel['reelId']);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}