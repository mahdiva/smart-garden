import 'package:flutter/material.dart';

class NumberInputDialog extends StatefulWidget {
  final Function(double) onNumberEntered;

  const NumberInputDialog({required this.onNumberEntered});

  @override
  _NumberInputDialogState createState() => _NumberInputDialogState();
}

class _NumberInputDialogState extends State<NumberInputDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  void _validateInput() {
    final input = _controller.text;
    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a value';
      });
      return;
    }

    final parsed = double.tryParse(input);
    if (parsed == null) {
      setState(() {
        _errorMessage = 'Please enter a valid decimal number';
      });
      return;
    }

    widget.onNumberEntered(parsed);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter the target value'),
      content: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: (_) => _errorMessage,
        onChanged: (_) => setState(() {
          _errorMessage = null;
        }),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Save'),
          onPressed: _validateInput,
        ),
      ],
    );
  }
}
