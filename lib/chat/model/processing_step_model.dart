enum StepStatus { pending, inProgress, completed, error, skipped }

class ProcessingStepModel {
  final String name;
  final String displayName;
  final StepStatus status;
  final dynamic message;
  final int? startTime;
  final int? duration;
  final Map<String, dynamic>? details;
  final dynamic error;

  ProcessingStepModel({
    required this.name,
    required this.displayName,
    required this.status,
    required this.message,
    this.startTime,
    this.duration,
    this.details,
    this.error,
  });

  ProcessingStepModel copyWith({
    String? name,
    String? displayName,
    StepStatus? status,
    String? message,
    int? startTime,
    int? duration,
    Map<String, dynamic>? details,
    dynamic error,
  }) {
    return ProcessingStepModel(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      message: message ?? this.message,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      details: details ?? this.details,
      error: error ?? this.error,
    );
  }

  String get statusText {
    switch (status) {
      case StepStatus.pending:
        return 'Pending';
      case StepStatus.inProgress:
        return 'In Progress';
      case StepStatus.completed:
        return 'Completed';
      case StepStatus.error:
        return 'Error';
      case StepStatus.skipped:
        return 'Skipped';
    }
  }

  String get durationText {
    if (duration == null) return '';
    if (duration! >= 1000) {
      return '${(duration! / 1000).toStringAsFixed(1)}s';
    }
    return '${duration}ms';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'status': status.toString().split('.').last,
      'message': message,
      'startTime': startTime,
      'duration': duration,
      'details': details,
      'error': error,
    };
  }

  static ProcessingStepModel fromJson(Map<String, dynamic> json) {
    return ProcessingStepModel(
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
      status: _parseStepStatus(json['status']),
      message: json['message'] ?? '',
      startTime: json['startTime'],
      duration: json['duration'],
      details: json['details'] as Map<String, dynamic>?,
      error: json['error'],
    );
  }

  static StepStatus _parseStepStatus(dynamic status) {
    if (status is StepStatus) return status;
    
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'pending':
        return StepStatus.pending;
      case 'inprogress':
      case 'in_progress':
        return StepStatus.inProgress;
      case 'completed':
        return StepStatus.completed;
      case 'error':
        return StepStatus.error;
      case 'skipped':
        return StepStatus.skipped;
      default:
        return StepStatus.pending;
    }
  }

  static String formatStepName(String stepName) {
    const names = {
      'translation': 'Translation',
      'workflow_init': 'Workflow Init',
      'restructure_route': 'Query Routing',
      'retrieval': 'Document Retrieval',
      'vision_processing': 'Vision Processing',
      'answer_generation': 'Answer Generation',
      'response_translation': 'Response Translation',
      'web_search': 'Web Search',
      'complete': 'Processing Complete',
      'error': 'Processing Error',
    };
    
    return names[stepName] ?? 
           stepName.replaceAll('_', ' ').split(' ')
               .map((word) => word.isNotEmpty ? 
                   word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
               .join(' ');
  }
}