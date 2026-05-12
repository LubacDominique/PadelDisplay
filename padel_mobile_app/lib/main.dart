import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ble_service.dart';
import 'screens/player_setup_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BLEService(),
      child: const PadelApp(),
    ),
  );
}

class PadelApp extends StatelessWidget {
  const PadelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Padel Display',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bleService = context.watch<BLEService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Padel Display'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
            tooltip: 'Historique',
          ),
          Icon(
            bleService.isConnected 
                ? Icons.bluetooth_connected 
                : Icons.bluetooth_disabled,
            color: bleService.isConnected ? Colors.blue : Colors.red,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_tennis,
                size: 100,
                color: Colors.blue.shade300,
              ),
              const SizedBox(height: 40),
              
              if (!bleService.isConnected) ...[
                const Text(
                  'Non connecté au tableau',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                
                if (bleService.isScanning)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Recherche en cours...'),
                    ],
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      await bleService.startScan();
                    },
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text('Rechercher tableau'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (bleService.discoveredDevices.isNotEmpty) ...[
                    const Text(
                      'Appareils trouvés:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ...bleService.discoveredDevices.map((device) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.bluetooth),
                          title: Text(device.name.isNotEmpty 
                              ? device.name 
                              : 'Appareil inconnu'),
                          subtitle: Text(device.id.toString()),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final success = await bleService.connect(device);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Connecté avec succès'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: const Text('Connecter'),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ] else ...[
                const Text(
                  '✅ Connecté au tableau',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlayerSetupScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Démarrer un match'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                OutlinedButton.icon(
                  onPressed: () async {
                    await bleService.disconnect();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Déconnecté'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.bluetooth_disabled),
                  label: const Text('Déconnecter'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
