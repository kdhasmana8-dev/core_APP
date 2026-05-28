import 'package:flutter/material.dart';

import '../model/profile_model.dart';


class ProfileViewModel extends ChangeNotifier {
  UserProfile _user = UserProfile(
    name: "Aspirant Name",
    email: "aspirant@study.com",
    rank: "AIR 124",
    testsCompleted: 42,
    hoursLearned: 128,
  );

  UserProfile get user => _user;
}