class SSEEventModel {
  final String step;
  final String status;
  final String message;
  final int? timestamp;
  final Map<String, dynamic>? data;
  final String? finalAnswer;
  final String? translatedQuery;
  final String? sourceLang;
  final String? targetLang;
  final String? collection;
  final bool? isSmallTalk;
  final double? routingConfidence;
  final int? chunksCount;
  final String? retrievalType;
  final List<dynamic>? top10Chunks;
  final String? llmPrompt;
  final String? llmVisionPromptTextComponent;
  final String? modelUsed;
  final int? tokensGenerated;
  final int? imagesProcessed;
  final String? visionModel;
  final String? searchQuery;
  final int? resultsCount;
  final dynamic error;

  SSEEventModel({
    required this.step,
    required this.status,
    required this.message,
    this.timestamp,
    this.data,
    this.finalAnswer,
    this.translatedQuery,
    this.sourceLang,
    this.targetLang,
    this.collection,
    this.isSmallTalk,
    this.routingConfidence,
    this.chunksCount,
    this.retrievalType,
    this.top10Chunks,
    this.llmPrompt,
    this.llmVisionPromptTextComponent,
    this.modelUsed,
    this.tokensGenerated,
    this.imagesProcessed,
    this.visionModel,
    this.searchQuery,
    this.resultsCount,
    this.error,
  });

  factory SSEEventModel.fromJson(Map<String, dynamic> json) {
    return SSEEventModel(
      step: json['step'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'],
      data: json['data'],
      finalAnswer: json['final_answer'],
      translatedQuery: json['translated_query'],
      sourceLang: json['source_lang'],
      targetLang: json['target_lang'],
      collection: json['collection'],
      isSmallTalk: json['is_small_talk'],
      routingConfidence: json['routing_confidence']?.toDouble(),
      chunksCount: json['chunks_count'],
      retrievalType: json['retrieval_type'],
      top10Chunks: json['top_10_chunks'],
      llmPrompt: json['llm_prompt'],
      llmVisionPromptTextComponent: json['llm_vision_prompt_text_component'],
      modelUsed: json['model_used'],
      tokensGenerated: json['tokens_generated'],
      imagesProcessed: json['images_processed'],
      visionModel: json['vision_model'],
      searchQuery: json['search_query'],
      resultsCount: json['results_count'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'status': status,
      'message': message,
      'timestamp': timestamp,
      'data': data,
      'final_answer': finalAnswer,
      'translated_query': translatedQuery,
      'source_lang': sourceLang,
      'target_lang': targetLang,
      'collection': collection,
      'is_small_talk': isSmallTalk,
      'routing_confidence': routingConfidence,
      'chunks_count': chunksCount,
      'retrieval_type': retrievalType,
      'top_10_chunks': top10Chunks,
      'llm_prompt': llmPrompt,
      'llm_vision_prompt_text_component': llmVisionPromptTextComponent,
      'model_used': modelUsed,
      'tokens_generated': tokensGenerated,
      'images_processed': imagesProcessed,
      'vision_model': visionModel,
      'search_query': searchQuery,
      'results_count': resultsCount,
      'error': error,
    };
  }
}