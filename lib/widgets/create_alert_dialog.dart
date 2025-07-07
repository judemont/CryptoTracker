import 'package:flutter/material.dart';
import 'package:cryptotracker/services/alert_service.dart';
import 'package:cryptotracker/services/settingsDB.dart';

class CreateAlertDialog extends StatefulWidget {
  final String cryptoId;
  final String cryptoName;
  final double? currentPrice;
  final VoidCallback? onAlertCreated;

  const CreateAlertDialog({
    super.key,
    required this.cryptoId,
    required this.cryptoName,
    this.currentPrice,
    this.onAlertCreated,
  });

  @override
  State<CreateAlertDialog> createState() => _CreateAlertDialogState();
}

class _CreateAlertDialogState extends State<CreateAlertDialog> {
  final TextEditingController _aboveController = TextEditingController();
  final TextEditingController _belowController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Pre-fill with current price as reference
    if (widget.currentPrice != null) {
      _aboveController.text = (widget.currentPrice! * 1.1).toStringAsFixed(2);
      _belowController.text = (widget.currentPrice! * 0.9).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = SettingsDb.getValue("settings", "currencySymbol");
    
    return AlertDialog(
      title: Text('Create Price Alert for ${widget.cryptoName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.currentPrice != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Current Price: $currencySymbol${widget.currentPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const Text('Alert me when price goes above:'),
            const SizedBox(height: 8),
            TextField(
              controller: _aboveController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter threshold price',
                prefixText: currencySymbol,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Alert me when price goes below:'),
            const SizedBox(height: 8),
            TextField(
              controller: _belowController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter threshold price',
                prefixText: currencySymbol,
                border: const OutlineInputBorder(),
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Note: Leave fields empty if you don\'t want that type of alert',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createAlert,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Alert'),
        ),
      ],
    );
  }

  Future<void> _createAlert() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      double? thresholdAbove;
      double? thresholdBelow;

      if (_aboveController.text.isNotEmpty) {
        thresholdAbove = double.tryParse(_aboveController.text);
        if (thresholdAbove == null) {
          throw Exception('Invalid threshold above value');
        }
      }

      if (_belowController.text.isNotEmpty) {
        thresholdBelow = double.tryParse(_belowController.text);
        if (thresholdBelow == null) {
          throw Exception('Invalid threshold below value');
        }
      }

      if (thresholdAbove == null && thresholdBelow == null) {
        throw Exception('At least one threshold must be provided');
      }

      await AlertService.createAlert(
        cryptoId: widget.cryptoId,
        cryptoName: widget.cryptoName,
        thresholdAbove: thresholdAbove,
        thresholdBelow: thresholdBelow,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onAlertCreated?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Price alert created for ${widget.cryptoName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _aboveController.dispose();
    _belowController.dispose();
    super.dispose();
  }
}