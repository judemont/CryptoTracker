import 'package:cryptotracker/models/portfolio.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/widgets/new_portfolio_dialog.dart';
import 'package:cryptotracker/widgets/edit_portfolio_dialog.dart';
import 'package:flutter/material.dart';

class PortfolioSelector extends StatefulWidget {
  final Function(int) onPortfolioSelected;
  final int selectedPortfolioID;
  final List<Portfolio> portfolios;
  final Function loadPortfolios;
  const PortfolioSelector({
    super.key,
    required this.onPortfolioSelected,
    required this.selectedPortfolioID,
    required this.portfolios,
    required this.loadPortfolios,
  });

  @override
  State<PortfolioSelector> createState() => _PortfolioSelectorState();
}

class _PortfolioSelectorState extends State<PortfolioSelector> {
  @override
  Widget build(BuildContext context) {
    final selectedPortfolio = widget.portfolios.firstWhere(
      (el) => el.id == widget.selectedPortfolioID,
      orElse: () => Portfolio(name: "-"),
    );

    return ElevatedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(selectedPortfolio.name ?? ""),
            Icon(Icons.arrow_downward),
          ],
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, bottomSheetSetState) {
                  return FutureBuilder<List<Portfolio>>(
                    future: DatabaseService.getPortfolios(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 300,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      List<Portfolio> currentPortfolios = snapshot.data ?? [];

                      return Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 200,
                              child: ListView.builder(
                                itemCount: currentPortfolios.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.all(10),
                                    title: Text(
                                        currentPortfolios[index].name ?? "",
                                        style: TextStyle(fontSize: 20)),
                                    leading: Icon(Icons.pie_chart),
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditPortfolioDialog(
                                            portfolio: currentPortfolios[index],
                                            onPortfolioUpdated: () async {
                                              await widget.loadPortfolios();
                                              bottomSheetSetState(() {});
                                            },
                                          );
                                        },
                                      );
                                    },
                                    onTap: () {
                                      widget.onPortfolioSelected(
                                          currentPortfolios[index].id!);
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                            ),
                            Divider(),
                            ListTile(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return NewPortfolioDialog(
                                        onAddPortfolio: () async {
                                      await widget.loadPortfolios();
                                      bottomSheetSetState(() {});
                                    });
                                  },
                                );
                              },
                              title: Text("New Portfolio"),
                              leading: Icon(Icons.add),
                              contentPadding: EdgeInsets.all(15),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        });
  }
}
