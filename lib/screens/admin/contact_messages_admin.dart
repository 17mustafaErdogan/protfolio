import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';

/// Admin paneli — iletişim mesajları ekranı.
class ContactMessagesAdminScreen extends StatefulWidget {
  const ContactMessagesAdminScreen({super.key});

  @override
  State<ContactMessagesAdminScreen> createState() =>
      _ContactMessagesAdminScreenState();
}

class _ContactMessagesAdminScreenState
    extends State<ContactMessagesAdminScreen> {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = context.read<DataService>();
    final msgs = await ds.getContactMessages();
    if (mounted) {
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(String id) async {
    final ds = context.read<DataService>();
    ds.clearError();
    final ok = await ds.markMessageAsRead(id);
    if (!mounted) return;
    if (ok) {
      setState(() {
        final idx = _messages.indexWhere((m) => m['id'].toString() == id);
        if (idx != -1) {
          _messages[idx] = {..._messages[idx], 'is_read': true};
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ds.errorMessage ?? 'Okundu işaretlenemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _delete(String id) async {
    final ds = context.read<DataService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Mesajı Sil'),
        content: const Text('Bu mesajı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    ds.clearError();
    final ok = await ds.deleteContactMessage(id);
    if (!mounted) return;
    if (ok) {
      setState(() => _messages.removeWhere((m) => m['id'].toString() == id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesaj silindi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ds.errorMessage ?? 'Mesaj silinemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDetail(Map<String, dynamic> msg) {
    final id = msg['id'].toString();
    if (msg['is_read'] == false) _markRead(id);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(msg['subject'] ?? '(Konusuz)'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('Gönderen', msg['name'] ?? ''),
              _infoRow('E-posta', msg['email'] ?? ''),
              _infoRow('Tarih', _formatDate(msg['created_at'])),
              const Divider(height: Spacing.xl),
              Text(
                msg['message'] ?? '',
                style: const TextStyle(color: AppTheme.textPrimary, height: 1.6),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İletişim Mesajları',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Ziyaretçilerden gelen mesajlar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Yenile',
                onPressed: () {
                  setState(() => _isLoading = true);
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: Spacing.xxl),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_messages.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xxl),
                child: Column(
                  children: [
                    const Icon(Icons.inbox_outlined,
                        size: 48, color: AppTheme.textMuted),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'Henüz mesaj yok',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                final isUnread = msg['is_read'] == false;
                return _MessageCard(
                  message: msg,
                  isUnread: isUnread,
                  onTap: () => _showDetail(msg),
                  onDelete: () => _delete(msg['id'].toString()),
                  formatDate: _formatDate,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatefulWidget {
  final Map<String, dynamic> message;
  final bool isUnread;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String Function(dynamic) formatDate;

  const _MessageCard({
    required this.message,
    required this.isUnread,
    required this.onTap,
    required this.onDelete,
    required this.formatDate,
  });

  @override
  State<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<_MessageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: _isHovered ? AppTheme.surfaceLight : AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isUnread
                  ? AppTheme.accent.withOpacity(0.4)
                  : AppTheme.border,
            ),
          ),
          child: Row(
            children: [
              // Okunmamış göstergesi
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.isUnread
                      ? AppTheme.accent
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.message['name'] ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: widget.isUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                        ),
                        Text(
                          widget.formatDate(widget.message['created_at']),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.message['subject'] ?? '(Konusuz)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.isUnread
                                ? AppTheme.textSecondary
                                : AppTheme.textMuted,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.message['message'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.md),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppTheme.textMuted,
                tooltip: 'Sil',
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
