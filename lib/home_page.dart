import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'crud_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.crudService});

  final CrudService crudService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CrudService get crudService => widget.crudService;
  late final items = crudService.getItems();
  bool showFavorites = false;

  void showItemDialog({String? id, String name = '', int? quantity}) {
    showDialog<void>(
      context: context,
      builder: (context) => _ItemDialog(
        name: name,
        quantity: quantity,
        isEditing: id != null,
        onSave: (name, quantity) {
          if (id == null) return crudService.addItem(name, quantity);
          return crudService.updateItem(id, name, quantity);
        },
      ),
    );
  }

  Future<void> runItemAction(
    Future<void> Function() action,
    String errorMessage,
  ) async {
    try {
      await action();
    } on FirebaseException {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> showDeleteDialog(String id) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (delete == true && mounted) {
      await runItemAction(
        () => crudService.deleteItem(id),
        'Could not delete the item. Try again.',
      );
    }
  }

  Widget itemCard(QueryDocumentSnapshot<Map<String, dynamic>> item) {
    final data = item.data();
    final name = data['name'] as String;
    final quantity = data['quantity'] as int;
    final isFavorite = data['isFavorite'] == true;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Quantity $quantity',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () => runItemAction(
                () => crudService.setFavorite(item.id, !isFavorite),
                'Could not update the favorite. Try again.',
              ),
            ),
            IconButton(
              tooltip: 'Edit $name',
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () =>
                  showItemDialog(id: item.id, name: name, quantity: quantity),
            ),
            IconButton(
              tooltip: 'Delete $name',
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => showDeleteDialog(item.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Firebase | Montejo'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: showFavorites ? 'Show all items' : 'Show favorites',
            icon: Icon(
              showFavorites ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                showFavorites = !showFavorites;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: items,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load items'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data!.docs;
          final visibleItems = showFavorites
              ? documents
                    .where((item) => item.data()['isFavorite'] == true)
                    .toList()
              : documents;

          if (visibleItems.isEmpty) {
            return Center(
              child: Text(
                showFavorites ? 'No favorites found' : 'No items found',
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
            itemCount: visibleItems.length,
            itemBuilder: (context, index) => itemCard(visibleItems[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add item',
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: showItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ItemDialog extends StatefulWidget {
  const _ItemDialog({
    required this.name,
    required this.quantity,
    required this.isEditing,
    required this.onSave,
  });

  final String name;
  final int? quantity;
  final bool isEditing;
  final Future<void> Function(String, int) onSave;

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  final formKey = GlobalKey<FormState>();
  late final nameController = TextEditingController(text: widget.name);
  late final quantityController = TextEditingController(
    text: widget.quantity?.toString(),
  );
  bool saving = false;
  String? saveError;

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving || !formKey.currentState!.validate()) return;
    final name = nameController.text.trim();
    final quantity = int.parse(quantityController.text.trim());
    setState(() {
      saving = true;
      saveError = null;
    });
    try {
      await widget.onSave(name, quantity);
      if (mounted) Navigator.pop(context);
    } on FirebaseException {
      if (!mounted) return;
      setState(() {
        saving = false;
        saveError = 'Could not save the item. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );

    return PopScope(
      canPop: !saving,
      child: AlertDialog(
        scrollable: true,
        title: Text(widget.isEditing ? 'Edit Item' : 'Add Item'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                readOnly: saving,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: border,
                ),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                readOnly: saving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: border,
                ),
                validator: (value) {
                  final quantity = int.tryParse(value!.trim());
                  if (quantity == null || quantity < 0) {
                    return 'Enter a whole number of 0 or more';
                  }
                  return null;
                },
              ),
              if (saveError != null) ...[
                const SizedBox(height: 12),
                Text(
                  saveError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isEditing ? Colors.orange : Colors.teal,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: saving ? null : save,
            child: Text(
              saving ? 'Saving…' : (widget.isEditing ? 'Edit' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}
