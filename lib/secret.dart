class Secret {
  static final production = "pcist-backend-21023948f2fe.herokuapp.com";
  static final development = "192.168.0.103:4000";
  static final siteLink = development;
}

class LoggedInUserData {
  static String? id;
  static String? classroll;
  static String? email;
  static String? verificationCode;
  static bool isEmailVerified = false;
  static String? forgotPasswordCode;
  static String? phone;
  static String? profileImage;
  static String? name;
  static String? gender;
  static String? tshirt;
  static int? batch;
  static String? dept;
  static int? role;
  static bool membership = false;
  static String? cfhandle;
  static String? atchandle;
  static String? cchandle;
  static List<String> badges = [];
  static List<String> certificates = [];
}

class Event {
  String? id;
  String? eventName;
  String? eventType;
  DateTime? date;
  DateTime? registrationDeadline;
  String? location;
  String? description;
  List<String> imageUrls = [];
  bool? needMembership;
  List<String> registeredMembers = [];
  List<RegisteredTeam> registeredTeams = [];

  Event({
    required this.id,
    required this.eventName,
    required this.eventType,
    required this.date,
    required this.registrationDeadline,
    required this.description,
    required this.imageUrls,
    required this.location,
    required this.needMembership,
    required this.registeredMembers,
    required this.registeredTeams,
  });

  factory Event.setDataFromJson(Map<String, dynamic> json) {
    final isTeamEvent = json.containsKey('registeredTeams');

    return Event(
      id: json['_id'],
      eventName: json['eventName'],
      eventType: isTeamEvent ? 'team' : 'solo',
      date: DateTime.tryParse(json['date'] ?? ''),
      registrationDeadline: DateTime.tryParse(
        json['registrationDeadline'] ?? '',
      ),
      location: json['location'],
      description: json['description'],
      imageUrls: List<String>.from(
        (json['images'] ?? []).map((image) => image['url']),
      ),
      needMembership: json['needMembership'] ?? false,
      registeredMembers: isTeamEvent
          ? []
          : List<String>.from(
              (json['registeredMembers'] ?? []).map((m) => m['Name']),
            ),
      registeredTeams: isTeamEvent
          ? List<RegisteredTeam>.from(
              (json['registeredTeams'] ?? []).map(
                (teamData) => RegisteredTeam.fromJson(teamData),
              ),
            )
          : [],
    );
  }
}

class RegisteredTeam {
  String teamName;
  List<String> members;

  RegisteredTeam({required this.teamName, required this.members});

  factory RegisteredTeam.fromJson(Map<String, dynamic> json) {
    return RegisteredTeam(
      teamName: json['teamName'],
      members: List<String>.from((json['members'] ?? []).map((m) => m['Name'])),
    );
  }
}



// {
//   "status": true,
//   "message": "User created successfully",
//   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MzQ1ZGUzOGQ4MGI3NzI2ODQwNTBjYiIsImNsYXNzcm9sbCI6MjEwNjMsImVtYWlsIjoiZXhhbXBsZXVzZXIyNEBnbWFpbC5jb20iLCJyb2xlIjoyLCJpYXQiOjE3NDgyNjIzNzF9.HFbndTIkg9r_CKOel5IgirI3ZBIqK_FbHMV8D84gDJQ",
//   "slug": "21063"
// }
















