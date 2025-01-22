import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExplosionGame(),
    );
  }
}



class ExplosionGame extends StatefulWidget {
  const ExplosionGame({super.key});

  @override
  State<ExplosionGame> createState() => _ExplosionGameState();
}

class _ExplosionGameState extends State<ExplosionGame> with SingleTickerProviderStateMixin {

  ValueNotifier<double>  left = ValueNotifier(120.0);
  ValueNotifier<double>  bottom = ValueNotifier(100.0);
  bool isTapped = true;
  bool isGameStarted = false;
  bool nextPlay = false;
  ValueNotifier<bool?> jumpRight=ValueNotifier(null);
  int countIndex=10;
  late final AnimationController _controller = AnimationController(vsync: this, duration: Duration(seconds: 100))..repeat();
  double screenWidth =320;
  List<double> springPosition = [];
  final ScrollController _scrollController = ScrollController();
  final _random =  Random();

  _scrollToBottom() {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 20), curve: Curves.linear).then((value)
        {
          _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(seconds: 20), curve: Curves.linear);

        }
    );
  }

  final player = AudioPlayer();

  @override
  void initState() {
    player.setAsset("assets/clank-car.mp3").then((value){

    });
    player.setVolume(0.1);
    // TODO: implement initState
    super.initState();
  }


  jump(double t,){
    double h = 20*t - 14*t*t;
    if(!h.isNegative)
    {
      bottom.value = 100 +h*10;
      if(jumpRight.value!=null)
      {
        if(jumpRight.value!)
        {
          if(left.value>5) {
            left.value = left.value-4;
          } else {
            jumpRight.value = !jumpRight.value!;
          }
        } else {
          if(left.value > screenWidth) {
            jumpRight.value = !jumpRight.value!;
          } else {
            left.value = left.value+4;
          }
        }
      }
    } else {
      bottom.value = 99;
    }
  }

  sec5Timer() {
    isTapped = false;
    int time = 0;
    Timer.periodic(Duration(milliseconds: 17), (timer) {
      time = time+17;
      jump(time/1000);
      if(nextPlay)
      {
        timer.cancel();
      }
      if (bottom.value<100) {
        bottom.value = 100;
        isTapped = true;
        timer.cancel();
        sec5Timer();
      }
    });
  }

  increaseCounter(){
    if(countIndex<120) {
      countIndex = countIndex + 10;
      _scrollToBottom();
      nextPlay = true;
      isGameStarted = false;
    } else {
      const snackBar = SnackBar(
        content: Text("Max Level"),
        duration: Duration(milliseconds: 500),

      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }


  }

  decreaseCounter(){
    if(countIndex>10)
    {
      countIndex = countIndex-10;
      _scrollToBottom();
      isGameStarted = false;
      nextPlay = true;
      bottom.value = 99;
    } else {
      const snackBar = SnackBar(
        content: Text("Lowest Level"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  startGame(){
    nextPlay = false;
    sec5Timer();
    _scrollToBottom();
    bottom.value = 99;
  }

  @override
  void dispose() {

    if(player.playing)
    {
      player.pause();
      player.stop();
      player.dispose();
    }
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<bool> myList = List.generate(countIndex, (index) => true);
    int itemCount = 0;
    var itemIndexRun = 0;
    screenWidth = MediaQuery.of(context).size.width-70;

    for (var i = 0; i < 800; i++) {
      if((i+1)*10<screenWidth) {
        springPosition.add((i+1)*10);
      }
    }
    print(springPosition);
    return  Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (value){

          if(value.delta.dx.isNegative){
            jumpRight.value = true;
            if( left.value>4)
            {
              left.value = left.value-2;

            }
          } else {
            jumpRight.value = false;
            if(left.value<MediaQuery.of(context).size.width-40) {
              left.value = left.value+2;
            }
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.cyan,

          child: Stack(
            children: [

              ValueListenableBuilder(valueListenable: bottom, builder: (context, value, _){
                return Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0, right: 16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                      child: Text("score: $itemCount / $countIndex", style: TextStyle(fontSize: 28,color: Colors.white),),
                    ),
                  ),
                );
              }),

              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child:
                ListView.builder(
                    itemCount: countIndex,
                    reverse: true,
                    controller: _scrollController,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index){
                      double elementPosition = springPosition[_random.nextInt(springPosition.length)];
                      final GlobalKey key = GlobalKey();
                      return Row(
                        children: [
                          SizedBox(width: elementPosition,),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 140.0),
                              child: ValueListenableBuilder(valueListenable: bottom,
                                  builder: (context, value, _){
                                    if(index > itemIndexRun)
                                    {
                                      itemIndexRun = index;
                                      if(countIndex<120) {
                                        if (index >= countIndex - 1) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            setState(() {
                                              increaseCounter();
                                              _scrollController.animateTo(0,
                                                  duration: Duration(
                                                      microseconds: 500),
                                                  curve: Curves.linear);
                                            });
                                          });
                                        }
                                      }

                                    }


                                    var difference = 0.0;
                                    if(left.value> elementPosition){
                                      difference = left.value- elementPosition;
                                    } else {
                                      difference = elementPosition  - left.value;
                                    }
                                    Offset? position;

                                    void getOffset(GlobalKey key) {
                                      if(key.currentContext!=null)
                                      {
                                        RenderBox? box = key.currentContext!.findRenderObject() as RenderBox?;

                                        position = box!.localToGlobal(Offset.zero);
                                      }

                                    }
                                    if(difference<70)
                                    {
                                      getOffset(key);
                                      if( myList[index]==true)
                                        {
                                          if (position != null) {
                                            if(position!.dy+ bottom.value+120>MediaQuery.of(context).size.height)
                                            {
                                              if(position!.dy+ bottom.value+ 20<MediaQuery.of(context).size.height)
                                              {
                                                if(player.playing)
                                                {
                                                  player.seek(Duration(seconds: 0));
                                                  player.play();
                                                } else {
                                                  player.play();
                                                }
                                                myList[index] = false;

                                                itemCount++;
                                              }
                                            }
                                          }
                                        }

                                    }
                                    return  SizedBox(
                                      height: 100,
                                      width: 100,
                                      key: key,
                                      child: myList[index] ? Center(child:                                          Image.asset("assets/1191094.png", height: 90, width: 90 ,),
                                      ):Image.asset("assets/explosion.png", height: 100, width: 100,)
                                    );
                                  })
                          ),
                          Spacer()
                        ],
                      );
                    }),
              ),
              Align(
                alignment: Alignment.topRight,
                child:  Padding(
                  padding: const EdgeInsets.only(top: 116.0, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2)
                    ),
                    height: 120, width:90,
                    child: Column(
                      children: [
                        InkWell(
                            onTap: (){
                              setState(() {
                                increaseCounter();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(Icons.expand_less, color: Colors.white, size: 36,),
                            )),
                        Text("Level ${(countIndex/10).floor()}", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                        InkWell(
                          onTap: (){
                            setState(() {
                              decreaseCounter();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(Icons.expand_more, color: Colors.white, size: 36,),
                          )
                          ,
                        )

                      ],
                    ),
                  ),
                ),),
              Align(
                alignment: Alignment.bottomLeft,
                child: InkWell(
                    onTap: (){
                      if(isGameStarted)
                      {
                        if(isTapped)
                        {
                          sec5Timer();
                        } else {
                          jumpRight.value = null;
                        }
                      }
                    },
                    child: ValueListenableBuilder(valueListenable: bottom, builder: (context, value, index){
                      return Padding(
                        padding: EdgeInsets.only(left: left.value, bottom: bottom.value),
                        child: jumpRight.value!=null ? AnimatedBuilder(
                          animation: _controller,
                          builder: (_, child) {
                            return ValueListenableBuilder(
                                valueListenable: _controller,
                                builder: (context, value, index) {
                                  return Transform.rotate(
                                    angle:  _controller.value*400,
                                    child: Image.asset("assets/1152091.png", height: 70, width: 70,color: Colors.white,),
                                  );
                                }
                            );
                          },
                          child: Image.asset("assets/1152091.png", height: 70, width: 70,color: Colors.white,),
                        ):Image.asset("assets/1152091.png", height: 70, width: 70,color: Colors.white,),
                      );
                    })
                ),
              ),
              if(!isGameStarted)
                Center(child: InkWell(
                  onTap:(){
                    startGame();
                    setState(() {
                      isGameStarted = true;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.redAccent
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                      child: Text( nextPlay? "Start Level: ${(countIndex/10).floor()}" :"Start Game", style: const TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                    ),
                  ),
                ),)

            ],
          ),
        ),
      ),
    );
  }
}

