// ignore_for_file: no_leading_underscores_for_local_identifiers

class ImageEntity {
  String id = "";
  String url = "";

  ImageEntity(this.id, this.url);

  ImageEntity.newImage(this.url);

  ImageEntity.fromJson(String _id, Map<String, dynamic> doc)
      : id = _id,
        url = doc['url'];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
    };
  }
}
