import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freetoplaychallange/screens/pc_game_details_screen.dart';
import 'package:http/http.dart' as http;

import '../models/game_model.dart';
import 'web_game_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  int tabsIndex = 0;
  List<GameModel> games = [];

  getGameFromApi() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(tabsIndex == 0
        ? Uri.parse('https://www.freetogame.com/api/games')
        : tabsIndex == 1
            ? Uri.parse('https://www.freetogame.com/api/games?platform=pc')
            : Uri.parse(
                'https://www.freetogame.com/api/games?platform=browser'));
    if (response.statusCode == 200) {
      final List<dynamic> gamesJson = json.decode(response.body);
      games = gamesJson.map((e) => GameModel.fromJson(e)).toList();
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load games');
    }
  }

  @override
  void initState() {
    getGameFromApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free to Play'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        games[index]
                                .platform
                                .toString()
                                .toString()
                                .contains('pc')
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PCGameDetailsScreen(
                                          gameId: games[index].id.toString(),
                                        )))
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WebGameDetailsScreen(
                                          gameId: games[index].id.toString(),
                                        )));
                      },
                      child: GridTile(
                        footer: Container(
                          color: Colors.deepPurple.withOpacity(0.5),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              games[index].title,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        child: Container(
                          foregroundDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              games[index].thumbnail.toString(),
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  )),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.computer),
            label: 'PC',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.weebly),
            label: 'Web',
          ),
        ],
        currentIndex: tabsIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (int index) {
          setState(() {
            tabsIndex = index;
          });
          getGameFromApi();
        },
      ),
    );
  }
}
