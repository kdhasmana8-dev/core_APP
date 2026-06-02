import 'package:flutter/material.dart';

// Robust Parameter Model for incoming test data navigation matrix
class TestResultData {
  final double totalScore;
  final double maxPossibleScore;
  final int totalQuestionsInTest;
  final int questionsAttempted;
  final int correctAnswers;
  final Duration timeTaken;

  // Subject wise deep statistics metrics
  final Map<String, SubjectInsight> subjectMetrics;

  TestResultData({
    required this.totalScore,
    required this.maxPossibleScore,
    required this.totalQuestionsInTest,
    required this.questionsAttempted,
    required this.correctAnswers,
    required this.timeTaken,
    required this.subjectMetrics,
  });

  double get accuracyPercentage {
    if (questionsAttempted == 0) return 0.0;
    return (correctAnswers / questionsAttempted) * 100;
  }
}

class SubjectInsight {
  final double accuracy;
  final String averageTimePerQuestion;

  SubjectInsight({
    required this.accuracy,
    required this.averageTimePerQuestion,
  });
}

class ResultDashboardScreen extends StatelessWidget {

  final dynamic resultData;

  const ResultDashboardScreen({
    super.key,
    required this.resultData,
  });

  @override
  Widget build(BuildContext context) {

    final analysis = resultData['analysis'] ?? {};

    final leaderboard =
        resultData['leaderboard'] ?? [];

    final subjectWise =
        resultData['subjectWise'] ?? [];

    // ================= SAFE DATA =================

    double score =
        double.tryParse(
          analysis['score'].toString(),
        ) ??
            0.0;

    int correct =
        int.tryParse(
          analysis['correct'].toString(),
        ) ??
            0;

    int wrong =
        int.tryParse(
          analysis['wrong'].toString(),
        ) ??
            0;

    int skipped =
        int.tryParse(
          analysis['skipped'].toString(),
        ) ??
            0;

    int attempted =
        int.tryParse(
          analysis['attempted'].toString(),
        ) ??
            0;

    int totalQuestions =
        int.tryParse(
          analysis['totalQuestions'].toString(),
        ) ??
            0;

    double accuracy =
        double.tryParse(
          analysis['accuracy'].toString(),
        ) ??
            0.0;

    String timeTaken =
        analysis['timeTaken']?.toString() ??
            "0m";

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(

        backgroundColor: Colors.black,

        elevation: 0,

        title: const Text(

          "Result Dashboard",

          style: TextStyle(

            color: Colors.white,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // ================= SCORE CARD =================

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: const Color(0xFF111111),

                borderRadius:
                BorderRadius.circular(20),

                border: Border.all(

                  color: Colors.orange
                      .withOpacity(0.3),
                ),
              ),

              child: Column(

                children: [

                  const Icon(

                    Icons.emoji_events,

                    color: Colors.orange,

                    size: 40,
                  ),

                  const SizedBox(height: 12),

                  Text(

                    score.toString(),

                    style: const TextStyle(

                      color: Colors.white,

                      fontSize: 42,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(

                    "Your Score",

                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= STATS =================

            Row(

              children: [

                Expanded(

                  child: _metricCard(

                    "Correct",

                    "$correct",

                    Colors.green,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(

                  child: _metricCard(

                    "Wrong",

                    "$wrong",

                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(

              children: [

                Expanded(

                  child: _metricCard(

                    "Skipped",

                    "$skipped",

                    Colors.orange,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(

                  child: _metricCard(

                    "Accuracy",

                    "${accuracy.toStringAsFixed(1)}%",

                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(

              children: [

                Expanded(

                  child: _metricCard(

                    "Attempted",

                    "$attempted/$totalQuestions",

                    Colors.purple,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(

                  child: _metricCard(

                    "Time",

                    timeTaken,

                    Colors.teal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ================= SUBJECT WISE =================

            const Text(

              "Subject Wise Analysis",

              style: TextStyle(

                color: Colors.white,

                fontSize: 20,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            if (subjectWise.isEmpty)

              const Text(

                "No Subject Data",

                style: TextStyle(
                  color: Colors.white54,
                ),
              ),

            ...subjectWise.map<Widget>((subject) {

              return Container(

                margin:
                const EdgeInsets.only(
                  bottom: 12,
                ),

                padding:
                const EdgeInsets.all(16),

                decoration: BoxDecoration(

                  color: const Color(0xFF111111),

                  borderRadius:
                  BorderRadius.circular(16),
                ),

                child: Row(

                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

                  children: [

                    Text(

                      subject['subject']
                          ?.toString() ??
                          "",

                      style: const TextStyle(

                        color: Colors.white,

                        fontSize: 16,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.end,

                      children: [

                        Text(

                          "Accuracy: ${subject['accuracy'] ?? 0}%",

                          style: const TextStyle(
                            color: Colors.green,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(

                          "Correct: ${subject['correct'] ?? 0}",

                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 30),

            // ================= LEADERBOARD =================

            const Text(

              "Leaderboard",

              style: TextStyle(

                color: Colors.white,

                fontSize: 20,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            if (leaderboard.isEmpty)

              const Text(

                "No Leaderboard Data",

                style: TextStyle(
                  color: Colors.white54,
                ),
              ),

            ...leaderboard.map<Widget>((user) {

              return Container(

                margin:
                const EdgeInsets.only(
                  bottom: 10,
                ),

                padding:
                const EdgeInsets.all(14),

                decoration: BoxDecoration(

                  color: const Color(0xFF111111),

                  borderRadius:
                  BorderRadius.circular(16),
                ),

                child: Row(

                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

                  children: [

                    Row(

                      children: [

                        CircleAvatar(

                          backgroundColor:
                          Colors.orange,

                          child: Text(

                            "${user['rank'] ?? 0}",

                            style:
                            const TextStyle(
                              color:
                              Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Column(

                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Text(

                              user['name']
                                  ?.toString() ??
                                  "",

                              style:
                              const TextStyle(

                                color:
                                Colors.white,

                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(

                              "Score: ${user['score'] ?? 0}",

                              style:
                              const TextStyle(
                                color:
                                Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Text(

                      "${user['accuracy'] ?? 0}%",

                      style: const TextStyle(

                        color: Colors.green,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(
      String title,
      String value,
      Color color,
      ) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: const Color(0xFF111111),

        borderRadius:
        BorderRadius.circular(16),

        border: Border.all(

          color: color.withOpacity(0.3),
        ),
      ),

      child: Column(

        children: [

          Text(

            title,

            style: TextStyle(

              color: color,

              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          Text(

            value,

            style: const TextStyle(

              color: Colors.white,

              fontSize: 22,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
//
// // Robust Parameter Model for incoming test data navigation matrix
// class TestResultData {
//   final double totalScore;
//   final double maxPossibleScore;
//   final int totalQuestionsInTest;
//   final int questionsAttempted;
//   final int correctAnswers;
//   final Duration timeTaken;
//
//   // Subject wise deep statistics metrics
//   final Map<String, SubjectInsight> subjectMetrics;
//
//   TestResultData({
//     required this.totalScore,
//     required this.maxPossibleScore,
//     required this.totalQuestionsInTest,
//     required this.questionsAttempted,
//     required this.correctAnswers,
//     required this.timeTaken,
//     required this.subjectMetrics,
//   });
//
//   double get accuracyPercentage {
//     if (questionsAttempted == 0) return 0.0;
//     return (correctAnswers / questionsAttempted) * 100;
//   }
// }
//
// class SubjectInsight {
//   final double accuracy;
//   final String averageTimePerQuestion;
//
//   SubjectInsight({
//     required this.accuracy,
//     required this.averageTimePerQuestion,
//   });
// }
//
// class ResultDashboardScreen extends StatelessWidget {
//   final TestResultData result;
//   final String studentName;
//   final String examBatchCode;
//
//   const ResultDashboardScreen({
//     super.key,
//     required this.result,
//     this.studentName = "Rahul Kumar",
//     this.examBatchCode = "BIO-QG-01",
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Formatting durations to string format dynamically
//     String timeTakenStr = "${result.timeTaken.inMinutes}m ${result.timeTaken.inSeconds % 60}s";
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Result dashboard",
//           style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 10),
//             _buildStudentHeaderCard(),
//             const SizedBox(height: 20),
//
//             // Top Grid Analytics Layer
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(flex: 5, child: _buildScoreDisplayCard()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   flex: 5,
//                   child: Column(
//                     children: [
//                       _buildMetricSideTile("Accuracy", "${result.accuracyPercentage.toInt()}%", const Color(0xFF0F2D1D), Colors.greenAccent),
//                       const SizedBox(height: 10),
//                       _buildMetricSideTile("Time taken", timeTakenStr, const Color(0xFF2C1A0F), Colors.orangeAccent),
//                       const SizedBox(height: 10),
//                       _buildMetricSideTile("Attempted", "${result.questionsAttempted}/${result.totalQuestionsInTest}", const Color(0xFF1D1435), Colors.purpleAccent),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//
//             const SizedBox(height: 20),
//             _buildDualPerformanceComparisonSection(timeTakenStr),
//             const SizedBox(height: 20),
//             _buildTopperComparisonMetricCard(),
//             const SizedBox(height: 20),
//             _buildLeaderboardSection(),
//             const SizedBox(height: 20),
//             _buildSubjectWiseInsightsSection(),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStudentHeaderCard() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             CircleAvatar(
//               radius: 24,
//               backgroundColor: Colors.indigoAccent.shade400,
//               child: Text(
//                 studentName.isNotEmpty ? studentName.substring(0, 2).toUpperCase() : "RK",
//                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(studentName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 2),
//                 const Text("JEE (Main+Adv) | Smart quiz", style: TextStyle(color: Colors.white38, fontSize: 12)),
//               ],
//             )
//           ],
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(color: const Color(0xFF1A233D), borderRadius: BorderRadius.circular(20)),
//           child: Text(examBatchCode, style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w600)),
//         )
//       ],
//     );
//   }
//
//   Widget _buildScoreDisplayCard() {
//     bool isNegative = result.totalScore < 0;
//     return Container(
//       height: 172,
//       decoration: BoxDecoration(
//         color: const Color(0xFF0B140E),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: isNegative ? Colors.red.withOpacity(0.4) : Colors.green.withOpacity(0.4), width: 1.5),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.emoji_events_outlined, color: isNegative ? Colors.redAccent : Colors.greenAccent, size: 28),
//           const SizedBox(height: 10),
//           Text(
//             "${result.totalScore > 0 ? '+' : ''}${result.totalScore}",
//             style: TextStyle(color: isNegative ? Colors.redAccent : Colors.greenAccent, fontSize: 36, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 2),
//           Text("/ ${result.maxPossibleScore}", style: const TextStyle(color: Colors.white38, fontSize: 14)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMetricSideTile(String title, String stateValue, Color baseColor, Color accentColor) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: baseColor.withOpacity(0.5),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: accentColor.withOpacity(0.15)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: TextStyle(color: accentColor.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500)),
//           const SizedBox(height: 2),
//           Text(stateValue, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDualPerformanceComparisonSection(String userTime) {
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("Your performance", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 15),
//                 _buildPlainRowMetric("Questions attempted", "${result.questionsAttempted}"),
//                 _buildPlainRowMetric("Accuracy", "${result.accuracyPercentage.toInt()}%"),
//                 _buildPlainRowMetric("Time taken", userTime, hideDivider: true),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("Batch average", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 15),
//                 _buildPlainRowMetric("Average score", "3.8"),
//                 _buildPlainRowMetric("Average accuracy", "15%"),
//                 _buildPlainRowMetric("Average time", "5m 38s", hideDivider: true),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPlainRowMetric(String title, String value, {bool hideDivider = false}) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(title, style: const TextStyle(color: Colors.white38, fontSize: 12)),
//             Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
//           ],
//         ),
//         if (!hideDivider) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white.withOpacity(0.05), height: 1)),
//       ],
//     );
//   }
//
//   Widget _buildTopperComparisonMetricCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Topper comparison", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 15),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   const CircleAvatar(radius: 18, backgroundColor: Colors.blue, child: Text("AS", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
//                   const SizedBox(width: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Aarav Sharma", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
//                       Text("Rank #1  |  14.0/${result.maxPossibleScore}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
//                     ],
//                   )
//                 ],
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(color: const Color(0xFF2C1D11), borderRadius: BorderRadius.circular(6)),
//                 child: const Text("Topper", style: TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold)),
//               )
//             ],
//           ),
//           const SizedBox(height: 15),
//           Row(
//             children: [
//               _buildMiniCapsuleTag("Attempted 4", const Color(0xFF161F38), Colors.blueAccent),
//               const SizedBox(width: 8),
//               _buildMiniCapsuleTag("Time 7m 00s", const Color(0xFF201633), Colors.purpleAccent),
//               const SizedBox(width: 8),
//               _buildMiniCapsuleTag("Accuracy 34%", const Color(0xFF0F2417), Colors.greenAccent),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildGapComparisonRow("Score gap", "${result.totalScore} vs 14.0"),
//           _buildGapComparisonRow("Time gap", "0m 05s vs 7m 00s"),
//           _buildGapComparisonRow("Accuracy gap", "${result.accuracyPercentage.toInt()}% vs 34%", isLast: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMiniCapsuleTag(String text, Color bg, Color textColors) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
//       child: Text(text, style: TextStyle(color: textColors, fontSize: 12, fontWeight: FontWeight.w600)),
//     );
//   }
//
//   Widget _buildGapComparisonRow(String parameter, String valueComparison, {bool isLast = false}) {
//     return Padding(
//         padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
//     child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//     Text(parameter, style: const TextStyle(color: Colors.white38, fontSize: 13)),
//     Text(valueComparison, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
//     ],
//     ),
//     );
//   }
//
//   EdgeInsets pastures(double bottom) => EdgeInsets.only(bottom: bottom);
//
//   Widget _buildLeaderboardSection() {
//     final List<Map<String, dynamic>> leaderboardMockData = [
//       {"rank": "#1", "name": "Aarav Sharma", "initials": "AS", "score": "14.0/36.0", "acc": "34%", "time": "7m 00s", "badge": "Topper", "color": Colors.orangeAccent},
//       {"rank": "#2", "name": "Myra Singh", "initials": "MS", "score": "8.0/36.0", "acc": "22%", "time": "8m 40s", "badge": "Rank", "color": Colors.blueAccent},
//       {"rank": "#3", "name": "Vihaan Patel", "initials": "VP", "score": "3.0/36.0", "acc": "14%", "time": "9m 20s", "badge": "Rank", "color": Colors.blueAccent},
//       {"rank": "#4", "name": "Anaya Verma", "initials": "AV", "score": "0.0/36.0", "acc": "12%", "time": "3m 20s", "badge": "Rank", "color": Colors.blueAccent},
//       {"rank": "#5", "name": "Kabir Mehta", "initials": "KM", "score": "0.0/36.0", "acc": "10%", "time": "5m 20s", "badge": "Rank", "color": Colors.blueAccent},
//     ];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text("Leaderboard", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(color: const Color(0xFF111C30), borderRadius: BorderRadius.circular(12)),
//               child: const Text("6 attempts", style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
//             )
//           ],
//         ),
//         const SizedBox(height: 12),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: leaderboardMockData.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 8),
//           itemBuilder: (context, index) {
//             final user = leaderboardMockData[index];
//             return Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Text(user['rank'], style: TextStyle(color: user['color'], fontWeight: FontWeight.bold, fontSize: 14)),
//                       const SizedBox(width: 12),
//                       CircleAvatar(radius: 16, backgroundColor: Colors.indigo.shade700, child: Text(user['initials'], style: const TextStyle(color: Colors.white, fontSize: 11))),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(user['name'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 2),
//                           Text("${user['score']}  |  ${user['acc']} acc  |  ${user['time']}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
//                         ],
//                       )
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(index == 0 ? "4 Q" : "${4 - index} Q", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
//                       const SizedBox(height: 2),
//                       Text(user['badge'], style: const TextStyle(color: Colors.white38, fontSize: 11)),
//                     ],
//                   )
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSubjectWiseInsightsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Subject-wise insight", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 12),
//         _buildSubjectRowMetricTile("Physics", result.subjectMetrics["Physics"]?.accuracy ?? 0.0, result.subjectMetrics["Physics"]?.averageTimePerQuestion ?? "5m 24s"),
//         const SizedBox(height: 8),
//         _buildSubjectRowMetricTile("Chemistry", result.subjectMetrics["Chemistry"]?.accuracy ?? 0.0, result.subjectMetrics["Chemistry"]?.averageTimePerQuestion ?? "4m 28s"),
//         const SizedBox(height: 8),
//         _buildSubjectRowMetricTile("Biology", result.subjectMetrics["Biology"]?.accuracy ?? 0.0, result.subjectMetrics["Biology"]?.averageTimePerQuestion ?? "3m 40s"),
//       ],
//     );
//   }
//
//   Widget _buildSubjectRowMetricTile(String subject, double accuracy, String timePerQ) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: const Color(0xFF0F0707),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.withOpacity(0.15)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent)),
//               const SizedBox(width: 10),
//               Text(subject, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
//             ],
//           ),
//           Row(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text("${accuracy.toInt()}%", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
//                   const Text("Accuracy", style: TextStyle(color: Colors.white38, fontSize: 10)),
//                 ],
//               ),
//               const SizedBox(width: 24),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(timePerQ, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
//                   const Text("Time/Q", style: TextStyle(color: Colors.white38, fontSize: 10)),
//                 ],
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }