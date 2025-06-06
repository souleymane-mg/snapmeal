import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/timeago.dart' as timeago_fr;

class AnnonceScreen extends StatelessWidget {
  const AnnonceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    timeago_fr.setLocaleMessages('fr', timeago_fr.FrMessages());

    return Scaffold(
      appBar: AppBar(
        title: Text('Annonces'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Annonces').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<FeedItem> feedItems = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return FeedItem(
              content: data['contenu_annonce'],
              imageUrl: data['image_contenu'],
              userName: data['auteur_post'],
              postTime: DateTime.parse('${data['date_contenu']} ${data['heure_annonce']}'),
              commentsCount: 0,
              likesCount: 0,
              retweetsCount: 0,
            );
          }).toList();

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: OrientationBuilder(
                builder: (context, orientation) {
                  final bool isPortrait = orientation == Orientation.portrait;
                  return ListView.separated(
                    itemCount: feedItems.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final item = feedItems[index];
                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance.collection('medecin_md')
                            .where('nom_md', isEqualTo: item.userName)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          final userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                          final user = User(
                            fullName: item.userName,
                            userName: item.userName,
                            imageUrl: userData['photoURL'],
                          );

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _AvatarImage(user.imageUrl),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: RichText(
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(children: [
                                                  TextSpan(
                                                    text: user.fullName,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                                  TextSpan(
                                                    text: " @${user.userName}",
                                                    style: Theme.of(context).textTheme.titleMedium,
                                                  ),
                                                ]),
                                              )),
                                          Text('· ${timeago.format(item.postTime, locale: 'fr')}',
                                              style: Theme.of(context).textTheme.titleMedium),
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Icon(Icons.more_horiz),
                                          )
                                        ],
                                      ),
                                      if (item.content != null)
                                        Text(
                                          item.content!,
                                          style: TextStyle(fontSize: isPortrait ? 18 : 24), // Ajuster la taille de la police
                                        ),
                                      if (item.imageUrl != null)
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: InteractiveViewer(
                                                    child: Image.network(item.imageUrl!),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: 200,
                                            margin: const EdgeInsets.only(top: 8.0),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8.0),
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(item.imageUrl!),
                                                )),
                                          ),
                                        ),
                                      _ActionsRow(item: item)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String url;
  const _AvatarImage(this.url, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: NetworkImage(url))),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final FeedItem item;
  const _ActionsRow({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.grey, size: 18),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.grey),
              ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mode_comment_outlined),
            label: Text(
                item.commentsCount == 0 ? '' : item.commentsCount.toString()),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.repeat_rounded),
            label: Text(
                item.retweetsCount == 0 ? '' : item.retweetsCount.toString()),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
            label: Text(item.likesCount == 0 ? '' : item.likesCount.toString()),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.share_up),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

class FeedItem {
  final String? content;
  final String? imageUrl;
  final String userName;
  final DateTime postTime;
  final int commentsCount;
  final int likesCount;
  final int retweetsCount;

  FeedItem(
      {this.content,
        this.imageUrl,
        required this.userName,
        required this.postTime,
        this.commentsCount = 0,
        this.likesCount = 0,
        this.retweetsCount = 0});
}

class User {
  final String fullName;
  final String imageUrl;
  final String userName;

  User({
    required this.fullName,
    required this.userName,
    required this.imageUrl,
  });
}
