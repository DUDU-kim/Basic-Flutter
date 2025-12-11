import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../account_test_page.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_project/provider.dart';
import 'package:provider/provider.dart';
import 'package:my_project/api_config.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage> {
  // 【修正1】使用 static 變數，讓資料永遠存在，不會因為頁面重繪而閃爍
  static String _keptKeyword = "";
  static List<Map<String, dynamic>> _keptAlbums = [];

  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  // 使用 ValueNotifier 來處理焦點，避免 setState 觸發整頁重繪
  final ValueNotifier<bool> _isFocusedNotifier = ValueNotifier(false);

  final String baseUrl = 'http://13.239.60.163';
  File? _avatarImage;

  final buttonData = [
    {"title": "音樂", "color": Colors.pink, "image": "assets/num/1.png"},
    {"title": "Podcast", "color": Colors.teal[700], "image": "assets/num/2.png"},
    {"title": "現場活動", "color": Colors.purple[500], "image": "assets/num/1.png"},
    {"title": "專為你打造", "color": Colors.purple[200], "image": "assets/num/2.png"},
    {"title": "最新發行", "color": Colors.green[500], "image": "assets/num/1.png"},
    {"title": "華語流行", "color": Colors.blue[900], "image": "assets/num/2.png"},
    {"title": "流行樂", "color": Colors.blue[500], "image": "assets/num/1.png"},
    {"title": "韓國流行樂", "color": Colors.redAccent, "image": "assets/num/2.png"},
    {"title": "嘻哈樂", "color": Colors.blue[500], "image": "assets/num/1.png"},
    {"title": "排行榜", "color": Colors.purple[200], "image": "assets/num/2.png"},
  ];

  @override
  void initState() {
    super.initState();
    // 初始化時填入保留的文字
    _searchController = TextEditingController(text: _keptKeyword);

    _searchFocusNode.addListener(() {
      _isFocusedNotifier.value = _searchFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _isFocusedNotifier.dispose();
    super.dispose();
  }

  Future<void> searchAlbums(String val) async {
    // 防止重複搜尋
    if (val == _keptKeyword && _keptAlbums.isNotEmpty) return;

    if (val.isEmpty) {
      setState(() {
        _keptAlbums = [];
        _keptKeyword = "";
      });
      return;
    }

    _keptKeyword = val;

    var url = Uri.parse(ApiConfig.baseUrl + ApiConfig.searchMusic);
    var response = await http.post(url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
        },
        body: { "keyword": val });

    if (response.statusCode == 200) {
      if (!mounted) return;
      setState(() {
        final List<dynamic> data = json.decode(response.body);
        _keptAlbums = data.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  void cancelSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _keptKeyword = "";
      _keptAlbums = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // 【修正2】移除這裡原本包住 Scaffold 的 Consumer2
    // 改成直接回傳 Scaffold，這樣音樂播放時整頁就不會重繪
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              title: Text("搜尋", style: TextStyle(color: Colors.white)),
              titleSpacing: 0,
              iconTheme: IconThemeData(color: Colors.white),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [],
            ),

            // ---- 搜尋框 ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: screenHeight * 0.08,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isFocusedNotifier,
                        builder: (context, isFocused, child) {
                          return TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            cursorColor: Colors.cyan,
                            onChanged: (value) {
                              // 只有當有焦點時才搜尋，避免系統誤觸發
                              if (_searchFocusNode.hasFocus) {
                                searchAlbums(value);
                              }
                            },
                            style: TextStyle(color: Colors.white, fontSize: (screenWidth * 0.03).clamp(13.0, 15.0)),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search, color: Colors.white),
                              suffixIcon: isFocused
                                  ? TextButton(
                                onPressed: cancelSearch,
                                child: Text("取消", style: TextStyle(color: Colors.cyan, fontSize: (screenWidth * 0.03).clamp(13.0, 15.0))),
                              )
                                  : null,
                              labelText: "想聽甚麼?",
                              labelStyle: TextStyle(color: Colors.grey, fontSize: (screenWidth * 0.03).clamp(13.0, 15.0)),
                              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyan, width: 2)),
                              floatingLabelStyle: TextStyle(color: isFocused ? Colors.cyan : Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---- 內容區域 ----
            Expanded(
              child: Stack(
                children: [
                  // ---- "瀏覽全部" 視圖 ----
                  // 使用 Visibility 配合 static 變數，切換最穩定
                  Visibility(
                    visible: _keptKeyword.isEmpty,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.01),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: const Text('瀏覽全部', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'MicrosoftJhengHei', fontWeight: FontWeight.bold,),),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                for (int i = 0; i < buttonData.length; i += 2)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: screenHeight * 0.13,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: buttonData[i]["color"] as Color?,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountTestPage()));
                                              },
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: screenWidth * 0.04,
                                                    top: screenHeight * 0.13 * 0.1,
                                                    child: Text(
                                                      buttonData[i]["title"] as String,
                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: (screenWidth * 0.035).clamp(12.0, 15.0)),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 0, top: 0, bottom: 0,
                                                    child: Transform.rotate(
                                                      angle: 0.2,
                                                      child: Image.asset(buttonData[i]["image"] as String, width: screenWidth * 0.12, fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.04),
                                        Expanded(
                                          child: (i + 1 < buttonData.length)
                                              ? SizedBox(
                                            height: screenHeight * 0.13,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: buttonData[i + 1]["color"] as Color?,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountTestPage()));
                                              },
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: screenWidth * 0.04,
                                                    top: screenHeight * 0.13 * 0.1,
                                                    child: Text(
                                                      buttonData[i + 1]["title"] as String,
                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: (screenWidth * 0.035).clamp(12.0, 15.0)),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 0, top: 0, bottom: 0,
                                                    child: Transform.rotate(
                                                      angle: 0.2,
                                                      child: Image.asset(buttonData[i + 1]["image"] as String, width: screenWidth * 0.12, fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                              : const SizedBox(),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ---- "搜尋結果" 視圖 ----
                  Visibility(
                    visible: _keptKeyword.isNotEmpty,
                    child: Container(
                      color: Colors.black,
                      child: _keptAlbums.isEmpty
                          ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('查無結果', style: TextStyle(color: Colors.grey, fontSize: 16))))
                          : ListView.builder(
                        itemCount: _keptAlbums.length,
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        itemBuilder: (context, index) {
                          var album = _keptAlbums[index];

                          // 【修正3】使用 Listener 確保點擊有效，並不主動 unfocus
                          return Listener(
                            behavior: HitTestBehavior.translucent,
                            onPointerDown: (_) {

                              // 播放邏輯
                              final selectedProvider = Provider.of<SelectedAlbumProvider>(context, listen: false);
                              selectedProvider.getPlayList("搜尋 「 ${album["title"]} 」");

                              final onlyOneSong = [{
                                'id': album["id"],
                                "title": album["title"],
                                "artist": album["artist"],
                                "file_url": album["file_url"],
                                'music_cache': album["music_cache"],
                                "cover_url": album["id"],
                                "image_small": album["image_small"],
                                "image_medium": album["image_medium"],
                                'duration': album["duration"],
                              }];

                              Provider.of<SelectedAlbumProvider>(context, listen: false).selectAlbum(
                                  isRepeat: false,
                                  newAlbum: album,
                                  newPlaylist: onlyOneSong.cast<Map<String, dynamic>>());

                              Provider.of<MyPlaylistProvider>(context, listen: false).updateAddState(album["title"], isNetWork: true);
                            },
                            child: ListTile(
                              mouseCursor: SystemMouseCursors.click,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                // 【修正4】加上 IgnorePointer 防止圖片攔截點擊
                                child: IgnorePointer(
                                  child: Image.network(
                                    album["image_small"]!,
                                    width: screenWidth * 0.15,
                                    height: screenHeight * 0.08,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // 【修正5】 Consumer 只包住這個 Text！
                              // 只有這行字會變色，其他整個頁面都不會動
                              title: Consumer<SelectedAlbumProvider>(
                                builder: (context, albumProvider, child) {
                                  return Text(
                                    album["title"]!,
                                    style: TextStyle(
                                      color: albumProvider.selectedAlbumFileUrl == album["file_url"] ? Colors.cyan : Colors.white,
                                    ),
                                  );
                                },
                              ),
                              subtitle: Text('藝人：${album["artist"]!}', style: TextStyle(color: Colors.grey, fontSize: (screenWidth * 0.03).clamp(8.0, 10.0))),
                              onTap: () {},
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey[900],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.grey[850]),
                accountName: Text('老師你可能要稍微躲一下', style: TextStyle(fontSize: (screenWidth * 0.03).clamp(18.0, 20.0), color: Colors.grey)),
                accountEmail: Text("檢視個人檔案", style: TextStyle(fontSize: (screenWidth * 0.03).clamp(8.0, 10.0), color: Colors.grey)),
                currentAccountPicture: GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedImage != null) {
                      if (mounted) {
                        setState(() {
                          _avatarImage = File(pickedImage.path);
                        });
                      }
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white70,
                    backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : null,
                    child: _avatarImage == null ? Icon(Icons.person, color: Colors.black) : null,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text('設定', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.history, color: Colors.white),
                title: Text('歷史紀錄', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}