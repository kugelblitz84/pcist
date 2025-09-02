class Secret {
  static final production = "pcist-backend-21023948f2fe.herokuapp.com";
  static final development = "192.168.0.103:4000";
  static final siteLink = production; // Change to development for local testing
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

class RegisteredMember {
  String? userId;
  int? classroll;
  String? name;
  bool? paymentStatus;

  RegisteredMember({
    this.userId,
    this.classroll,
    this.name,
    this.paymentStatus,
  });

  factory RegisteredMember.fromJson(Map<String, dynamic> json) {
    return RegisteredMember(
      userId: json['userId'],
      classroll: json['classroll'],
      name: json['Name'],
      paymentStatus: json['paymentStatus'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'classroll': classroll,
      'Name': name,
      'paymentStatus': paymentStatus,
    };
  }
}

class RegisteredTeam {
  String teamName;
  List<RegisteredMember> members;

  RegisteredTeam({required this.teamName, required this.members});

  factory RegisteredTeam.fromJson(Map<String, dynamic> json) {
    return RegisteredTeam(
      teamName: json['teamName'] ?? '',
      members: List<RegisteredMember>.from(
        (json['members'] ?? []).map((m) => RegisteredMember.fromJson(m)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamName': teamName,
      'members': members.map((m) => m.toJson()).toList(),
    };
  }
}

class EventImage {
  String url;
  String publicId;

  EventImage({required this.url, required this.publicId});

  factory EventImage.fromJson(Map<String, dynamic> json) {
    return EventImage(url: json['url'] ?? '', publicId: json['publicId'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'publicId': publicId};
  }
}

class Event {
  String? id;
  String? eventName;
  String? eventType;
  DateTime? date;
  DateTime? registrationDeadline;
  String? location;
  String? description;
  List<EventImage> images = [];
  bool needMembership;
  List<RegisteredMember> registeredMembers = [];
  List<RegisteredTeam> registeredTeams = [];

  Event({
    this.id,
    this.eventName,
    this.eventType,
    this.date,
    this.registrationDeadline,
    this.location,
    this.description,
    this.images = const [],
    this.needMembership = false,
    this.registeredMembers = const [],
    this.registeredTeams = const [],
  });

  // Helper getter for backward compatibility
  List<String> get imageUrls => images.map((img) => img.url).toList();

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
      images: List<EventImage>.from(
        (json['images'] ?? []).map((image) => EventImage.fromJson(image)),
      ),
      needMembership: json['needMembership'] ?? false,
      registeredMembers: isTeamEvent
          ? []
          : List<RegisteredMember>.from(
              (json['registeredMembers'] ?? []).map(
                (m) => RegisteredMember.fromJson(m),
              ),
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

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'eventName': eventName,
      'date': date?.toIso8601String(),
      'registrationDeadline': registrationDeadline?.toIso8601String(),
      'location': location,
      'description': description,
      'images': images.map((img) => img.toJson()).toList(),
      'needMembership': needMembership,
      if (eventType == 'solo')
        'registeredMembers': registeredMembers.map((m) => m.toJson()).toList(),
      if (eventType == 'team')
        'registeredTeams': registeredTeams.map((t) => t.toJson()).toList(),
    };
  }
}



// {
//   "status": true,
//   "message": "User created successfully",
//   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MzQ1ZGUzOGQ4MGI3NzI2ODQwNTBjYiIsImNsYXNzcm9sbCI6MjEwNjMsImVtYWlsIjoiZXhhbXBsZXVzZXIyNEBnbWFpbC5jb20iLCJyb2xlIjoyLCJpYXQiOjE3NDgyNjIzNzF9.HFbndTIkg9r_CKOel5IgirI3ZBIqK_FbHMV8D84gDJQ",
//   "slug": "21063"
// }
















