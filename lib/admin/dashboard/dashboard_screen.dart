import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  final bool isEmulator;

  const DashboardScreen({super.key, this.isEmulator = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _service = DashboardService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildKPICards(),
          const SizedBox(height: 20),
          _buildChartsSection(),
          const SizedBox(height: 20),
          if (widget.isEmulator) _buildEmulatorControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Resumen de Actividad",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF142F30),
                  ),
            ),
            Text(
              "Estadísticas en tiempo real",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        if (widget.isEmulator)
          Chip(
            label: const Text("MODO EMULADOR"),
            backgroundColor: Colors.amber.shade100,
            avatar: const Icon(Icons.bug_report, size: 16),
          ),
      ],
    );
  }

  Widget _buildKPICards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = width > 1200 ? 4 : (width > 800 ? 2 : 1);
        double childAspectRatio = width > 1200 ? 1.5 : 2.5;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _KpiCard(
              title: "Anuncios",
              icon: Icons.campaign,
              color: Colors.blue,
              stream: _service.getCollectionCount('announcements'),
            ),
            _KpiCard(
              title: "Actividades",
              icon: Icons.event,
              color: Colors.orange,
              stream: _service.getCollectionCount('activities'),
            ),
            _KpiCard(
              title: "Conferencias",
              icon: Icons.mic,
              color: Colors.purple,
              stream: _service.getCollectionCount('conferences'),
            ),
            _KpiCard(
              title: "Dispositivos Activos",
              icon: Icons.devices,
              color: Colors.teal,
              stream: _service.getActiveSessionsCount(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _ActivityLineChart(service: _service)),
              const SizedBox(width: 20),
              Expanded(flex: 1, child: _CategoryPieChart()), // Mocked for now
            ],
          );
        } else {
          return Column(
            children: [
              _ActivityLineChart(service: _service),
              const SizedBox(height: 20),
              _CategoryPieChart(),
            ],
          );
        }
      },
    );
  }

  Widget _buildEmulatorControls() {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.science, color: Colors.amber),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Herramientas de Desarrollo",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Genera datos de prueba para visualizar el dashboard."),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await _service.seedSampleData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Datos de prueba generados!')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Insertar Seed Data"),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Stream<int>? stream;

  const _KpiCard({
    required this.title,
    required this.icon,
    required this.color,
    this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 5),
                if (stream != null)
                  StreamBuilder<int>(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      return Text(
                        '${snapshot.data ?? 0}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF142F30),
                        ),
                      );
                    },
                  )
                else
                  const Text(
                    '0',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF142F30),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityLineChart extends StatelessWidget {
  final DashboardService service;

  const _ActivityLineChart({required this.service});

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
            const Text(
              "Actividad (Últimos 7 días)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: StreamBuilder<List<DailyCount>>(
                stream: service
                    .getLast7DaysCounts('announcements'), // Example stream
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  final data = snapshot.data!;
                  // Map data to FlSpots
                  final spots = data.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.count.toDouble());
                  }).toList();

                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < data.length) {
                                return Text(
                                  "${data[index].date.day}/${data[index].date.month}",
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 30)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey.shade200)),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
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
            const Text("Tipos de Eventos",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                        color: Colors.blue,
                        value: 40,
                        title: 'Jóvenes',
                        radius: 50),
                    PieChartSectionData(
                        color: Colors.orange,
                        value: 30,
                        title: 'Niños',
                        radius: 50),
                    PieChartSectionData(
                        color: Colors.purple,
                        value: 15,
                        title: 'General',
                        radius: 50),
                    PieChartSectionData(
                        color: Colors.green,
                        value: 15,
                        title: 'Salud',
                        radius: 50),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
