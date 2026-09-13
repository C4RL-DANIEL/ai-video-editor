/// Content graph models for the AI Video Editor app.
///
/// Models representing relationships between creators, videos, people, and topics.

/// The type of connection between two entities in the content graph.
enum ConnectionType {
  /// Creator appeared in the video.
  creatorOf,

  /// Person mentioned or featured in the video.
  featuredIn,

  /// Topic discussed in the video.
  discusses,

  /// Video references or is related to another video.
  references,

  /// Collaborator relationship between creators.
  collaborates,

  /// Creator follows or is associated with a topic.
  interestedIn,

  /// Generic similarity connection.
  similarTo;

  factory ConnectionType.fromString(String value) {
    return ConnectionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConnectionType.similarTo,
    );
  }

  String toJson() => name;
}

/// A creator/channel in the content graph.
class ContentCreator {
  final String id;
  final String name;
  final String? channelUrl;
  final String? avatarUrl;
  final String? platform;
  final int? subscriberCount;
  final Map<String, dynamic> metadata;

  const ContentCreator({
    required this.id,
    required this.name,
    this.channelUrl,
    this.avatarUrl,
    this.platform,
    this.subscriberCount,
    this.metadata = const {},
  });

  factory ContentCreator.fromJson(Map<String, dynamic> json) {
    return ContentCreator(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      channelUrl: json['channelUrl'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      platform: json['platform'] as String?,
      subscriberCount: json['subscriberCount'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'channelUrl': channelUrl,
      'avatarUrl': avatarUrl,
      'platform': platform,
      'subscriberCount': subscriberCount,
      'metadata': metadata,
    };
  }

  ContentCreator copyWith({
    String? id,
    String? name,
    String? channelUrl,
    String? avatarUrl,
    String? platform,
    int? subscriberCount,
    Map<String, dynamic>? metadata,
    bool clearChannelUrl = false,
    bool clearAvatarUrl = false,
    bool clearPlatform = false,
    bool clearSubscriberCount = false,
  }) {
    return ContentCreator(
      id: id ?? this.id,
      name: name ?? this.name,
      channelUrl: clearChannelUrl ? null : (channelUrl ?? this.channelUrl),
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      platform: clearPlatform ? null : (platform ?? this.platform),
      subscriberCount: clearSubscriberCount
          ? null
          : (subscriberCount ?? this.subscriberCount),
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentCreator &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ContentCreator(id: $id, name: $name)';
}

/// A video entry in the content graph.
class ContentVideo {
  final String id;
  final String title;
  final String? url;
  final String? thumbnailUrl;
  final double? duration;
  final DateTime? publishedAt;
  final String? creatorId;
  final Map<String, dynamic> metadata;

  const ContentVideo({
    required this.id,
    required this.title,
    this.url,
    this.thumbnailUrl,
    this.duration,
    this.publishedAt,
    this.creatorId,
    this.metadata = const {},
  });

  factory ContentVideo.fromJson(Map<String, dynamic> json) {
    return ContentVideo(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      creatorId: json['creatorId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'publishedAt': publishedAt?.toIso8601String(),
      'creatorId': creatorId,
      'metadata': metadata,
    };
  }

  ContentVideo copyWith({
    String? id,
    String? title,
    String? url,
    String? thumbnailUrl,
    double? duration,
    DateTime? publishedAt,
    String? creatorId,
    Map<String, dynamic>? metadata,
    bool clearUrl = false,
    bool clearThumbnailUrl = false,
    bool clearDuration = false,
    bool clearPublishedAt = false,
    bool clearCreatorId = false,
  }) {
    return ContentVideo(
      id: id ?? this.id,
      title: title ?? this.title,
      url: clearUrl ? null : (url ?? this.url),
      thumbnailUrl:
          clearThumbnailUrl ? null : (thumbnailUrl ?? this.thumbnailUrl),
      duration: clearDuration ? null : (duration ?? this.duration),
      publishedAt:
          clearPublishedAt ? null : (publishedAt ?? this.publishedAt),
      creatorId: clearCreatorId ? null : (creatorId ?? this.creatorId),
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentVideo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ContentVideo(id: $id, title: $title)';
}

/// A person referenced in the content graph.
class ContentPerson {
  final String id;
  final String name;
  final String? imageUrl;
  final String? role;
  final Map<String, dynamic> metadata;

  const ContentPerson({
    required this.id,
    required this.name,
    this.imageUrl,
    this.role,
    this.metadata = const {},
  });

  factory ContentPerson.fromJson(Map<String, dynamic> json) {
    return ContentPerson(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      role: json['role'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'role': role,
      'metadata': metadata,
    };
  }

  ContentPerson copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? role,
    Map<String, dynamic>? metadata,
    bool clearImageUrl = false,
    bool clearRole = false,
  }) {
    return ContentPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      role: clearRole ? null : (role ?? this.role),
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentPerson &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ContentPerson(id: $id, name: $name)';
}

/// A topic in the content graph.
class ContentTopic {
  final String id;
  final String name;
  final String? description;
  final int? weight;
  final Map<String, dynamic> metadata;

  const ContentTopic({
    required this.id,
    required this.name,
    this.description,
    this.weight,
    this.metadata = const {},
  });

  factory ContentTopic.fromJson(Map<String, dynamic> json) {
    return ContentTopic(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      weight: json['weight'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'weight': weight,
      'metadata': metadata,
    };
  }

  ContentTopic copyWith({
    String? id,
    String? name,
    String? description,
    int? weight,
    Map<String, dynamic>? metadata,
    bool clearDescription = false,
    bool clearWeight = false,
  }) {
    return ContentTopic(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      weight: clearWeight ? null : (weight ?? this.weight),
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentTopic &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ContentTopic(id: $id, name: $name)';
}

/// A connection between two entities in the content graph.
class ContentConnection {
  final String fromId;
  final String toId;
  final ConnectionType type;
  final double strength; // 0.0 to 1.0

  const ContentConnection({
    required this.fromId,
    required this.toId,
    required this.type,
    this.strength = 1.0,
  });

  factory ContentConnection.fromJson(Map<String, dynamic> json) {
    return ContentConnection(
      fromId: json['fromId'] as String? ?? '',
      toId: json['toId'] as String? ?? '',
      type: json['type'] != null
          ? ConnectionType.fromString(json['type'] as String)
          : ConnectionType.similarTo,
      strength: (json['strength'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromId': fromId,
      'toId': toId,
      'type': type.toJson(),
      'strength': strength,
    };
  }

  ContentConnection copyWith({
    String? fromId,
    String? toId,
    ConnectionType? type,
    double? strength,
  }) {
    return ContentConnection(
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      type: type ?? this.type,
      strength: strength ?? this.strength,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentConnection &&
          runtimeType == other.runtimeType &&
          fromId == other.fromId &&
          toId == other.toId &&
          type == other.type;

  @override
  int get hashCode => Object.hash(fromId, toId, type);

  @override
  String toString() =>
      'ContentConnection(from: $fromId, to: $toId, type: $type, strength: $strength)';
}

/// The full content graph with all entities and their connections.
class ContentGraph {
  final List<ContentCreator> creators;
  final List<ContentVideo> videos;
  final List<ContentPerson> people;
  final List<ContentTopic> topics;
  final List<ContentConnection> connections;

  const ContentGraph({
    this.creators = const [],
    this.videos = const [],
    this.people = const [],
    this.topics = const [],
    this.connections = const [],
  });

  factory ContentGraph.fromJson(Map<String, dynamic> json) {
    return ContentGraph(
      creators: (json['creators'] as List<dynamic>?)
              ?.map((c) => ContentCreator.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((v) => ContentVideo.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      people: (json['people'] as List<dynamic>?)
              ?.map((p) => ContentPerson.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      topics: (json['topics'] as List<dynamic>?)
              ?.map((t) => ContentTopic.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      connections: (json['connections'] as List<dynamic>?)
              ?.map((c) =>
                  ContentConnection.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creators': creators.map((c) => c.toJson()).toList(),
      'videos': videos.map((v) => v.toJson()).toList(),
      'people': people.map((p) => p.toJson()).toList(),
      'topics': topics.map((t) => t.toJson()).toList(),
      'connections': connections.map((c) => c.toJson()).toList(),
    };
  }

  ContentGraph copyWith({
    List<ContentCreator>? creators,
    List<ContentVideo>? videos,
    List<ContentPerson>? people,
    List<ContentTopic>? topics,
    List<ContentConnection>? connections,
  }) {
    return ContentGraph(
      creators: creators ?? this.creators,
      videos: videos ?? this.videos,
      people: people ?? this.people,
      topics: topics ?? this.topics,
      connections: connections ?? this.connections,
    );
  }

  /// All connections from a specific entity.
  List<ContentConnection> connectionsFrom(String entityId) {
    return connections.where((c) => c.fromId == entityId).toList();
  }

  /// All connections to a specific entity.
  List<ContentConnection> connectionsTo(String entityId) {
    return connections.where((c) => c.toId == entityId).toList();
  }

  /// All connections involving a specific entity (either direction).
  List<ContentConnection> connectionsFor(String entityId) {
    return connections
        .where((c) => c.fromId == entityId || c.toId == entityId)
        .toList();
  }

  /// Find a creator by ID.
  ContentCreator? creatorById(String id) {
    try {
      return creators.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Find a video by ID.
  ContentVideo? videoById(String id) {
    try {
      return videos.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Find a person by ID.
  ContentPerson? personById(String id) {
    try {
      return people.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Find a topic by ID.
  ContentTopic? topicById(String id) {
    try {
      return topics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() =>
      'ContentGraph(creators: ${creators.length}, videos: ${videos.length}, people: ${people.length}, topics: ${topics.length}, connections: ${connections.length})';
}
