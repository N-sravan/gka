import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/processing_step_model.dart';

class ThinkingContainerWidget extends StatefulWidget {
  final List<ProcessingStepModel> steps;
  final bool isProcessing;
  final int totalDuration;
  final bool includeDetails;
  final VoidCallback? onToggle;

  const ThinkingContainerWidget({
    Key? key,
    required this.steps,
    required this.isProcessing,
    required this.totalDuration,
    this.includeDetails = false,
    this.onToggle,
  }) : super(key: key);

  @override
  State<ThinkingContainerWidget> createState() =>
      _ThinkingContainerWidgetState();
}

class _ThinkingContainerWidgetState extends State<ThinkingContainerWidget>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  Map<String, bool> _detailsExpanded = {};
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isProcessing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ThinkingContainerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isProcessing != oldWidget.isProcessing) {
      if (widget.isProcessing) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _rotationController.reverse();
      } else {
        _rotationController.forward();
      }
    });
    // Don't call onToggle here as it should not hide the container
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (_isExpanded) _buildContent(),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isProcessing
                ? [Colors.orange.shade50, Colors.orange.shade100]
                : widget.steps.any((s) => s.status == StepStatus.error)
                    ? [Colors.red.shade50, Colors.red.shade100]
                    : [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(16),
            bottom: _isExpanded ? Radius.zero : const Radius.circular(16),
          ),
          border: Border.all(
            color: widget.isProcessing
                ? Colors.orange.shade200
                : widget.steps.any((s) => s.status == StepStatus.error)
                    ? Colors.red.shade200
                    : Colors.green.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildStatusIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isProcessing
                        ? '🔄 Processing query...'
                        : widget.steps.any((s) => s.status == StepStatus.error)
                            ? '❌ Processing failed'
                            : '✅ Processing complete',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.steps.length} steps • ${widget.totalDuration/1000}s',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (widget.isProcessing) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (widget.steps.any((s) => s.status == StepStatus.error)) {
      return Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      );
    } else {
      return Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      );
    }
  }

  Widget _buildContent() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: widget.steps.map((step) => _buildStepItem(step)).toList(),
        ),
      ),
    );
  }

  Widget _buildStepItem(ProcessingStepModel step) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
        color: _getStepBackgroundColor(step.status),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.displayName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (step.duration != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    step.durationText,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: Colors.grey[700],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildStatusIndicator(step.status),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  step.message,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          if (widget.includeDetails && step.details != null)
            _buildStepDetails(step),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(StepStatus status) {
    Color color;
    Widget? child;

    switch (status) {
      case StepStatus.pending:
        color = Colors.grey[400]!;
        break;
      case StepStatus.inProgress:
        color = Colors.orange;
        child = SizedBox(
          width: 8,
          height: 8,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
          ),
        );
        break;
      case StepStatus.completed:
        color = Colors.green;
        break;
      case StepStatus.error:
        color = Colors.red;
        break;
      case StepStatus.skipped:
        color = Colors.grey[600]!;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }

  Color _getStepBackgroundColor(StepStatus status) {
    switch (status) {
      case StepStatus.completed:
        return Colors.green.withOpacity(0.05);
      case StepStatus.inProgress:
        return Colors.orange.withOpacity(0.1);
      case StepStatus.error:
        return Colors.red.withOpacity(0.05);
      default:
        return Colors.transparent;
    }
  }

  Widget _buildStepDetails(ProcessingStepModel step) {
    final details = step.details!;
    final stepKey = step.name;
    final isExpanded = _detailsExpanded[stepKey] ?? false;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle button
          InkWell(
            onTap: () {
              setState(() {
                _detailsExpanded[stepKey] = !isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Detailed Information',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Collapsible content
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: details.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _buildDetailItem(entry.key, entry.value),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String key, dynamic value) {
    if (value is List && key == 'top_10_chunks') {
      return _buildChunksDetail(value);
    }

    // Handle different data types with better formatting
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getKeyIcon(key),
              const SizedBox(width: 6),
              Text(
                _formatKeyName(key),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildFormattedValue(value),
        ],
      ),
    );
  }

  Widget _getKeyIcon(String key) {
    IconData icon;
    Color color;

    switch (key.toLowerCase()) {
      case 'model_used':
      case 'vision_model':
        icon = Icons.smart_toy;
        color = Colors.purple;
        break;
      case 'chunks_retrieved':
      case 'results_count':
        icon = Icons.storage;
        color = Colors.blue;
        break;
      case 'language':
      case 'translated_query':
        icon = Icons.translate;
        color = Colors.green;
        break;
      case 'tokens_generated':
        icon = Icons.memory;
        color = Colors.orange;
        break;
      case 'search_query':
        icon = Icons.search;
        color = Colors.amber;
        break;
      case 'retrieval_type':
        icon = Icons.category;
        color = Colors.teal;
        break;
      case 'routing_confidence':
        icon = Icons.analytics;
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }

  String _formatKeyName(String key) {
    return key
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildFormattedValue(dynamic value) {
    if (value is String) {
      // Check if string contains structured data
      if (_isTableData(value) || _isStructuredTableData(value)) {
        return _buildRichDocumentContent(value, null);
      }
      // Check if it's a URL (image or link)
      if (_isImageUrl(value)) {
        return _buildImageFromUrl(value);
      }
      return _buildFormattedText(value);
    } else if (value is num) {
      return _buildNumericValue(value);
    } else if (value is Map) {
      return _buildMapValue(value);
    } else if (value is List) {
      return _buildListValue(value);
    } else {
      return Text(
        value.toString(),
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[700],
        ),
      );
    }
  }

  bool _isImageUrl(String text) {
    final uri = Uri.tryParse(text);
    if (uri == null) return false;
    final path = uri.path.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp');
  }

  Widget _buildImageFromUrl(String url) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          url,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 60,
            color: Colors.grey.shade200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(height: 2),
                  Text(
                    'Image failed to load',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 120,
              color: Colors.grey.shade100,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[800],
          fontFamily: text.length > 100 ? 'monospace' : null,
        ),
      ),
    );
  }

  Widget _buildNumericValue(num value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        value.toString(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade800,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildMapValue(Map map) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.data_object, size: 12, color: Colors.amber.shade700),
              const SizedBox(width: 4),
              Text(
                'Object Data',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...map.entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            entry.key.toString(),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.amber.shade800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildListValue(List list) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list, size: 12, color: Colors.green.shade700),
              const SizedBox(width: 4),
              Text(
                'Array Data (${list.length} items)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...list
              .take(3)
              .toList()
              .asMap()
              .entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.green.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          if (list.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '... and ${list.length - 3} more items',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.green.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChunksDetail(List chunks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Retrieved Documents (${chunks.length} chunks):',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        ...chunks.take(3).map((chunk) => _buildChunkItem(chunk)),
      ],
    );
  }

  Widget _buildChunkItem(dynamic chunk) {
    if (chunk is! Map<String, dynamic>) return const SizedBox();

    final metadata = chunk['metadata'] as Map<String, dynamic>?;
    final document = chunk['document'] as String?;
    final similarity = chunk['similarity'] as double?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document header with metadata
          _buildDocumentHeader(metadata, similarity),
          const SizedBox(height: 6),

          // Rich document content
          if (document != null && document.isNotEmpty)
            _buildRichDocumentContent(document, metadata),
        ],
      ),
    );
  }

  Widget _buildDocumentHeader(
      Map<String, dynamic>? metadata, double? similarity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.description, size: 14, color: Colors.blue.shade700),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (metadata?['pdf_id'] != null)
                  Text(
                    'Source: ${metadata!['pdf_id']}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                if (metadata?['page'] != null)
                  Text(
                    'Page: ${metadata!['page']}',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.blue.shade600,
                    ),
                  ),
              ],
            ),
          ),
          if (similarity != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${(similarity * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRichDocumentContent(
      String document, Map<String, dynamic>? metadata) {
    // Check if document contains table data
    if (_isTableData(document)) {
      return _buildTableContent(document);
    }

    // Check if document has structured table format
    if (_isStructuredTableData(document)) {
      return _buildStructuredTableContent(document);
    }

    // Show image if available in metadata
    final widgets = <Widget>[];

    if (metadata?['image_url'] != null) {
      widgets.add(
          _buildDocumentImage(metadata!['image_url'], metadata['caption']));
      widgets.add(const SizedBox(height: 6));
    }

    // Regular text content
    widgets.add(_buildTextContent(document));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  bool _isTableData(String document) {
    return document.trim().startsWith('[[') && document.trim().endsWith(']]');
  }

  bool _isStructuredTableData(String document) {
    return document.contains('Headers:') && document.contains('Data:');
  }

  Widget _buildTableContent(String jsonString) {
    try {
      final dynamic tableData = jsonDecode(jsonString);
      if (tableData is! List || tableData.isEmpty) {
        return _buildTextContent(jsonString);
      }

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.table_chart,
                      size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Data Table',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            // Table content
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 8,
                horizontalMargin: 8,
                headingRowHeight: 24,
                dataRowHeight: 20,
                columns: _buildTableColumns(tableData[0]),
                rows: _buildTableRows(tableData.skip(1).toList()),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return _buildTextContent(jsonString);
    }
  }

  List<DataColumn> _buildTableColumns(List<dynamic> headers) {
    return headers
        .map((header) => DataColumn(
              label: Expanded(
                child: Text(
                  header.toString(),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ))
        .toList();
  }

  List<DataRow> _buildTableRows(List<dynamic> rows) {
    return rows.take(5).map((row) {
      // Limit to 5 rows for space
      if (row is! List) return DataRow(cells: [DataCell(Text(row.toString()))]);

      return DataRow(
        cells: row
            .map((cell) => DataCell(
                  Text(
                    cell.toString(),
                    style: const TextStyle(fontSize: 8),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
      );
    }).toList();
  }

  Widget _buildStructuredTableContent(String document) {
    final lines = document.split('\n');
    List<String> headers = [];
    List<List<String>> rows = [];

    bool inDataSection = false;

    for (String line in lines) {
      line = line.trim();

      if (line.startsWith('Headers:')) {
        headers = line.substring(8).split('|').map((h) => h.trim()).toList();
        continue;
      }

      if (line.startsWith('Data:')) {
        inDataSection = true;
        continue;
      }

      if (inDataSection && line.startsWith('Row ')) {
        final rowData = line
            .substring(line.indexOf(':') + 1)
            .split('|')
            .map((cell) => cell.trim())
            .toList();
        if (rowData.isNotEmpty) {
          rows.add(rowData);
        }
      }

      if (line.startsWith('Notes:') || line.startsWith('Raw Extraction:')) {
        break;
      }
    }

    if (headers.isEmpty) {
      return _buildTextContent(document);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Row(
              children: [
                Icon(Icons.table_rows, size: 12, color: Colors.orange.shade600),
                const SizedBox(width: 4),
                Text(
                  'Extracted Table',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 8,
              horizontalMargin: 8,
              headingRowHeight: 24,
              dataRowHeight: 20,
              columns: headers
                  .map((header) => DataColumn(
                        label: Expanded(
                          child: Text(
                            header,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              rows: rows
                  .take(5)
                  .map((row) => DataRow(
                        cells: row
                            .map((cell) => DataCell(
                                  Text(
                                    cell,
                                    style: const TextStyle(fontSize: 8),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentImage(String imageUrl, String? caption) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Row(
              children: [
                Icon(Icons.image, size: 12, color: Colors.purple.shade600),
                const SizedBox(width: 4),
                Text(
                  'Document Image',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(4)),
            child: Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 50,
                color: Colors.grey.shade200,
                child: Center(
                  child: Text(
                    'Image failed to load',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (caption != null && caption.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(4),
              child: Text(
                caption,
                style: TextStyle(
                  fontSize: 8,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextContent(String text) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade700,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isProcessing
                ? 'Processing steps...'
                : widget.steps.any((s) => s.status == StepStatus.error)
                    ? 'An error occurred during processing.'
                    : 'All steps completed successfully.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '${widget.totalDuration/1000}s',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
