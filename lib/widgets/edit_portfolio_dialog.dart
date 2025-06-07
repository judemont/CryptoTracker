import 'package:cryptotracker/models/portfolio.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:flutter/material.dart';

class EditPortfolioDialog extends StatefulWidget {
  final Portfolio portfolio;
  final VoidCallback onPortfolioUpdated;

  const EditPortfolioDialog({
    super.key,
    required this.portfolio,
    required this.onPortfolioUpdated,
  });

  @override
  State<EditPortfolioDialog> createState() => _EditPortfolioDialogState();
}

class _EditPortfolioDialogState extends State<EditPortfolioDialog> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.portfolio.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _updatePortfolio() async {
    if (nameController.text.isNotEmpty) {
      await DatabaseService.updatePortfolio(
        widget.portfolio.id!,
        nameController.text,
      );
      widget.onPortfolioUpdated();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _deletePortfolio() async {
    await DatabaseService.removePortfolio(widget.portfolio.id!);
    widget.onPortfolioUpdated();
    if (mounted) {
      Navigator.of(context).pop(); // Close confirmation dialog
      Navigator.of(context).pop(); // Close edit dialog
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm deletion"),
          content: Text(
            "Are you sure you want to delete '${widget.portfolio.name}'?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: _deletePortfolio,
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit ${widget.portfolio.name}"),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          hintText: "Portfolio Name",
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: _showDeleteConfirmation,
          child: const Text(
            "Remove",
            style: TextStyle(color: Colors.red),
          ),
        ),
        FilledButton(
          onPressed: _updatePortfolio,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
