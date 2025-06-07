import 'package:cryptotracker/services/database.dart';
import 'package:flutter/material.dart';

class NewPortfolioDialog extends StatefulWidget {
  final Function onAddPortfolio;
  const NewPortfolioDialog({super.key, required this.onAddPortfolio});

  @override
  State<NewPortfolioDialog> createState() => _NewPortfolioDialogState();
}

class _NewPortfolioDialogState extends State<NewPortfolioDialog> {
  TextEditingController portfolioNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New portfolio"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Enter portfolio name"),
          TextField(
              controller: portfolioNameController,
              decoration: const InputDecoration(
                hintText: "Portfolio name",
              )),
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
            String name = portfolioNameController.text.toLowerCase();

            DatabaseService.newPortfolio(name);
            widget.onAddPortfolio();

            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
