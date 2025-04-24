import 'dart:collection';

import 'package:skana_ehentai/src/model/gallery.dart';
import 'package:skana_ehentai/src/model/gallery_url.dart';

import 'gallery_comment.dart';
import 'gallery_image.dart';
import 'gallery_tag.dart';
import 'gallery_thumbnail.dart';

class GalleryDetail {
  GalleryUrl galleryUrl;
  String rawTitle;
  String? japaneseTitle;
  String category;
  GalleryImage cover;
  int pageCount;
  double rating;

  /// real rating, not the one we rated
  double realRating;
  bool hasRated;
  int ratingCount;
  int? favoriteTagIndex;
  String? favoriteTagName;

  int favoriteCount;
  String language;

  /// null for disowned gallery
  String? uploader;
  String publishTime;
  bool isExpunged;

  /// full tags: tags in Gallery may be incomplete
  LinkedHashMap<String, List<GalleryTag>> tags;

  String size;
  String torrentCount;
  String torrentPageUrl;
  String archivePageUrl;
  GalleryUrl? parentGalleryUrl;
  List<({GalleryUrl galleryUrl, String title, String updateTime})>? childrenGallerys;
  List<GalleryComment> comments;
  List<GalleryThumbnail> thumbnails;
  int thumbnailsPageCount;

  bool get isFavorite => favoriteTagIndex != null || favoriteTagName != null;

  GalleryUrl? get newVersionGalleryUrl => childrenGallerys?.lastOrNull?.galleryUrl;

  GalleryDetail({
    required this.galleryUrl,
    required this.rawTitle,
    this.japaneseTitle,
    required this.category,
    required this.cover,
    required this.pageCount,
    required this.rating,
    required this.realRating,
    required this.hasRated,
    required this.ratingCount,
    this.favoriteTagIndex,
    this.favoriteTagName,
    required this.favoriteCount,
    required this.language,
    this.uploader,
    required this.publishTime,
    required this.isExpunged,
    required this.tags,
    required this.size,
    required this.torrentCount,
    required this.torrentPageUrl,
    required this.archivePageUrl,
    this.parentGalleryUrl,
    this.childrenGallerys,
    required this.comments,
    required this.thumbnails,
    required this.thumbnailsPageCount,
  });

  Gallery toGallery() {
    return Gallery(
      galleryUrl: galleryUrl,
      title: japaneseTitle ?? rawTitle,
      category: category,
      cover: cover,
      pageCount: pageCount,
      rating: rating,
      hasRated: hasRated,
      favoriteTagIndex: favoriteTagIndex,
      favoriteTagName: favoriteTagName,
      language: language,
      uploader: uploader,
      publishTime: publishTime,
      isExpunged: isExpunged,
      tags: tags,
    );
  }
}
