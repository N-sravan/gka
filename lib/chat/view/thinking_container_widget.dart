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
  State<ThinkingContainerWidget> createState() => _ThinkingContainerWidgetState();
}

class _ThinkingContainerWidgetState extends State<ThinkingContainerWidget>
    with TickerProviderStateMixin {
  bool _isExpanded = true;
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(12),
            bottom: _isExpanded ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            _buildStatusIcon(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.isProcessing ? 'Processing query...' : 
                widget.steps.any((s) => s.status == StepStatus.error) 
                    ? 'Processing failed' 
                    : 'Processing complete',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: Colors.grey[600],
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: details.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildDetailItem(entry.key, entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailItem(String key, dynamic value) {
    if (value is List && key == 'top_10_chunks') {
      return _buildChunksDetail(value);
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$key: ',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
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
        ...chunks.take(3).map((chunk) => _buildChunkItem(chunk)).toList(),
      ],
    );
  }

  Widget _buildChunkItem(dynamic chunk) {
    if (chunk is! Map<String, dynamic>) return const SizedBox();
    
    final metadata = chunk['metadata'] as Map<String, dynamic>?;
    final document = chunk['document'] as String?;
    final similarity = chunk['similarity'] as double?;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (metadata != null) ...[
            if (metadata['pdf_id'] != null)
              Text(
                'Source: ${metadata['pdf_id']}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            if (similarity != null)
              Text(
                'Similarity: ${(similarity * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                ),
              ),
          ],
          if (document != null && document.isNotEmpty)
            Text(
              document.length > 200 ? '${document.substring(0, 200)}...' : document,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[700],
              ),
            ),
        ],
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
            widget.isProcessing ? 'Processing steps...' : 
            widget.steps.any((s) => s.status == StepStatus.error)
                ? 'An error occurred during processing.'
                : 'All steps completed successfully.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '${widget.totalDuration}ms',
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