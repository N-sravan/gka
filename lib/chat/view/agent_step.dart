import 'dart:convert';

import 'package:flutter/material.dart';

class AgentStepWidget extends StatefulWidget {
  final Map<String, dynamic> step;
  final bool shouldExpand;

  const AgentStepWidget({
    Key? key,
    required this.step,
    this.shouldExpand = false,
  }) : super(key: key);

  @override
  State<AgentStepWidget> createState() => _AgentStepWidgetState();
}

class _AgentStepWidgetState extends State<AgentStepWidget> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.shouldExpand;
  }

  @override
  void didUpdateWidget(AgentStepWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shouldExpand != widget.shouldExpand) {
      setState(() {
        isExpanded = widget.shouldExpand;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.step.entries.first;
    final title = entry.key;
    final content = entry.value;
    final type = 'text';

    // Customize the appearance based on step type
    Color headerColor;
    IconData headerIcon;

    // Set colors and icons based on step title
    if (title == 'Input') {
      headerColor = Colors.blue.shade50;
      headerIcon = Icons.send;
    } else if (title == 'Output') {
      headerColor = Colors.green.shade50;
      headerIcon = Icons.comment;
    } else if (title.contains('Error') || title.contains('exception')) {
      headerColor = Colors.red.shade50;
      headerIcon = Icons.error_outline;
    } else if (title.contains('Search') || title.contains('query')) {
      headerColor = Colors.amber.shade50;
      headerIcon = Icons.search;
    } else if (title.contains('API') || title.contains('request')) {
      headerColor = Colors.purple.shade50;
      headerIcon = Icons.api;
    } else if (title.contains('Tool') || title.contains('function')) {
      headerColor = Colors.orange.shade50;
      headerIcon = Icons.build;
    } else {
      headerColor = Colors.grey.shade50;
      headerIcon = Icons.info_outline;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: headerColor.withOpacity(0.8), width: 1),
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            isExpanded = expanded;
          });
        },
        leading: Icon(headerIcon, color: headerColor.withOpacity(0.8)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: _buildContentWidget(type, content),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget(String type, dynamic content) {
    final textContent = content is String ? content : jsonEncode(content);

    switch (type.toLowerCase()) {
      case 'code':
        return Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.all(12),
          child: Text(
            textContent,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      case 'json':
        try {
          final Map<String, dynamic> jsonData =
          content is String ? json.decode(content) : content;
          final prettyJson =
          const JsonEncoder.withIndent('  ').convert(jsonData);
          return Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              prettyJson,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          );
        } catch (e) {
          return Text(textContent);
        }
      default:
        return Text(
          textContent,
          style: const TextStyle(fontSize: 13),
        );
    }
  }
}