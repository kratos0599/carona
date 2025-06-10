import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class RideRequestsScreen extends StatefulWidget {
  final int rideId;

  const RideRequestsScreen({super.key, required this.rideId});

  @override
  State<RideRequestsScreen> createState() => _RideRequestsScreenState();
}

class _RideRequestsScreenState extends State<RideRequestsScreen> {
  Map<String, dynamic>? _ride;
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRideRequests();
  }

  Future<void> _loadRideRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Buscar informações da carona
      final rideResponse = await ApiService.getRide(widget.rideId);
      
      if (!rideResponse['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(rideResponse['message'])),
          );
        }
        return;
      }

      // Buscar solicitações da carona
      final requestsResponse = await ApiService.getRideRequests(widget.rideId);
      
      if (requestsResponse['success']) {
        setState(() {
          _ride = rideResponse['data'];
          _requests = requestsResponse['data'] ?? [];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(requestsResponse['message'])),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar solicitações: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _respondToRequest(int requestId, String action) async {
    try {
      final response = await ApiService.respondToRideRequest(int.parse(requestId.toString()), action);
      
      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                action == 'accept' 
                    ? 'Solicitação aceita!' 
                    : 'Solicitação recusada!',
              ),
              backgroundColor: action == 'accept' ? Colors.green : Colors.orange,
            ),
          );
          _loadRideRequests(); // Recarregar lista
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao responder solicitação: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendente';
      case 'accepted':
        return 'Aceita';
      case 'rejected':
        return 'Recusada';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Solicitações')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_ride == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Solicitações')),
        body: const Center(child: Text('Carona não encontrada')),
      );
    }

    final departureTime = DateTime.parse(_ride!['departure_time']);
    final formattedDate = DateFormat('dd/MM/yyyy').format(departureTime);
    final formattedTime = DateFormat('HH:mm').format(departureTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Informações da carona
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informações da Carona',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.my_location, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_ride!['origin'])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_ride!['destination'])),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.blue[600], size: 16),
                        const SizedBox(width: 4),
                        Text('$formattedDate às $formattedTime'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 4),
                        Text('${int.parse(_ride!['available_seats'].toString())} vagas'),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'R\$ ${double.parse(_ride!['price'].toString()).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1),

          // Lista de solicitações
          Expanded(
            child: _requests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return _buildRequestCard(request);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma solicitação',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você ainda não recebeu solicitações para esta carona',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final createdAt = DateTime.parse(request['created_at']);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com usuário e status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    request['passenger']['name'].substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['passenger']['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (request['passenger']['phone'] != null)
                        Text(
                          request['passenger']['phone'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(request['status'])),
                  ),
                  child: Text(
                    _getStatusText(request['status']),
                    style: TextStyle(
                      color: _getStatusColor(request['status']),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            // Mensagem (se houver)
            if (request['message'] != null && request['message'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mensagem:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request['message'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],

            // Data da solicitação
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
                Text(
                  'Solicitado em $formattedDate',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // Botões de ação (apenas para solicitações pendentes)
            if (request['status'].toLowerCase() == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                                             onPressed: () => _respondToRequest(int.parse(request['id'].toString()), 'reject'),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text(
                        'Recusar',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                                             onPressed: () => _respondToRequest(int.parse(request['id'].toString()), 'accept'),
                      icon: const Icon(Icons.check),
                      label: const Text('Aceitar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
} 