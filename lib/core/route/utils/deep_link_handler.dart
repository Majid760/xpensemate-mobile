

class DeepLinkHandler {
  /// Handle incoming deep links
  String? handleDeepLink(String path, Map<String, String> queryParams) {
    // Parse deep link and return appropriate route
    if (path.startsWith('/share/')) {
      final itemId = path.split('/').last;
      return '/item/$itemId';
    }
    
    if (path.startsWith('/invite/')) {
      final inviteCode = queryParams['code'];
      if (inviteCode != null) {
        return '/register?invite=$inviteCode';
      }
    }
    
    return null; // No special handling needed
  }

  /// Generate shareable deep links
  String generateShareLink(String route, {Map<String, String>? params}) {
    final uri = Uri(
      scheme: 'https',
      host: 'yourapp.com',
      path: route,
      queryParameters: params,
    );
    return uri.toString();
  }
}