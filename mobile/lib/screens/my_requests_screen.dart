import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({Key? key}) : super(key: key);

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyRequests();
  }

  Future<void> _loadMyRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getMyRequests();
      
      if (response['success']) {
        setState(() {
          _requests = response['data'] ?? [];
        });
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
          SnackBar(content: Text('Erro ao carregar solicitações: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelRequest(int requestId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar cancelamento'),
          content: const Text('Tem certeza que deseja cancelar esta solicitação?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Não'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sim, cancelar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final response = await ApiService.cancelRideRequest(requestId);
        
        if (response['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solicitação cancelada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadMyRequests(); // Recarregar lista
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
            SnackBar(content: Text('Erro ao cancelar solicitação: $e')),
          );
        }
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
        return 'Rejeitada';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Solicitações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadMyRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return _buildRequestCard(request);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.request_page,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma solicitação encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você ainda não fez nenhuma solicitação de carona',
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
    final ride = request['ride'];
    final driver = ride['driver'];
    final status = request['status'] ?? 'pending';
    final createdAt = DateTime.parse(request['created_at']);
    final departureTime = DateTime.parse(ride['departure_time']);
    
    final formattedRequestDate = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
    final formattedDepartureDate = DateFormat('dd/MM/yyyy').format(departureTime);
    final formattedDepartureTime = DateFormat('HH:mm').format(departureTime);
    
    final canCancel = status == 'pending';
    final isPastDate = departureTime.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 16,
                        color: _getStatusColor(status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(status),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canCancel)
                  TextButton.icon(
                    onPressed: () => _cancelRequest(int.parse(request['id'].toString())),
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    label: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),

            // Informações da carona
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
                  // Rota
                  Row(
                    children: [
                      Icon(Icons.my_location, color: Colors.green[600], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ride['origin'],
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red[600], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ride['destination'],
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Data e hora da viagem
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: isPastDate ? Colors.grey : Colors.blue[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$formattedDepartureDate às $formattedDepartureTime',
                        style: TextStyle(
                          color: isPastDate ? Colors.grey : Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Motorista
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Motorista: ${driver['name']}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Preço
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.green[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'R\$ ${double.parse(ride['price'].toString()).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Mensagem da solicitação (se houver)
            if (request['message'] != null && request['message'].isNotEmpty) ...[
              Text(
                'Mensagem enviada:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  request['message'],
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Data da solicitação
            Text(
              'Solicitação feita em: $formattedRequestDate',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 