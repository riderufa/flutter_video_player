import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late VideoPlayerController _videoPlayerController;
  Duration? _position = Duration.zero;
  Duration? _duration = Duration.zero;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(
      'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',
    );
    _videoPlayerController.addListener(() {
      setState(() {});
    });
    // _videoPlayerController.setLooping(true);
    _videoPlayerController.initialize().then((_) {
      _duration = _videoPlayerController.value.duration;
      _videoPlayerController.addListener(_onControllerUpdate);
      _videoPlayerController.play;
      setState(() {});
    });
  }

  void _onControllerUpdate() async {
    _position = await _videoPlayerController.position;
    final isPlaying = _videoPlayerController.value.isPlaying;
    if (isPlaying) {
      setState(() {
        _progress = _position!.inMilliseconds.ceilToDouble() /
            _duration!.inMilliseconds.ceilToDouble();
      });
    }
  }

  String getTimeString(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    String hoursString = '';
    if (hours < 10 && hours > 0) {
      hoursString = '0$hours:';
    } else if (hours > 9) {
      hoursString = '$hours:';
    }
    String minutesString;
    if (minutes < 10 && minutes > 0) {
      minutesString = '0$minutes:';
    } else if (minutes > 9) {
      minutesString = '$minutes:';
    } else {
      minutesString = '00:';
    }
    String secondsString = '';
    if (seconds < 10 && seconds > 0) {
      secondsString = '0$seconds';
    } else if (seconds > 9) {
      secondsString = '$seconds';
    } else {
      secondsString = '00';
    }
    return hoursString + minutesString + secondsString;
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SizedBox(
        height: 200,
        child: Stack(
          children: [
            VideoPlayer(_videoPlayerController),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    Slider(
                      value: max(0, min(_progress * 100, 100)),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (value) {
                        setState(() {
                          _progress = value * 0.01;
                        });
                      },
                      onChangeStart: (_) {
                        _videoPlayerController.pause();
                      },
                      onChangeEnd: (value) {
                        final Duration duration =
                            _videoPlayerController.value.duration;
                        double newValue = max(0, min(value, 99)) * 0.01;
                        int millis =
                            (duration.inMilliseconds * newValue).toInt();
                        _videoPlayerController
                            .seekTo(Duration(milliseconds: millis));
                        // _videoPlayerController.play();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            getTimeString(_position!),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Spacer(),
                          Text(
                            getTimeString(_duration!),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                bottom: 16,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        _videoPlayerController.seekTo(
                            Duration(seconds: _position!.inSeconds - 10));
                      },
                      icon: const Icon(Icons.replay_10),
                      color: Colors.white,
                    ),
                    IconButton(
                      onPressed: () {
                        _videoPlayerController.value.isPlaying
                            ? _videoPlayerController.pause()
                            : _videoPlayerController.play();
                      },
                      icon: _videoPlayerController.value.isPlaying
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                      color: Colors.white,
                    ),
                    IconButton(
                      onPressed: () {
                        _videoPlayerController.seekTo(
                            Duration(seconds: _position!.inSeconds + 10));
                      },
                      icon: const Icon(Icons.forward_10),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
