import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freetoplaychallange/models/detailed_pc_game_model.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class PCGameDetailsScreen extends StatefulWidget {
  const PCGameDetailsScreen({super.key, required this.gameId});
  final String gameId;
  @override
  State<PCGameDetailsScreen> createState() => _PCGameDetailsScreenState();
}

class _PCGameDetailsScreenState extends State<PCGameDetailsScreen> {
  bool isLoading = false;
  late DetailedPcGameModel game;

  getGameDetailes() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
        Uri.parse('https://www.freetogame.com/api/game?id=${widget.gameId}'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> gameJson = json.decode(response.body);
      game = DetailedPcGameModel.fromJson(gameJson);
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load game');
    }
  }

  @override
  void initState() {
    getGameDetailes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: size.width,
                            height: size.height * 0.4,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                bottomRight: Radius.circular(50),
                              ),
                              image: DecorationImage(
                                image: NetworkImage(
                                  game.thumbnail,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                              top: 0,
                              right: 0,
                              child: SafeArea(
                                child: IconButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse(game.gameUrl));
                                    },
                                    icon: const FaIcon(
                                      FontAwesomeIcons.share,
                                      color: Colors.white,
                                    )),
                              ))
                        ],
                      ),

                      // Platform
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  game.title,
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: Colors.deepPurple,
                              thickness: 0.3,
                            ),
                            Row(
                              children: [
                                Text("Platform : ${game.platform}"),
                                const SizedBox(
                                  width: 15,
                                ),
                                FaIcon(game.platform
                                        .toString()
                                        .toLowerCase()
                                        .contains('windows')
                                    ? FontAwesomeIcons.windows
                                    : FontAwesomeIcons.weebly)
                              ],
                            ),
                            const Divider(
                              color: Colors.deepPurple,
                              thickness: 0.3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: size.width * 0.5,
                                    child:
                                        Text("Publisher : ${game.publisher}")),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(game.releaseDate
                                    .toString()
                                    .substring(0, 10)
                                    .replaceAll('-', '/')),
                              ],
                            ),
                            const Divider(
                              color: Colors.deepPurple,
                              thickness: 0.3,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                    width: size.width * 0.9,
                                    child: Text(game.shortDescription)),
                              ],
                            )
                          ],
                        ),
                      ),
                      GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: game.screenshots.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: ((context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GridTile(
                                child: Image.network(
                                  game.screenshots[index].image,
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
                            );
                          })),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(game.description),
                      )
                    ],
                  ),
                )),
    );
  }
}
