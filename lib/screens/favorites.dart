import 'dart:async';
import 'package:cryptotracker/models/crypto.dart';
import 'package:cryptotracker/services/coins_api.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:flutter/material.dart';
import '../widgets/coins_list.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List<Crypto> listings = [];
  bool isLoading = false;
  bool loadingError = false;
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
    loadListings();
    updateTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => checkForUpdates());
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              child: !loadingError
                  ? (!isLoading
                      ? (listings.isNotEmpty
                          ? CoinsList(listings: listings)
                          : const Center(child: Text("No favorites yet")))
                      : const Center(child: CircularProgressIndicator()))
                  : Center(
                      child: ElevatedButton(
                        child: const Text("Try again"),
                        onPressed: () {
                          setState(() {
                            loadingError = false;
                          });
                          loadListings();
                        },
                      ),
                    ),
              onRefresh: () async {
                await loadListings();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadListings({order = "market_cap_desk"}) async {
    setState(() {
      isLoading = true;
    });

    try {
      List<String> favorites = await DatabaseService.getFavorites();
      List<Crypto> cryptoLists = [];

      for (var id in favorites) {
        Crypto? value = await getCoinData(id);
        if (value != null) {
          cryptoLists.add(value);
        }
      }

      setState(() {
        listings = cryptoLists;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        loadingError = true;
        isLoading = false;
      });
    }
  }

  Future<void> checkForUpdates() async {
    try {
      List<String?> currentIds = listings.map((c) => c.id).toList();
      List<String> latestFavorites = await DatabaseService.getFavorites();

      // Reload only if there's a change
      if (!_listsEqual(currentIds, latestFavorites)) {
        await loadListings();
      }
    } catch (_) {}
  }

  bool _listsEqual(List<String?> a, List<String> b) {
    if (a.length != b.length) return false;
    final sortedA = List<String>.from(a)..sort();
    final sortedB = List<String>.from(b)..sort();
    for (int i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }
    return true;
  }
}
