import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'metadata_registry.dart';
import 'crud_form_view.dart';

class CrudTableView extends StatelessWidget {
  final AdminModule module;

  const CrudTableView({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              module.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF142F30),
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CrudFormView(module: module)),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Nuevo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Data Grid
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(module.collectionPath)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(module.icon,
                            size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text('No hay ${module.title} registrados.',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;

                    // Try to find a meaningful title field
                    String displayTitle = 'Elemento sin título';
                    String subtitle = '';

                    if (data.containsKey('title')) {
                      displayTitle = data['title'];
                    } else if (data.containsKey('name')) {
                      displayTitle = data['name'];
                    } else if (data.containsKey('content')) {
                      displayTitle = (data['content'] as String).length > 50
                          ? '${(data['content'] as String).substring(0, 50)}...'
                          : data['content'];
                    }

                    // Try to find date or description for subtitle
                    if (data.containsKey('date')) {
                      final date = data['date'];
                      if (date is Timestamp) {
                        subtitle = date.toDate().toString().split(' ')[0];
                      }
                    } else if (data.containsKey('description')) {
                      subtitle = (data['description'] as String).length > 50
                          ? '${(data['description'] as String).substring(0, 50)}...'
                          : data['description'];
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      title: Text(displayTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: subtitle.isNotEmpty
                          ? Text(subtitle)
                          : Text('ID: $id'),
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(module.icon,
                            color: Theme.of(context).primaryColor),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CrudFormView(
                                    module: module,
                                    documentId: id,
                                    initialData: data,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmar eliminación'),
                                  content: const Text(
                                      '¿Estás seguro de eliminar este registro?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Eliminar',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection(module.collectionPath)
                                    .doc(id)
                                    .delete();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
