import 'package:flutter/material.dart';
import 'package:guess_waifu_game/business/harem.dart';
import 'package:guess_waifu_game/business/waifu.dart';
import 'package:guess_waifu_game/config.dart';

class GameplayPage extends StatefulWidget {
  const GameplayPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameplayPageState();
}

class _GameplayPageState extends State<GameplayPage>
    with TickerProviderStateMixin {
  bool _isCountingDown = false;
  bool _isLoading = false;
  Waifu? _waifu;
  late AnimationController? _animationContainer;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _animationContainer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _waifu == null
                ? Container()
                : Image(
                    image:
                        _isCountingDown ? _waifu!.blurred : _waifu!.original),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              color: Colors.lightBlue,
                            ),
                          ),
                        ),
                        if (_animation != null)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _animation!,
                              builder: (_, __) => FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _animation!.value,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(4),
                                    ),
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_isCountingDown) {
                            _reveal();
                          } else {
                            _pickNew();
                          }
                        },
                  child: Text(_isCountingDown ? '显示答案' : '下个老婆'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _init() async {
    try {
      await harem.init();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('后宫初始化失败，请检查涩图文件夹')));
      return;
    }
    _pickNew();
  }

  void _reveal() {
    setState(() {
      _animationContainer?.stop();
      _animationContainer?.dispose();
      _animationContainer = null;
      _animation = null;
      _isCountingDown = false;
    });
  }

  void _pickNew() async {
    setState(() {
      _isLoading = true;
    });
    Waifu newWaifu;
    try {
      final start = DateTime.now().millisecondsSinceEpoch;
      newWaifu = await harem.pickWaifu(context);
      print('Loading waifu costs ' +
          (DateTime.now().millisecondsSinceEpoch - start).toString() +
          'ms');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('挑选新老婆失败，请检查涩图文件夹')));
      return;
    }
    // Loading next image...
    setState(() {
      _isLoading = false;
      _isCountingDown = true;
      _waifu = newWaifu;
      _animationContainer = AnimationController(
          duration: const Duration(seconds: countdownSeconds), vsync: this);
      _animationContainer!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _reveal();
        }
      });
      _animation = Tween(begin: 1.0, end: 0.0).animate(_animationContainer!);
      _animationContainer!.forward();
    });
  }
}
