import 'package:flutter/material.dart';

import '../model/progress_model.dart';

class ProgressViewModel extends ChangeNotifier {
  final _data = ProgressData(
    overallProgress: 0.72,
    conceptsLearned: 248,
    totalConcepts: 450,
    reelsWatched: 312,
    totalReels: 600,
    mockTests: 12,
    accuracy: 81,
  );

  ProgressData get data => _data;
}