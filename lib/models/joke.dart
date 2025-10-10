class Joke {
  final String id;
  final String value;
  final String iconUrl;
  final List<String> categories;
  final String url;

  Joke({
    required this.id,
    required this.value,
    required this.iconUrl,
    required this.categories,
    required this.url,
  });

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      id: json['id'] as String? ?? '',
      value: json['value'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
        'icon_url': iconUrl,
        'categories': categories,
        'url': url,
      };
}
