class Secret {
  static final prod = "pcist-backend-21023948f2fe.herokuapp.com";
  static final dev = "192.168.0.102:4000"; //"192.168.0.103:4000";
  static final siteLink = prod; // Change to development for local testing
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
  // New participation tracking
  static List<UserSoloParticipation> myParticipationsSolo = [];
  static List<UserTeamParticipation> myParticipationsTeam = [];
  // Role-Based Access Control fields
  static String title = 'Member'; // GS, JS, OS, Member
  static bool treasurer = false;

  // Helper getters for permissions
  static bool get isAdmin => role == 2;
  static bool get canManageInvoices => isAdmin || treasurer;
  static bool get canManageUsers => isAdmin;

  // Title display helper
  static String get titleFullName {
    switch (title) {
      case 'GS':
        return 'General Secretary';
      case 'JS':
        return 'Joint Secretary';
      case 'OS':
        return 'Organizing Secretary';
      default:
        return 'Member';
    }
  }
}

class UserSoloParticipation {
  String? eventId;
  String? eventName;
  UserSoloParticipation({this.eventId, this.eventName});
  factory UserSoloParticipation.fromJson(Map<String, dynamic> json) {
    return UserSoloParticipation(
      eventId: json['eventId']?.toString(),
      eventName: json['eventName']?.toString(),
    );
  }
  Map<String, dynamic> toJson() => {'eventId': eventId, 'eventName': eventName};
}

class UserTeamParticipation {
  String? eventId;
  String? eventName;
  UserTeamParticipation({this.eventId, this.eventName});
  factory UserTeamParticipation.fromJson(Map<String, dynamic> json) {
    return UserTeamParticipation(
      eventId: json['eventId']?.toString(),
      eventName: json['eventName']?.toString(),
    );
  }
  Map<String, dynamic> toJson() => {'eventId': eventId, 'eventName': eventName};
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

class PadAuthorizer {
  String name;
  String role;

  PadAuthorizer({required this.name, required this.role});

  Map<String, String> toMap() {
    return {'name': name, 'role': role};
  }

  factory PadAuthorizer.fromMap(Map<String, dynamic> map) {
    return PadAuthorizer(name: map['name'] ?? '', role: map['role'] ?? '');
  }
}

class PadStatement {
  final String? id;
  final String? receiverEmail;
  final String? subject;
  final String? statement;
  final List<PadAuthorizer> authorizers;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final String? serial;
  final String? dateStr;
  final bool? sent;
  final String? sentAt;
  final String? downloadedAt;
  final String? createdBy;
  final String? pdfUrl;
  final String? pdfPublicId;
  final String? createdAt;
  final String? updatedAt;

  const PadStatement({
    this.id,
    this.receiverEmail,
    this.subject,
    this.statement,
    List<PadAuthorizer>? authorizers,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.serial,
    this.dateStr,
    this.sent,
    this.sentAt,
    this.downloadedAt,
    this.createdBy,
    this.pdfUrl,
    this.pdfPublicId,
    this.createdAt,
    this.updatedAt,
  }) : authorizers = authorizers ?? const [];

  factory PadStatement.fromMap(Map<String, dynamic> map) {
    final rawAuthorizers = map['authorizers'] as List<dynamic>?;
    return PadStatement(
      id: map['_id']?.toString(),
      receiverEmail: map['receiverEmail']?.toString(),
      subject: map['subject']?.toString(),
      statement: map['statement']?.toString(),
      authorizers: rawAuthorizers == null
          ? const []
          : rawAuthorizers
                .map(
                  (auth) => PadAuthorizer.fromMap(
                    (auth as Map?)?.cast<String, dynamic>() ??
                        <String, dynamic>{},
                  ),
                )
                .where((auth) => auth.name.isNotEmpty || auth.role.isNotEmpty)
                .toList(),
      contactEmail: map['contactEmail']?.toString(),
      contactPhone: map['contactPhone']?.toString(),
      address: map['address']?.toString(),
      serial: map['serial']?.toString(),
      dateStr: map['dateStr']?.toString(),
      sent: map['sent'] as bool?,
      sentAt: map['sentAt']?.toString(),
      downloadedAt: map['downloadedAt']?.toString(),
      createdBy: _resolveCreatedBy(map['createdBy']),
      pdfUrl: map['pdfUrl']?.toString(),
      pdfPublicId: map['pdfPublicId']?.toString(),
      createdAt: map['createdAt']?.toString(),
      updatedAt: map['updatedAt']?.toString(),
    );
  }

  static String? _resolveCreatedBy(dynamic rawCreatedBy) {
    if (rawCreatedBy == null) {
      return null;
    }
    if (rawCreatedBy is String) {
      return rawCreatedBy;
    }
    if (rawCreatedBy is Map) {
      final map = rawCreatedBy.cast<String, dynamic>();
      return map['_id']?.toString() ?? map['id']?.toString();
    }
    return rawCreatedBy.toString();
  }
}

class InvoiceProduct {
  String description;
  int quantity;
  double unitPrice;

  InvoiceProduct({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': totalPrice, // Add the calculated total for backend compatibility
    };
  }

  factory InvoiceProduct.fromMap(Map<String, dynamic> map) {
    return InvoiceProduct(
      description: map['description']?.toString() ?? '',
      quantity: (map['quantity'] is int)
          ? map['quantity']
          : (map['quantity']?.toInt() ?? 0),
      unitPrice: (map['unitPrice'] is double)
          ? map['unitPrice']
          : (map['unitPrice']?.toDouble() ?? 0.0),
    );
  }

  double get totalPrice => quantity * unitPrice;
}

class Invoice {
  String? id;
  String? serial;
  double? grandTotal;
  String authorizerName;
  String authorizerDesignation;
  String? dateStr;
  String? issueDateStr;
  String? generatedDateStr;
  bool? sentViaEmail;
  String? receiverEmail;
  String? downloadedAt;
  String? createdAt;
  String? updatedAt;
  List<InvoiceProduct> products;
  String contactEmail;
  String contactPhone;
  String address;

  Invoice({
    this.id,
    this.serial,
    this.grandTotal,
    required this.authorizerName,
    required this.authorizerDesignation,
    this.dateStr,
    this.issueDateStr,
    this.generatedDateStr,
    this.sentViaEmail,
    this.receiverEmail,
    this.downloadedAt,
    this.createdAt,
    this.updatedAt,
    required this.products,
    required this.contactEmail,
    required this.contactPhone,
    required this.address,
  });

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['_id'],
      serial: map['serial'],
      grandTotal: map['grandTotal']?.toDouble(),
      authorizerName: map['authorizerName'] ?? '',
      authorizerDesignation: map['authorizerDesignation'] ?? '',
      dateStr: map['dateStr'],
      issueDateStr: map['issueDateStr'],
      generatedDateStr: map['generatedDateStr'],
      sentViaEmail: map['sentViaEmail'],
      receiverEmail: map['receiverEmail'],
      downloadedAt: map['downloadedAt'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      products: map['products'] != null
          ? (map['products'] as List<dynamic>)
                .map(
                  (product) =>
                      InvoiceProduct.fromMap(product as Map<String, dynamic>),
                )
                .toList()
          : [],
      contactEmail: map['contactEmail'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      address: map['address'] ?? '',
    );
  }

  double calculateGrandTotal() {
    return products.fold(0.0, (sum, product) => sum + product.totalPrice);
  }
}

// {
//   "status": true,
//   "message": "User created successfully",
//   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MzQ1ZGUzOGQ4MGI3NzI2ODQwNTBjYiIsImNsYXNzcm9sbCI6MjEwNjMsImVtYWlsIjoiZXhhbXBsZXVzZXIyNEBnbWFpbC5jb20iLCJyb2xlIjoyLCJpYXQiOjE3NDgyNjIzNzF9.HFbndTIkg9r_CKOel5IgirI3ZBIqK_FbHMV8D84gDJQ",
//   "slug": "21063"
// }
