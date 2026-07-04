import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(const MaterialApp(home: TrollPrompterApp()));

class TrollPrompterApp extends StatefulWidget {
  const TrollPrompterApp({Key? key}) : super(key: key);
  @override
  _TrollPrompterAppState createState() => _TrollPrompterAppState();
}

class _TrollPrompterAppState extends State<TrollPrompterApp> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  ScrollController _scrollController = ScrollController();

  // 模拟剧本文本（实际开发中可以做成让用户自己输入/粘贴）
  String _scriptText =
      "欢迎使用巨魔免签AI提词器。今天我们要测试的是Windows环境下的全自动声音轮动功能。当你对着手机说话的时候，AI会自动识别你当前读到了哪一个字，并且驱动屏幕上的滚动条自动向下平滑推进。这样你就再也不用手动去翻页了，录制视频也会变得更加自然。";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // 启动/停止语音识别
  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('状态: $status'),
        onError: (errorNotification) => print('错误: $errorNotification'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: "zh_CN", // 强制指定中文识别
          onResult: (result) {
            _handleVoiceMatch(result.recognizedWords);
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // AI核心算法：将听到的语音和剧本做匹配并滚动
  void _handleVoiceMatch(String words) {
    if (words.isEmpty) return;

    // 取出AI最后听到的4个字作为定位锚点
    String searchKeyword = words.length > 4
        ? words.substring(words.length - 4)
        : words;

    // 在剧本中寻找这几个字的位置
    int charIndex = _scriptText.indexOf(searchKeyword);

    if (charIndex != -1) {
      // 计算读到的字占整篇剧本的比例
      double progressRatio = charIndex / _scriptText.length;

      // 计算滚动条应该滚动到的目标像素位置
      double targetOffset =
          _scrollController.position.maxScrollExtent * progressRatio;

      // 驱动滚动条平滑滚动过去
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 提词器一般用黑底高对比度
      appBar: AppBar(
        title: const Text('巨魔 AI 提词器 (Windows版)'),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: _scrollController,
                children: [
                  Text(
                    _scriptText,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.green, // 经典提词器绿色字体
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleListening,
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  label: Text(_isListening ? 'AI 正在追踪声音...' : '开启 AI 轮动'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.red : Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
