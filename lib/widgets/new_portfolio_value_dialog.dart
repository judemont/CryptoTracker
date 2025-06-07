import 'package:cryptotracker/models/crypto.dart';
import 'package:cryptotracker/screens/settings.dart';
import 'package:cryptotracker/services/coins_api.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:flutter/material.dart';

class NewPortfolioValueDialog extends StatefulWidget {
  final int portfolioID;
  final Function onAddCoin;
  const NewPortfolioValueDialog(
      {super.key, required this.onAddCoin, required this.portfolioID});

  @override
  State<NewPortfolioValueDialog> createState() =>
      _NewPortfolioValueDialogState();
}

class _NewPortfolioValueDialogState extends State<NewPortfolioValueDialog> {
  TextEditingController coinNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add coin to your portfolio"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Enter coin name"),
          Autocomplete(
            optionsBuilder: (TextEditingValue textEditingValue) async {
              List<Crypto>? coins =
                  await getListings(search: textEditingValue.text);

              if (coins == null) {
                return const Iterable<String>.empty();
              }
              return coins.map((e) => e.id!.toCapitalized());
            },
            onSelected: (option) {
              setState(() {
                coinNameController.text = option;
              });
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
              return TextField(
                  onChanged: (value) {
                    setState(() {
                      coinNameController.text = value;
                    });
                  },
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    hintText: "Bitcoin",
                  ));
            },
          ),
          const SizedBox(height: 20),
          const Text("Enter amount"),
          TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: "3.5")),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            // try {
            String name = coinNameController.text.toLowerCase();
            double amount = double.parse(amountController.text);

            Crypto? coin = await getCoinData(name);
            if (coin == null) {
              throw Exception("Invalid coin");
            }
            if (amount <= 0) {
              throw Exception("Invalid amount");
            }
            DatabaseService.newPortfolioCoin(name, amount, widget.portfolioID);
            widget.onAddCoin();
            /*  } catch (e) {
              print(e);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Invalid coin or amount"),
                ),
              );
            }*/
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
