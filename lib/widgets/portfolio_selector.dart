import 'package:cryptotracker/models/portfolio.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/widgets/new_portfolio_dialog.dart';
import 'package:flutter/material.dart';

class PortfolioSelector extends StatefulWidget {
  final Function(int) onPortfolioSelected;
  final int selectedPortfolioID;
  const PortfolioSelector({
    super.key,
    required this.onPortfolioSelected,
    required this.selectedPortfolioID,
  });

  @override
  State<PortfolioSelector> createState() => _PortfolioSelectorState();
}

class _PortfolioSelectorState extends State<PortfolioSelector> {
  List<Portfolio> portfolios = [];
  TextEditingController nameController = TextEditingController();

  Future<void> loadPortfolios() async {
    print("LOAD PORFOLIO! ");
    List<Portfolio> portfoliosDB = await DatabaseService.getPortfolios();
    setState(() {
      portfolios = portfoliosDB;
    });
    print(portfolios);
  }

  @override
  void initState() {
    loadPortfolios();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (portfolios.isEmpty) {
      return const CircularProgressIndicator();
    }

    final selectedPortfolio = portfolios.firstWhere(
      (el) => el.id == widget.selectedPortfolioID,
      orElse: () => portfolios.first,
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
            builder: (context) {
              return StatefulBuilder(
                builder: (context, bottomSheetSetState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: portfolios.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              contentPadding: EdgeInsets.all(10),
                              title: Text(portfolios[index].name ?? "",
                                  style: TextStyle(fontSize: 20)),
                              leading: Icon(Icons.pie_chart),
                              onLongPress: () {
                                nameController = TextEditingController(
                                    text: portfolios[index].name);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                          "Edit ${portfolios[index].name}"),
                                      content: TextField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                            hintText: "Portfolio Name"),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Confirm deletion"),
                                                  content: Text(
                                                    "Are you sure you want to delete '${portfolios[index].name}'?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        await DatabaseService
                                                            .removePortfolio(
                                                                portfolios[
                                                                        index]
                                                                    .id!);
                                                        await loadPortfolios();
                                                        if (mounted) {
                                                          bottomSheetSetState(
                                                              () {});
                                                          Navigator.of(context)
                                                              .pop(); // close confirm dialog
                                                          Navigator.of(context)
                                                              .pop(); // close edit dialog
                                                        }
                                                      },
                                                      child:
                                                          const Text("Delete"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: const Text("Remove"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if (nameController
                                                .text.isNotEmpty) {
                                              await DatabaseService
                                                  .updatePortfolio(
                                                      portfolios[index].id!,
                                                      nameController.text);
                                              await loadPortfolios();
                                              if (mounted) {
                                                bottomSheetSetState(() {});
                                                Navigator.of(context).pop();
                                              }
                                            }
                                          },
                                          child: const Text("Save"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              onTap: () {
                                widget
                                    .onPortfolioSelected(portfolios[index].id!);
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
                                await loadPortfolios();
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
                  );
                },
              );
            },
          );
        });
  }
}
