import 'package:better_player/better_player.dart';
import 'package:better_player/src/configuration/better_player_configuration.dart';
import 'package:better_player/src/configuration/better_player_data_source.dart';
import 'package:better_player/src/configuration/better_player_event_type.dart';
import 'package:better_player/src/playlist/better_player_playlist_configuration.dart';

import 'package:flutter/material.dart';

class BetterPlayerPlaylist extends StatefulWidget {
  final List<BetterPlayerDataSource> betterPlayerDataSourceList;
  final BetterPlayerConfiguration betterPlayerConfiguration;
  final BetterPlayerPlaylistConfiguration betterPlayerPlaylistConfiguration;

  BetterPlayerPlaylist(
      {Key key,
      this.betterPlayerDataSourceList,
      this.betterPlayerConfiguration,
      this.betterPlayerPlaylistConfiguration})
      : super(key: key);

  @override
  _BetterPlayerPlaylistState createState() => _BetterPlayerPlaylistState();
}

class _BetterPlayerPlaylistState extends State<BetterPlayerPlaylist> {
  BetterPlayerDataSource _currentSource;
  BetterPlayerController _controller;
  bool _changingToNextVideo = false;

  List<BetterPlayerDataSource> get _betterPlayerDataSourceList =>
      widget.betterPlayerDataSourceList;

  @override
  void initState() {
    super.initState();
    _currentSource = _getNextDateSource();
    _setupPlayer();
    _registerListeners();
  }

  void _registerListeners() {
    _controller.nextVideoTimeStreamController.stream.listen((data) {
      if (data == 0) {
        _onVideoChange();
      }
    });
  }

  void _onVideoChange() {
    if (_changingToNextVideo) {
      return;
    }
    if (_controller.isFullScreen) {
      _controller.exitFullScreen();
    }
    _changingToNextVideo = true;
    BetterPlayerDataSource _nextDataSource = _getNextDateSource();
    print("next data source: " + _nextDataSource.toString());
    if (_nextDataSource == null) {
      return;
    }

    setState(() {
      _currentSource = _nextDataSource;
    });
    _setupNextDataSource();
    _changingToNextVideo = false;
  }

  void _setupPlayer() {
    _controller = BetterPlayerController(widget.betterPlayerConfiguration,
        betterPlayerPlaylistConfiguration:
            widget.betterPlayerPlaylistConfiguration,
        betterPlayerDataSource: _currentSource);
    _controller.addEventsListener((event) async {
      if (event.betterPlayerEventType == BetterPlayerEventType.FINISHED) {
        _controller.startNextVideoTimer();
      }
    });
    _controller.addListener(() {
      setState(() {});
    });
  }

  void _setupNextDataSource() async {
    _controller.setupDataSource(_currentSource);
  }

  String _getKey() => _controller.hashCode.toString();

  BetterPlayerDataSource _getNextDateSource() {
    if (_currentSource == null) {
      return _betterPlayerDataSourceList.first;
    } else {
      int index = _betterPlayerDataSourceList.indexOf(_currentSource);
      if (index + 1 < _betterPlayerDataSourceList.length) {
        return _betterPlayerDataSourceList[index + 1];
      } else {
        if (widget.betterPlayerPlaylistConfiguration.loopVideos) {
          return _betterPlayerDataSourceList.first;
        } else {
          return null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(
      key: Key(_getKey()),
      controller: _controller,
    );
  }
}