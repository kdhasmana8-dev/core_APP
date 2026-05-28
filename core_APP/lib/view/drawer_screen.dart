import 'package:flutter/material.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data matching JEE context
    final List<Map<String, String>> downloadedLectures = [
      {'title': 'Electrostatics - Lecture 04', 'sub': 'Physics • 342 MB • MP4'},
      {'title': 'Chemical Bonding Short Notes', 'sub': 'Chemistry • 4.5 MB • PDF'},
      {'title': 'Definite Integration Core Problems', 'sub': 'Mathematics • 180 MB • MP4'},
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
        title: const Text('Downloads', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            onPressed: () {},
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: downloadedLectures.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_for_offline_outlined, color: Colors.white.withOpacity(0.2), size: 64),
            const SizedBox(height: 16),
            const Text("No offline downloads found", style: TextStyle(color: Colors.white30, fontSize: 14)),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: downloadedLectures.length,
        separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
        itemBuilder: (context, index) {
          final item = downloadedLectures[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item['title']!.contains('PDF') ? Icons.picture_as_pdf_outlined : Icons.play_circle_outline,
                color: Colors.redAccent,
                size: 22,
              ),
            ),
            title: Text(item['title']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(item['sub']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}

//Bookmarks Screen--------------------------

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

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
  const ReferEarnScreen({Key? key}) : super(key: key);

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
  const SettingsScreen({Key? key}) : super(key: key);

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
              activeColor: Colors.redAccent,
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
  const NotesScreen({Key? key}) : super(key: key);

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
  const HelpSupportScreen({Key? key}) : super(key: key);

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