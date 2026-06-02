import 'dart:convert';
import 'dart:io';
import 'package:core_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<dynamic> downloadedLectures = [];
  bool loading = true;
  String? errorMessage;
  Map<String, DownloadProgress> downloadProgress = {};

  // For tracking downloaded files locally
  List<LocalDownload> localDownloads = [];

  @override
  void initState() {
    super.initState();
    _fetchDownloadedLectures();
    _loadLocalDownloads();
  }

  Future<void> _fetchDownloadedLectures() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("user_token");

      if (token == null) {
        setState(() {
          errorMessage = "Please login to view downloads";
          loading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://core-backend-38rr.onrender.com/api/downloaded-lectures'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['result'] != null) {
          setState(() {
            downloadedLectures = data['result'];
            loading = false;
          });
        } else {
          setState(() {
            errorMessage = "No downloads found";
            loading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to load downloads";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error. Please try again.";
        loading = false;
      });
    }
  }

  Future<void> _loadLocalDownloads() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/Downloads');

      if (await downloadsDir.exists()) {
        final files = downloadsDir.listSync();
        for (var file in files) {
          if (file is File) {
            localDownloads.add(LocalDownload(
              fileName: file.path.split('/').last,
              filePath: file.path,
              size: await file.length(),
            ));
          }
        }
        setState(() {});
      }
    } catch (e) {
      print("Error loading local downloads: $e");
    }
  }

  Future<void> _downloadVideo(Map<String, dynamic> lecture) async {
    // Request storage permission
    PermissionStatus permission = await Permission.storage.request();
    if (!permission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission required for downloads')),
      );
      return;
    }

    String videoUrl = lecture['videoUrl'];
    String fileName = '${lecture['title']}.mp4';
    String reelId = lecture['reelId'];

    setState(() {
      downloadProgress[reelId] = DownloadProgress(progress: 0, status: 'downloading');
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/Downloads');

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      String savePath = '${downloadsDir.path}/$fileName';

      // Using http.Client to download file
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(videoUrl));
      final response = await client.send(request);

      if (response.statusCode == 200) {
        final file = File(savePath);
        final sink = file.openWrite();

        int received = 0;
        final int total = response.contentLength ?? 0;

        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;

          if (total > 0) {
            setState(() {
              downloadProgress[reelId] = DownloadProgress(
                progress: received / total,
                status: 'downloading',
              );
            });
          }
        }

        await sink.close();
        client.close();

        // After successful download, save to API
        await _saveDownloadToApi(lecture, savePath);

        setState(() {
          downloadProgress[reelId] = DownloadProgress(progress: 1, status: 'completed');
        });

        // Add to local downloads list
        localDownloads.add(LocalDownload(
          fileName: fileName,
          filePath: savePath,
          size: await file.length(),
        ));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded: $fileName'), backgroundColor: Colors.green),
        );

        // Refresh the list
        _fetchDownloadedLectures();
      } else {
        throw Exception('Failed to download video');
      }

    } catch (e) {
      setState(() {
        downloadProgress[reelId] = DownloadProgress(progress: 0, status: 'failed');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _saveDownloadToApi(Map<String, dynamic> lecture, String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("user_token");

      if (token == null) return;

      final response = await http.post(
        Uri.parse('https://core-backend-38rr.onrender.com/api/downloaded-lectures'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'reelId': lecture['reelId'],
          'title': lecture['title'],
          'videoUrl': lecture['videoUrl'],
          'thumbnail': lecture['thumbnail'],
          'teacherName': lecture['teacherName'],
          'localPath': filePath,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Saved download to API");
      }
    } catch (e) {
      print("Error saving to API: $e");
    }
  }

  Future<void> _openVideo(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open file: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteDownload(String reelId, String filePath) async {
    try {
      // Delete from API
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("user_token");

      if (token != null) {
        await http.delete(
          Uri.parse('https://core-backend-38rr.onrender.com/api/downloaded-lectures/$reelId'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }

      // Delete local file
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from lists
      setState(() {
        downloadedLectures.removeWhere((lecture) => lecture['reelId'] == reelId);
        localDownloads.removeWhere((download) => download.filePath == filePath);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download removed'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Downloads', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryOrange,
            labelColor: AppColors.primaryOrange,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Online', icon: Icon(Icons.cloud_download)),
              Tab(text: 'Local', icon: Icon(Icons.storage)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Online Downloads Tab
            loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                : errorMessage != null
                ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.white54)))
                : downloadedLectures.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download_for_offline, color: Colors.white24, size: 64),
                  const SizedBox(height: 16),
                  Text("No downloads yet", style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: downloadedLectures.length,
              itemBuilder: (context, index) {
                final lecture = downloadedLectures[index];
                final progress = downloadProgress[lecture['reelId']];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: lecture['thumbnail'] != null
                              ? Image.network(
                            lecture['thumbnail'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[900],
                                child: const Icon(Icons.video_library, color: Colors.white24),
                              );
                            },
                          )
                              : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[900],
                            child: const Icon(Icons.video_library, color: Colors.white24),
                          ),
                        ),
                        title: Text(
                          lecture['title'] ?? 'Untitled',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          lecture['teacherName'] ?? 'Teacher',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        trailing: progress?.status == 'completed'
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow, color: AppColors.primaryOrange),
                              onPressed: () => _openVideo(lecture['localPath'] ?? ''),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _deleteDownload(lecture['reelId'], lecture['localPath'] ?? ''),
                            ),
                          ],
                        )
                            : progress?.status == 'downloading'
                            ? SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: progress?.progress,
                            color: AppColors.primaryOrange,
                          ),
                        )
                            : IconButton(
                          icon: const Icon(Icons.download, color: AppColors.primaryOrange),
                          onPressed: () => _downloadVideo(lecture),
                        ),
                      ),
                      if (progress?.status == 'downloading')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: LinearProgressIndicator(
                            value: progress?.progress,
                            backgroundColor: Colors.white24,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            // Local Downloads Tab
            localDownloads.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, color: Colors.white24, size: 64),
                  const SizedBox(height: 16),
                  Text("No local files found", style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: localDownloads.length,
              itemBuilder: (context, index) {
                final download = localDownloads[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.video_file, color: AppColors.primaryOrange, size: 40),
                    title: Text(download.fileName, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(_formatFileSize(download.size), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow, color: AppColors.primaryOrange),
                          onPressed: () => _openVideo(download.filePath),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _deleteLocalFile(download),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _deleteLocalFile(LocalDownload download) async {
    try {
      final file = File(download.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      setState(() {
        localDownloads.remove(download);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File deleted'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

class DownloadProgress {
  double progress;
  String status;

  DownloadProgress({required this.progress, required this.status});
}

class LocalDownload {
  String fileName;
  String filePath;
  int size;

  LocalDownload({required this.fileName, required this.filePath, required this.size});
}

//Bookmarks Screen--------------------------

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> bookmarks = [
      {'title': 'Nernst Equation Tricky Numerical', 'tag': 'Chemistry', 'date': 'Saved on 18 May'},
      {'title': 'Rotational Mechanics Formula Sheet', 'tag': 'Physics', 'date': 'Saved on 12 May'},
      {'title': 'Complex Numbers Conjugate Properties', 'tag': 'Mathematics', 'date': 'Saved on 04 May'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bookmarks', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookmarks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final mark = bookmarks[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          mark['tag'],
                          style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        mark['title'],
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Text(mark['date'], style: const TextStyle(color: Colors.white30, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark, color: Colors.redAccent, size: 22),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

//Refer Earn Screen--------------------------

class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Refer & Earn', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Gift Custom Vector/Icon Layout
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent.withOpacity(0.15), width: 2),
              ),
              child: const Icon(Icons.card_giftcard_rounded, color: Colors.redAccent, size: 72),
            ),
            const SizedBox(height: 32),
            const Text(
              'Invite Friends & Earn Rewards',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Share your code with fellow aspirants. When they join premium mock series, you both get 500 reward tokens!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 40),

            // Referral Code Block Card View
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('YOUR REFERRAL CODE', style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 0.5)),
                      SizedBox(height: 6),
                      Text('ASPIRANT500', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied to clipboard!'), backgroundColor: Colors.redAccent),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, color: Colors.redAccent, size: 16),
                    label: const Text('Copy', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Native Share Button Action Box
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Share Invite Link', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//Settings Screen--------------------------


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _buildSettingsHeader('App Settings'),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 22),
            title: const Text('Push Notifications', style: TextStyle(color: Colors.white, fontSize: 14)),
            trailing: Switch(
              value: _isNotificationEnabled,
              onChanged: (val) {
                setState(() => _isNotificationEnabled = val);
              },
              activeThumbColor: Colors.redAccent,
              activeTrackColor: Colors.redAccent.withOpacity(0.3),
              inactiveTrackColor: Colors.white10,
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          _buildClickableSettingItem(Icons.translate, 'App Language', trailingText: 'English'),

          _buildSettingsHeader('Account Control'),
          _buildClickableSettingItem(Icons.lock_outline_rounded, 'Privacy Policy'),
          const Divider(color: Colors.white10, height: 1),
          _buildClickableSettingItem(Icons.gavel_outlined, 'Terms of Service'),
          const Divider(color: Colors.white10, height: 1),
          _buildClickableSettingItem(Icons.info_outline_rounded, 'App Version', trailingText: 'v2.4.1'),
        ],
      ),
    );
  }

  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8, right: 20),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildClickableSettingItem(IconData icon, String title, {String? trailingText}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: trailingText != null
          ? Text(trailingText, style: const TextStyle(color: Colors.white30, fontSize: 13))
          : const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
      onTap: () {},
    );
  }
}

//Notes-----------------


class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock dataset for student chapter notes
    final List<Map<String, dynamic>> subjectNotes = [
      {'subject': 'Physics', 'topic': 'Rotational Dynamics', 'chapters': '4 PDFs • 12 Handwritten Pages', 'date': 'Updated 2 days ago'},
      {'subject': 'Chemistry', 'topic': 'Organic Coordination Compounds', 'chapters': '2 PDFs • 8 Revision Slides', 'date': 'Updated 1 week ago'},
      {'subject': 'Mathematics', 'topic': 'Probability & Permutations', 'chapters': '5 PDFs • 20 Practice Sets', 'date': 'Updated 3 weeks ago'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Notes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_outlined, color: Colors.redAccent),
            onPressed: () {},
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: subjectNotes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final note = subjectNotes[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              note['subject'],
                              style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(note['date'], style: const TextStyle(color: Colors.white30, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        note['topic'],
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        note['chapters'],
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
                  onPressed: () {},
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
//Help and support screen------------------


class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connect Cards Grid
            const Text('Contact Us', style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildContactCard(Icons.chat_bubble_outline_rounded, 'Chat Support', 'Avg response: 5 mins'),
                const SizedBox(width: 12),
                _buildContactCard(Icons.mail_outline_rounded, 'Email Us', 'support@platform.com'),
              ],
            ),

            const SizedBox(height: 28),
            const Text('Frequently Asked Questions', style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
            const SizedBox(height: 12),

            // FAQ Accordions list
            _buildFaqExpansionTile('How to download lectures offline?', 'Aap kisi bhi lecture ke niche diye gaye download icon par click karke use offline save kar sakte hain, jo direct "Downloads" section me show hoga.'),
            _buildFaqExpansionTile('My mock test stats are not loading.', 'Network refresh karein ya profile section me jaakar data sync par tap karein. Agar samasya bani rahe toh direct chat par report karein.'),
            _buildFaqExpansionTile('Can I access notes on multiple devices?', 'Haan, aap ek waqt me maximum do devices me ek hi credentials se login karke smoothly access kar sakte hain.'),
            _buildFaqExpansionTile('How does the referral bonus token work?', 'Jaise hi aapka friend aapke code se sign up karke active batch subscription lega, dono ke dashboard me tokens credit ho jayenge.'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String actionInfo) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.redAccent, size: 24),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(actionInfo, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqExpansionTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.redAccent,
          collapsedIconColor: Colors.white38,
          title: Text(question, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                answer,
                style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Privacy Policy----------


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color primaryOrange = Color(0xFFFF7A00);
  static const Color background = Color(0xFF0F172A);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF8A00),
                    Color(0xFFFF5E00),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.privacy_tip_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                  SizedBox(height: 14),
                  Text(
                    "Your Privacy Matters",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "At Core App, we value your trust and are committed to protecting your personal information.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _policyTile(
              Icons.person_outline,
              "Information We Collect",
              "We may collect your name, email address, profile information, educational preferences, learning history, saved content, and app activity.",
            ),

            _policyTile(
              Icons.analytics_outlined,
              "How We Use Information",
              "To personalize your learning experience, recommend relevant content, improve performance, and enhance educational outcomes.",
            ),

            _policyTile(
              Icons.lock_outline,
              "Data Security",
              "We implement industry-standard security measures including secure authentication, encrypted communication, and restricted access controls.",
            ),

            _policyTile(
              Icons.play_circle_outline,
              "Learning Progress",
              "Your watch history, progress tracking, and completed content may be stored to help you continue learning seamlessly.",
            ),

            _policyTile(
              Icons.share_outlined,
              "Information Sharing",
              "We do not sell personal information. Data is only shared when necessary for service delivery, legal compliance, or trusted integrations.",
            ),

            _policyTile(
              Icons.child_care_outlined,
              "Children's Privacy",
              "Students should use Core App in accordance with applicable age requirements and parental guidance where appropriate.",
            ),

            _policyTile(
              Icons.update_outlined,
              "Policy Updates",
              "This Privacy Policy may be updated periodically. Continued use of the platform indicates acceptance of updated policies.",
            ),

            const SizedBox(height: 24),

            /// CONTACT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryOrange.withOpacity(.3),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.support_agent_rounded,
                    color: primaryOrange,
                    size: 40,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Need Help?",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "For privacy related concerns contact us:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textSecondary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "support@coreapp.com",
                    style: TextStyle(
                      color: primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Center(
              child: Text(
                "Last Updated: May 2026",
                style: TextStyle(
                  color: textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _policyTile(
      IconData icon,
      String title,
      String description,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primaryOrange,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: textSecondary,
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


//Terms and Condition------------


class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color primaryOrange = Color(0xFFFF7A00);
  static const Color background = Color(0xFF0F172A);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF8A00),
                    Color(0xFFFF5E00),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.gavel_rounded,
                    color: Colors.white,
                    size: 55,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Core App Terms & Conditions",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please read these terms carefully before using our services.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _section(
              "1. Acceptance of Terms",
              "By accessing or using Core App, you agree to be bound by these Terms & Conditions. If you do not agree with any part of these terms, please discontinue use of the application.",
            ),

            _section(
              "2. Educational Purpose",
              "Core App provides educational content including videos, reels, study materials, tests, notes, PYQs, mock tests, and learning resources. The content is intended for educational and informational purposes only.",
            ),

            _section(
              "3. User Accounts",
              "Users are responsible for maintaining the confidentiality of their account credentials. Any activity performed through your account will be considered your responsibility.",
            ),

            _section(
              "4. User Conduct",
              "Users must not misuse the platform, upload harmful content, attempt unauthorized access, distribute spam, engage in fraudulent activity, or interfere with application services.",
            ),

            _section(
              "5. Intellectual Property Rights",
              "All content available on Core App including videos, notes, graphics, logos, designs, courses, and educational resources remains the property of Core App or its licensors and is protected by intellectual property laws.",
            ),

            _section(
              "6. Payments & Subscriptions",
              "Premium courses, subscriptions, and paid features may require payment. Pricing, billing, refunds, and subscription details are governed by policies displayed within the application.",
            ),

            _section(
              "7. Third-Party Services",
              "Core App may integrate with third-party platforms and services. We are not responsible for the content, security practices, or policies of those external services.",
            ),

            _section(
              "8. Limitation of Liability",
              "Core App shall not be liable for any direct, indirect, incidental, special, or consequential damages resulting from the use or inability to use the platform or its educational content.",
            ),

            _section(
              "9. Account Suspension & Termination",
              "We reserve the right to suspend, restrict, or terminate user accounts that violate these Terms & Conditions, misuse services, or engage in fraudulent activities.",
            ),

            _section(
              "10. Availability of Services",
              "While we strive to provide uninterrupted access, Core App does not guarantee continuous availability of services and may perform maintenance, updates, or modifications at any time.",
            ),

            _section(
              "11. Privacy Protection",
              "Your use of Core App is also governed by our Privacy Policy. By using the platform, you consent to the collection and use of information as described therein.",
            ),

            _section(
              "12. Changes to Terms",
              "Core App may revise these Terms & Conditions periodically. Continued use of the application after changes constitutes acceptance of the updated terms.",
            ),

            _section(
              "13. Contact Information",
              "For any questions, concerns, or legal inquiries regarding these Terms & Conditions, please contact our support team through the official support channels.",
            ),

            const SizedBox(height: 24),

            /// AGREEMENT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryOrange.withOpacity(.30),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: primaryOrange,
                    size: 42,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "By continuing to use Core App, you acknowledge that you have read, understood, and agreed to these Terms & Conditions.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textSecondary,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Last Updated: May 2026",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Center(
              child: Text(
                "© 2026 Core App. All Rights Reserved.",
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _section(
      String title,
      String content,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
//Saved Reels Screen------------------


class SavedReelsScreen extends StatelessWidget {
  const SavedReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for saved reels
    final List<Map<String, String>> savedReels = [
      {'title': 'JEE Physics: Kinematics Trick', 'teacher': 'Lokesh Muwel', 'thumb': 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400'},
      {'title': 'Chemical Bonding Short Notes', 'teacher': 'Alakh Sir', 'thumb': 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=400'},
      {'title': 'Definite Integration', 'teacher': 'Maths Expert', 'thumb': 'https://images.unsplash.com/photo-1596496181878-305d78572710?w=400'},
      {'title': 'Simple Harmonic Motion', 'teacher': 'Physics Wallah', 'thumb': 'https://images.unsplash.com/photo-1612831455740-a2f013d33194?w=400'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Saved Reels', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: savedReels.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border_rounded, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text("No saved reels yet", style: TextStyle(color: Colors.white.withOpacity(0.3))),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75, // Reel shape aspect ratio
        ),
        itemCount: savedReels.length,
        itemBuilder: (context, index) {
          final reel = savedReels[index];
          return Container(
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
                    child: Image.network(
                      reel['thumb']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reel['title']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reel['teacher']!,
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
