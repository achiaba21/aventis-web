import 'package:web_flutter/util/function.dart';

class GpsResponse {
  List<double>? bbox;
  List<Routes>? routes;
  Metadata? metadata;

  GpsResponse({this.bbox, this.routes, this.metadata});

  GpsResponse.fromJson(Map<String, dynamic> json) {
    bbox = json['bbox'].cast<double>();
    if (json['routes'] != null) {
      routes = <Routes>[];
      json['routes'].forEach((v) {
        routes!.add(Routes.fromJson(v));
      });
    }
    metadata =
        json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bbox'] = bbox;
    if (routes != null) {
      data['routes'] = routes!.map((v) => v.toJson()).toList();
    }
    if (metadata != null) {
      data['metadata'] = metadata!.toJson();
    }
    return data;
  }
}

class Routes {
  Summary? summary;
  List<Segments>? segments;
  List<double>? bbox;
  String? geometry;
  List<int>? wayPoints;

  Routes({
    this.summary,
    this.segments,
    this.bbox,
    this.geometry,
    this.wayPoints,
  });

  Routes.fromJson(Map<String, dynamic> json) {
    summary =
        json['summary'] != null ? Summary.fromJson(json['summary']) : null;
    if (json['segments'] != null) {
      segments = <Segments>[];
      json['segments'].forEach((v) {
        segments!.add(Segments.fromJson(v));
      });
    }
    bbox = json['bbox'].cast<double>();
    geometry = json['geometry'];
    wayPoints = json['way_points'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (segments != null) {
      data['segments'] = segments!.map((v) => v.toJson()).toList();
    }
    data['bbox'] = bbox;
    data['geometry'] = geometry;
    data['way_points'] = wayPoints;
    return data;
  }
}

class Summary {
  double? distance;
  double? duration;

  Summary({this.distance, this.duration});

  Summary.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['duration'] = duration;
    return data;
  }
}

class Segments {
  double? distance;
  double? duration;
  List<Steps>? steps;

  Segments({this.distance, this.duration, this.steps});

  Segments.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    duration = json['duration'];
    if (json['steps'] != null) {
      steps = <Steps>[];
      json['steps'].forEach((v) {
        steps!.add(Steps.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['duration'] = duration;
    if (steps != null) {
      data['steps'] = steps!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Steps {
  double? distance;
  double? duration;
  int? type;
  String? instruction;
  String? name;
  List<int>? wayPoints;
  int? exitNumber;

  Steps({
    this.distance,
    this.duration,
    this.type,
    this.instruction,
    this.name,
    this.wayPoints,
    this.exitNumber,
  });

  Steps.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    duration = json['duration'];
    type = json['type'];
    instruction = json['instruction'];
    name = json['name'];
    wayPoints = json['way_points'].cast<int>();
    exitNumber = json['exit_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['duration'] = duration;
    data['type'] = type;
    data['instruction'] = instruction;
    data['name'] = name;
    data['way_points'] = wayPoints;
    data['exit_number'] = exitNumber;
    return data;
  }
}

class Metadata {
  String? attribution;
  String? service;
  int? timestamp;
  Query? query;
  Engine? engine;

  Metadata({
    this.attribution,
    this.service,
    this.timestamp,
    this.query,
    this.engine,
  });

  Metadata.fromJson(Map<String, dynamic> json) {
    attribution = json['attribution'];
    service = json['service'];
    timestamp = json['timestamp'];
    query = json['query'] != null ? Query.fromJson(json['query']) : null;
    engine = json['engine'] != null ? Engine.fromJson(json['engine']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attribution'] = attribution;
    data['service'] = service;
    data['timestamp'] = timestamp;
    if (query != null) {
      data['query'] = query!.toJson();
    }
    if (engine != null) {
      data['engine'] = engine!.toJson();
    }
    return data;
  }
}

class Query {
  List<List<dynamic>>? coordinates;
  String? profile;
  String? profileName;
  String? format;

  Query({this.coordinates, this.profile, this.profileName, this.format});

  Query.fromJson(Map<String, dynamic> json) {
    if (json['coordinates'] != null) {
      coordinates = [];
      json['coordinates'].forEach((v) {
        deboger([v, v.runtimeType]);

        coordinates!.add(v);
      });
    }
    profile = json['profile'];
    profileName = json['profileName'];
    format = json['format'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (coordinates != null) {
      data['coordinates'] = coordinates!.map((v) => v).toList();
    }
    data['profile'] = profile;
    data['profileName'] = profileName;
    data['format'] = format;
    return data;
  }
}

// class Coordinates {

// 	Coordinates();

// 	Coordinates.fromJson(Map<String, dynamic> json) {
// 	}

// 	Map<String, dynamic> toJson() {
// 		final Map<String, dynamic> data = new Map<String, dynamic>();
// 		return data;
// 	}
// }

class Engine {
  String? version;
  String? buildDate;
  String? graphDate;
  String? osmDate;

  Engine({this.version, this.buildDate, this.graphDate, this.osmDate});

  Engine.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    buildDate = json['build_date'];
    graphDate = json['graph_date'];
    osmDate = json['osm_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['version'] = version;
    data['build_date'] = buildDate;
    data['graph_date'] = graphDate;
    data['osm_date'] = osmDate;
    return data;
  }
}
