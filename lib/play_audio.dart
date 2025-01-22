import 'package:just_audio/just_audio.dart';
import 'package:flutter/cupertino.dart';

class PlayCreakSound extends StatefulWidget {
  const PlayCreakSound({super.key});

  @override
  State<PlayCreakSound> createState() => _PlayCreakSoundState();
}

class _PlayCreakSoundState extends State<PlayCreakSound> {
  final player = AudioPlayer();
  
  @override
  void initState() {
    player.setAsset("assets/snap-274158.mp3").then((value){

    });
    player.play();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {

    if(player.playing)
      {
        player.pause();
        player.stop();
      }
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

