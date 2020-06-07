import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'entities.g.dart';

extension NullHelper on Entity {
  bool anyNullFields() => _anyNullFieldsInMap(toJson());

  bool _anyNullFieldsInMap(Map<String, dynamic> map) {
    for (var entry in map.entries) {
      if (entry.value is Map<String, dynamic>) {
        if (_anyNullFieldsInMap(entry.value)) {
          return true;
        }
      } else if (entry.value is List) {
        for (var element in entry.value) {
          if (element is Map<String, dynamic>) {
            if (_anyNullFieldsInMap(element)) {
              return true;
            } else if (element == null) {
              print('KEY of LIST [${entry.key}] has a null element [${element}]\n${entry.value.toString()}');
              return true;
            }
          }
        }
      } else {
        if (entry.value == null) {
          print('KEY [${entry.key}] is associated with a null VALUE [${entry.value}]');
          return true;
        }
      }
    }
    return false;
  }
}

class Entity {
  Map<String, dynamic> toJson() => null;
}

class ByteArrayJsonConverter implements JsonConverter<Uint8List, List<dynamic>> {
  const ByteArrayJsonConverter();

  @override
  Uint8List fromJson(List<dynamic> json) => Uint8List.fromList(json.cast<int>());

  @override
  List<dynamic> toJson(Uint8List list) => list == null ? [] : List<dynamic>.from(list);
}

@JsonSerializable(checked: true, explicitToJson: true, createFactory: true, createToJson: true)
class EditSuggestion implements Entity {
  String artistName;
  String trackName;
  int clipStart;
  int clipEnd;

  EditSuggestion({
    @required this.artistName,
    @required this.trackName,
    @required this.clipStart,
    @required this.clipEnd,
  });

  factory EditSuggestion.fromJson(Map<String, dynamic> json) => _$EditSuggestionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EditSuggestionToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditSuggestion &&
          runtimeType == other.runtimeType &&
          artistName == other.artistName &&
          trackName == other.trackName &&
          clipStart == other.clipStart &&
          clipEnd == other.clipEnd;

  @override
  int get hashCode => artistName.hashCode ^ trackName.hashCode ^ clipStart.hashCode ^ clipEnd.hashCode;
}

@JsonSerializable(checked: true, explicitToJson: true, createFactory: true, createToJson: true)
@ByteArrayJsonConverter()
class SnippetTrack implements Entity {
  String id;
  int duration;
  int clipStart;
  int clipEnd;
  int listens;
  int originListens;
  Uint8List waveform;
  String url;
  String artistName;
  String artistURL;
  String trackName;
  String thumbnailURL;
  String fullCoverURL;
  String blurHash;

  SnippetTrack(
      {@required this.id,
      @required this.duration,
      @required this.url,
      @required this.artistName,
      @required this.artistURL,
      @required this.trackName,
      @required this.thumbnailURL,
      @required this.fullCoverURL,
      @required this.blurHash,
      this.waveform,
      this.clipEnd,
      this.clipStart = 0,
      this.listens = 0,
      this.originListens = 0}) {
    clipEnd ??= duration;
  }

  int getClippedDuration() {
    if (clipStart == -1) {
      if (clipEnd == -1) {
        return duration.toInt();
      } else {
        return clipEnd;
      }
    } else if (clipEnd == -1) {
      return (duration - clipStart).toInt();
    } else {
      return clipEnd - clipStart;
    }
  }

  factory SnippetTrack.fromJson(Map<String, dynamic> json) => _$SnippetTrackFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SnippetTrackToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true, createFactory: true, createToJson: true)
@ByteArrayJsonConverter()
class ScoredSnippetTrack extends SnippetTrack implements Entity {
  double score;

  ScoredSnippetTrack({
    @required this.score,
    @required String id,
    @required int duration,
    @required String url,
    @required String artistName,
    @required String artistURL,
    @required String trackName,
    @required String thumbnailURL,
    @required String fullCoverURL,
    @required String blurHash,
    int listens = 0,
    int originListens = 0,
    int clipStart,
    int clipEnd,
  }) : super(
            id: id,
            duration: duration,
            waveform: null,
            url: url,
            clipStart: clipStart,
            clipEnd: clipEnd,
            artistName: artistName,
            artistURL: artistURL,
            trackName: trackName,
            thumbnailURL: thumbnailURL,
            fullCoverURL: fullCoverURL,
            originListens: originListens,
            blurHash: blurHash);

  ScoredSnippetTrack.fromTrack(this.score, SnippetTrack track)
      : super(
          id: track.id,
          duration: track.duration,
          waveform: track.waveform,
          url: track.url,
          clipStart: track.clipStart,
          clipEnd: track.clipEnd,
          artistName: track.artistName,
          artistURL: track.artistURL,
          trackName: track.trackName,
          thumbnailURL: track.thumbnailURL,
          fullCoverURL: track.fullCoverURL,
          originListens: track.originListens,
          blurHash: track.blurHash,
        );

  factory ScoredSnippetTrack.fromJson(Map<String, dynamic> json) => _$ScoredSnippetTrackFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ScoredSnippetTrackToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true, createFactory: true, createToJson: true)
@ByteArrayJsonConverter()
class FullTrack extends SnippetTrack implements Entity {
  List<GeniusTrack> geniusSuggestions;

  /// <User ID, Edit Suggestion>
  Map<String, EditSuggestion> editSuggestions;

  /// <User ID, Edit Suggestion ID>
  Map<String, String> editSuggestionVotes;
  List<String> ngrams;
  String originURL;
  String description;
  int requests;
  DateTime publishedAt;

  FullTrack({
    @required String id,
    @required int duration,
    @required Uint8List waveform,
    @required String url,
    @required String artistName,
    @required String artistURL,
    @required String trackName,
    @required String thumbnailURL,
    @required String fullCoverURL,
    int listens = 0,
    int originListens = 0,
    int clipStart = 0,
    int clipEnd,
    @required String blurHash,
    @required this.publishedAt,
    @required this.geniusSuggestions,
    @required this.editSuggestions,
    @required this.editSuggestionVotes,
    @required this.ngrams,
    @required this.originURL,
    @required this.description,
    @required this.requests,
  }) : super(
            id: id,
            duration: duration,
            waveform: waveform,
            url: url,
            clipStart: clipStart,
            clipEnd: clipEnd,
            artistName: artistName,
            artistURL: artistURL,
            trackName: trackName,
            thumbnailURL: thumbnailURL,
            fullCoverURL: fullCoverURL,
            listens: listens,
            originListens: originListens,
            blurHash: blurHash);

  SnippetTrack toSnippet() {
    return SnippetTrack(
        id: id,
        duration: duration,
        waveform: waveform,
        url: url,
        clipStart: clipStart,
        clipEnd: clipEnd,
        artistName: artistName,
        artistURL: artistURL,
        trackName: trackName,
        thumbnailURL: thumbnailURL,
        fullCoverURL: fullCoverURL,
        listens: listens,
        originListens: originListens,
        blurHash: blurHash);
  }

  factory FullTrack.fromJson(Map<String, dynamic> json) => _$FullTrackFromJson(json);

  void preferredTrackName() {
    if (editSuggestions.length < 3) return;
  }

  @override
  Map<String, dynamic> toJson() => _$FullTrackToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true, createFactory: true, createToJson: true)
class GeniusTrack implements Entity {
  String trackURL;
  String trackName;
  String artistName;
  String artistURL;
  String lyrics;

  GeniusTrack(
      {@required this.trackURL,
      @required this.trackName,
      @required this.artistName,
      @required this.artistURL,
      @required this.lyrics});

  factory GeniusTrack.fromJson(Map<String, dynamic> json) => _$GeniusTrackFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GeniusTrackToJson(this);

  @override
  String toString() {
    return 'GeniusSuggestion{trackURL: $trackURL, trackName: $trackName, artistName: $artistName, artistURL: $artistURL, lyrics: $lyrics}';
  }
}

@JsonSerializable(checked: true, explicitToJson: true, createFactory: true, createToJson: true)
class Playlist implements Entity {
  String id;
  String name;
  String ownerID;
  String ownerName;
  List<String> trackIDs;
  List<SnippetTrack> tracks;
  List<String> whitelistedUserIDs;
  List<String> accessRequests;
  int listens;
  bool public;

  Playlist({
    @required this.name,
    @required this.public,
    @required this.trackIDs,
    @required this.tracks,
    @required this.id,
    @required this.ownerID,
    @required this.ownerName,
    this.whitelistedUserIDs = const [],
    this.accessRequests = const [],
    this.listens = 0,
  });

  void reorderTracks(List<String> newOrder) {
    trackIDs = newOrder;

    var newTracks = <SnippetTrack>[];

    for (var id in newOrder) {
      secondary:
      for (var snippet in tracks) {
        if (snippet.id == id) {
          newTracks.add(snippet);
          break secondary;
        }
      }
    }
    tracks = newTracks;
  }

  void addTrack(SnippetTrack track) {
    if (tracks.length < 500 && trackIDs.length < 500) {
      tracks.add(track);
      trackIDs.add(track.id);
    }
  }

  void removeTrack(String id) {
    for (FullTrack track in tracks) {
      if (track.id == id) {
        tracks.remove(track);
        break;
      }
    }
    trackIDs.remove(id);
  }

  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlaylistToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true, createFactory: true, createToJson: true)
class ChaChaUserSnippet implements Entity {
  String id;
  String displayName;
  String profilePicture;

  ChaChaUserSnippet({@required this.id, @required this.displayName, @required this.profilePicture});

  factory ChaChaUserSnippet.fromJson(Map<String, dynamic> json) => _$ChaChaUserSnippetFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChaChaUserSnippetToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true, createFactory: true, createToJson: true)
class ChaChaUser extends ChaChaUserSnippet implements Entity {
  List<SnippetTrack> tracks;
  List<String> trackIDs;
  List<Playlist> playlists;
  List<String> playlistIDs;
  List<String> friendIDs;
  List<ChaChaUserSnippet> friends;
  List<ChaChaUserSnippet> friendRequests;
  List<String> blockedUserIDs;
  bool public;
  String email;

  ChaChaUser({
    @required String id,
    @required String displayName,
    @required String profilePicture,
    this.email,
    this.public = false,
    this.tracks = const [],
    this.playlists = const [],
    this.trackIDs = const [],
    this.playlistIDs = const [],
    this.friendRequests = const [],
    this.friends = const [],
    this.friendIDs = const [],
    this.blockedUserIDs = const [],
  }) : super(id: id, displayName: displayName, profilePicture: profilePicture);

  void addPlaylist(Playlist playlist) {
    playlists.add(playlist);
    playlistIDs.add(playlist.id);
  }

  void editPlaylist(Playlist playlist) {
    if (playlists.contains(playlist)) {
      var index = playlists.indexOf(playlist);
      playlists.remove(playlist);
      playlists.insert(index, playlist);
    }
  }

  void removePlaylist(String playlistID) {
    for (var playlist in playlists) {
      if (playlist.id == playlistID) {
        playlists.remove(playlist);
        break;
      }
    }
    playlistIDs.remove(playlistID);
  }

  void addTrack(SnippetTrack track) {
    tracks.add(track);
    trackIDs.add(track.id);
  }

  void removeTrack(String id) {
    for (FullTrack track in tracks) {
      if (track.id == id) {
        tracks.remove(track);
        break;
      }
    }
    trackIDs.remove(id);
  }

  void reorderTracks(List<String> newOrder) {
    trackIDs = newOrder;

    var newTracks = <SnippetTrack>[];

    for (var id in newOrder) {
      secondary:
      for (var snippet in tracks) {
        if (snippet.id == id) {
          newTracks.add(snippet);
          break secondary;
        }
      }
    }
    tracks = newTracks;
  }

  void reorderPlaylists(List<String> newOrder) {
    playlistIDs = newOrder;

    var newPlaylists = <Playlist>[];

    for (var id in newOrder) {
      secondary:
      for (var playlist in playlists) {
        if (playlist.id == id) {
          newPlaylists.add(playlist);
          break secondary;
        }
      }
    }
    playlists = newPlaylists;
  }

  void addFriend(ChaChaUserSnippet friend) {
    friendIDs.add(friend.id);
    friends.add(friend);
  }

  void removeFriend(String friendID) {
    friendIDs.remove(friendID);
    for (var friend in friends) {
      if (friend.id == friendID) {
        friends.remove(friend);
        break;
      }
    }
  }

  ChaChaUserSnippet toSnippet() => ChaChaUserSnippet(id: id, displayName: displayName, profilePicture: profilePicture);

  factory ChaChaUser.fromJson(Map<String, dynamic> json) => _$ChaChaUserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChaChaUserToJson(this);
}
