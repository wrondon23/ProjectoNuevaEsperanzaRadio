import 'package:flutter/material.dart';
import 'package:radio_nueva_esperanza/admin/services/dashboard_service.dart';

class LiveSessionsTable extends StatelessWidget {
  final DashboardService service;

  const LiveSessionsTable({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Usuarios en Vivo por Ubicación",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                StreamBuilder<int>(
                    stream: service.getActiveSessionsCount(),
                    builder: (context, snapshot) {
                      return Chip(
                        label: Text(
                          "${snapshot.data ?? 0} Online",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.teal,
                      );
                    }),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: service.getActiveSessions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No hay usuarios activos en este momento."),
                    ),
                  );
                }

                final sessions = snapshot.data!;
                final groupedData = _groupSessions(sessions);

                return SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columns: const [
                      DataColumn(
                          label: Text('País',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Ciudad',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Usuarios',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: groupedData.map((data) {
                      return DataRow(cells: [
                        DataCell(
                          Row(
                            children: [
                              const Icon(Icons.public,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(data['country']),
                            ],
                          ),
                        ),
                        DataCell(Text(data['city'])),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              data['count'].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Agrupa sesiones por País y Ciudad
  List<Map<String, dynamic>> _groupSessions(
      List<Map<String, dynamic>> sessions) {
    final Map<String, Map<String, int>> grouped = {};

    for (var session in sessions) {
      final country = session['country'] ?? 'Desconocido';
      final city = session['city'] ?? 'Desconocido';

      grouped.putIfAbsent(country, () => {});
      grouped[country]![city] = (grouped[country]![city] ?? 0) + 1;
    }

    final List<Map<String, dynamic>> result = [];
    grouped.forEach((country, cities) {
      cities.forEach((city, count) {
        result.add({
          'country': country,
          'city': city,
          'count': count,
        });
      });
    });

    // Ordenar por cantidad de usuarios (descendente)
    result.sort((a, b) => b['count'].compareTo(a['count']));

    return result;
  }
}
