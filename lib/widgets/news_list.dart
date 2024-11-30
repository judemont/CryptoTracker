import 'package:cryptotracker/models/news.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class NewsList extends StatefulWidget {
  final List<News> listings;
  final Function? onScrollEnd;
  const NewsList({super.key, required this.listings, this.onScrollEnd});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.listings.length,
        itemBuilder: (BuildContext context, int index) {
          if (index >= widget.listings.length - 5) {
            if (widget.onScrollEnd != null) {
              widget.onScrollEnd!();
            }
          }
          return GestureDetector(
              onTap: () {
                Uri url = Uri.parse(widget.listings[index].url ?? "");
                url = url.replace(queryParameters: {
                  "utm_source": "",
                  "utm_medium": "",
                });
                launchUrl(url);
              },
              child: Card(
                elevation: 50,
                child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 400,
                          height: 200,
                          child: Image.network(
                              widget.listings[index].imgUrl ?? ""),
                        ),
                        Text(
                          widget.listings[index].source ?? "",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 13),
                        Text(
                          textAlign: TextAlign.center,
                          widget.listings[index].title ?? "",
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }
}
