import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'metadata_registry.dart';

class CrudFormView extends StatefulWidget {
  final AdminModule module;
  final String? documentId; // If null, creating new. If set, editing.
  final Map<String, dynamic>? initialData;

  const CrudFormView(
      {super.key, required this.module, this.documentId, this.initialData});

  @override
  State<CrudFormView> createState() => _CrudFormViewState();
}

class _CrudFormViewState extends State<CrudFormView> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _formData.addAll(widget.initialData!);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final collection =
          FirebaseFirestore.instance.collection(widget.module.collectionPath);

      if (widget.documentId == null) {
        // Create
        await collection.add(_formData);
      } else {
        // Update
        await collection.doc(widget.documentId).update(_formData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guardado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentId == null
            ? 'Crear ${widget.module.title}'
            : 'Editar ${widget.module.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ...widget.module.fields.map(_buildField),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Guardar",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(FieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          _buildInputWidget(field),
        ],
      ),
    );
  }

  Widget _buildInputWidget(FieldConfig field) {
    switch (field.type) {
      case FieldType.text:
      case FieldType.multiline:
        return TextFormField(
          initialValue: _formData[field.name]?.toString(),
          maxLines: field.type == FieldType.multiline ? 4 : 1,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Ingrese ${field.label.toLowerCase()}',
          ),
          validator: (value) {
            if (field.required && (value == null || value.isEmpty)) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
          onSaved: (value) => _formData[field.name] = value,
        );

      case FieldType.date:
        // Date + Time Picker Trigger
        return FormField<DateTime>(
          initialValue: _formData[field.name] is Timestamp
              ? (_formData[field.name] as Timestamp).toDate()
              : null,
          validator: (value) {
            if (field.required && value == null) return 'Seleccione una fecha';
            return null;
          },
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final initial = state.value ?? DateTime.now();
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      if (context.mounted) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(initial),
                        );

                        if (pickedTime != null) {
                          final combined = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          state.didChange(combined);
                          _formData[field.name] = Timestamp.fromDate(combined);
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    state.value == null
                        ? 'Seleccionar Fecha y Hora'
                        : DateFormat('yyyy-MM-dd hh:mm a').format(state.value!),
                  ),
                ),
                if (state.hasError)
                  Text(state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            );
          },
        );

      case FieldType.image:
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
                "Subida de Imágenes: Pendiente de implementación (Requiere Firebase Storage)"),
          ),
        );

      default:
        return const Text("Tipo de campo no soportado");
    }
  }
}
