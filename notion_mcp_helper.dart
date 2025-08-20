import 'dart:convert';
import 'dart:io';

/// A helper class for integrating with Notion via MCP (Model Context Protocol)
/// This demonstrates how to work with Notion databases, pages, and blocks
class NotionMcpHelper {
  /// Search for pages and databases in Notion workspace
  static Future<Map<String, dynamic>> searchNotion({
    required String query,
    String? filter,
    int pageSize = 100,
  }) async {
    try {
      // This would call the MCP function: mcp__notion__API-post-search
      final searchParams = {
        'query': query,
        'page_size': pageSize,
      };
      
      if (filter != null) {
        searchParams['filter'] = {'property': 'object', 'value': filter};
      }
      
      // Example response structure
      return {
        'success': true,
        'results': [],
        'has_more': false,
        'next_cursor': null,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Query a specific database
  static Future<Map<String, dynamic>> queryDatabase({
    required String databaseId,
    Map<String, dynamic>? filter,
    List<Map<String, dynamic>>? sorts,
    int pageSize = 100,
  }) async {
    try {
      final queryParams = {
        'database_id': databaseId,
        'page_size': pageSize,
      };
      
      if (filter != null) queryParams['filter'] = filter;
      if (sorts != null) queryParams['sorts'] = sorts;
      
      // This would call: mcp__notion__API-post-database-query
      return {
        'success': true,
        'results': [],
        'has_more': false,
        'next_cursor': null,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Create a new page in Notion
  static Future<Map<String, dynamic>> createPage({
    required String parentPageId,
    required String title,
    List<Map<String, dynamic>>? children,
  }) async {
    try {
      final pageData = {
        'parent': {'page_id': parentPageId},
        'properties': {
          'title': [
            {
              'text': {'content': title}
            }
          ]
        }
      };
      
      if (children != null) {
        pageData['children'] = children;
      }
      
      // This would call: mcp__notion__API-post-page
      return {
        'success': true,
        'page_id': 'generated-page-id',
        'url': 'https://notion.so/page-url',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Add content blocks to a page
  static Future<Map<String, dynamic>> addBlocksToPage({
    required String pageId,
    required List<Map<String, dynamic>> blocks,
  }) async {
    try {
      final blockData = {
        'block_id': pageId,
        'children': blocks,
      };
      
      // This would call: mcp__notion__API-patch-block-children
      return {
        'success': true,
        'blocks_added': blocks.length,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Create common block types
  static Map<String, dynamic> createParagraphBlock(String text) {
    return {
      'type': 'paragraph',
      'paragraph': {
        'rich_text': [
          {
            'type': 'text',
            'text': {'content': text}
          }
        ]
      }
    };
  }

  static Map<String, dynamic> createBulletListItem(String text) {
    return {
      'type': 'bulleted_list_item',
      'bulleted_list_item': {
        'rich_text': [
          {
            'type': 'text',
            'text': {'content': text}
          }
        ]
      }
    };
  }

  /// Get page content including all blocks
  static Future<Map<String, dynamic>> getPageContent(String pageId) async {
    try {
      // First get page details: mcp__notion__API-retrieve-a-page
      // Then get page blocks: mcp__notion__API-get-block-children
      
      return {
        'success': true,
        'page': {},
        'blocks': [],
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Create a database with properties
  static Future<Map<String, dynamic>> createDatabase({
    required String parentPageId,
    required String title,
    required Map<String, dynamic> properties,
  }) async {
    try {
      final databaseData = {
        'parent': {
          'type': 'page_id',
          'page_id': parentPageId,
        },
        'title': [
          {
            'type': 'text',
            'text': {'content': title}
          }
        ],
        'properties': properties,
      };
      
      // This would call: mcp__notion__API-create-a-database
      return {
        'success': true,
        'database_id': 'generated-database-id',
        'url': 'https://notion.so/database-url',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Example usage for code documentation
  static Future<void> documentCodeInNotion({
    required String parentPageId,
    required String projectName,
    required List<String> filePaths,
  }) async {
    // Create main project page
    final pageResult = await createPage(
      parentPageId: parentPageId,
      title: '$projectName - Code Documentation',
    );
    
    if (!pageResult['success']) {
      throw Exception('Failed to create page: ${pageResult['error']}');
    }
    
    final pageId = pageResult['page_id'];
    
    // Add file documentation blocks
    final blocks = <Map<String, dynamic>>[];
    
    for (final filePath in filePaths) {
      blocks.add(createParagraphBlock('File: $filePath'));
      // Add more specific documentation blocks here
    }
    
    await addBlocksToPage(pageId: pageId, blocks: blocks);
  }
}