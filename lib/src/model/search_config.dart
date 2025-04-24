import 'package:skana_ehentai/src/consts/eh_consts.dart';
import 'package:skana_ehentai/src/database/database.dart';
import 'package:json_annotation/json_annotation.dart';

enum SearchType {
  gallery,
  popular,
  favorite,
  watched,
  history,
}

@JsonSerializable()
class SearchConfig {
  SearchType searchType = SearchType.gallery;

  bool includeDoujinshi = true;
  bool includeManga = true;
  bool includeArtistCG = true;
  bool includeGameCg = true;
  bool includeWestern = true;
  bool includeNonH = true;
  bool includeImageSet = true;
  bool includeCosplay = true;
  bool includeAsianPorn = true;
  bool includeMisc = true;

  String? keyword;

  /// i have to admit this field is an awful design
  List<TagData>? tags;

  String? language;

  bool onlySearchExpungedGalleries = false;
  bool onlyShowGalleriesWithTorrents = false;

  int? pageAtLeast;
  int? pageAtMost;

  int minimumRating = 1;

  bool disableFilterForLanguage = false;
  bool disableFilterForUploader = false;
  bool disableFilterForTags = false;

  /// Favorite search
  int? searchFavoriteCategoryIndex;

  SearchConfig({
    this.searchType = SearchType.gallery,
    this.includeDoujinshi = true,
    this.includeManga = true,
    this.includeArtistCG = true,
    this.includeGameCg = true,
    this.includeWestern = true,
    this.includeNonH = true,
    this.includeImageSet = true,
    this.includeCosplay = true,
    this.includeAsianPorn = true,
    this.includeMisc = true,
    this.keyword,
    this.tags,
    this.language,
    this.onlySearchExpungedGalleries = false,
    this.onlyShowGalleriesWithTorrents = false,
    this.pageAtLeast,
    this.pageAtMost,
    this.minimumRating = 1,
    this.disableFilterForLanguage = false,
    this.disableFilterForUploader = false,
    this.disableFilterForTags = false,
    this.searchFavoriteCategoryIndex,
  });

  SearchConfig.nonHOnly({
    this.searchType = SearchType.gallery,
    this.includeDoujinshi = false,
    this.includeManga = false,
    this.includeArtistCG = false,
    this.includeGameCg = false,
    this.includeWestern = false,
    this.includeNonH = true,
    this.includeImageSet = false,
    this.includeCosplay = false,
    this.includeAsianPorn = false,
    this.includeMisc = false,
    this.keyword,
    this.tags,
    this.language,
    this.onlySearchExpungedGalleries = false,
    this.onlyShowGalleriesWithTorrents = false,
    this.pageAtLeast,
    this.pageAtMost,
    this.minimumRating = 1,
    this.disableFilterForLanguage = false,
    this.disableFilterForUploader = false,
    this.disableFilterForTags = false,
    this.searchFavoriteCategoryIndex,
  });

  void enableAllCategories() {
    includeDoujinshi = true;
    includeManga = true;
    includeArtistCG = true;
    includeGameCg = true;
    includeWestern = true;
    includeNonH = true;
    includeImageSet = true;
    includeCosplay = true;
    includeAsianPorn = true;
    includeMisc = true;
  }
  
  void disableAllCategories() {
    includeDoujinshi = false;
    includeManga = false;
    includeArtistCG = false;
    includeGameCg = false;
    includeWestern = false;
    includeNonH = false;
    includeImageSet = false;
    includeCosplay = false;
    includeAsianPorn = false;
    includeMisc = false;
  }

  /// search path
  String toPath() {
    switch (searchType) {
      case SearchType.gallery:
        return EHConsts.EIndex;
      case SearchType.popular:
        return EHConsts.EPopular;
      case SearchType.favorite:
        return EHConsts.EFavorite;
      case SearchType.watched:
        return EHConsts.EWatched;
      case SearchType.history:
        return '';
    }
  }

  /// search params
  Map<String, dynamic> toQueryParameters() {
    Map<String, dynamic> params = {};

    if (keyword != null || (tags?.isNotEmpty ?? false)) {
      params['f_search'] = computeFullKeywords();
    }

    if (language != null) {
      params['f_search'] = (params['f_search'] ?? '') + ' language:"$language"';
    }

    if (searchType == SearchType.gallery || searchType == SearchType.watched) {
      params['f_cats'] = _computeFCats();

      if (onlySearchExpungedGalleries) {
        params['f_sh'] = 'on';
      }
      if (onlyShowGalleriesWithTorrents) {
        params['f_sto'] = 'on';
      }

      if (pageAtLeast != null) {
        params['f_spf'] = pageAtLeast;
      }
      if (pageAtMost != null && (pageAtLeast == null || pageAtMost! >= pageAtLeast!)) {
        params['f_spt'] = pageAtMost;
      }

      if (minimumRating > 1) {
        params['f_srdd'] = minimumRating;
      }

      if (disableFilterForLanguage) {
        params['f_sfl'] = 'on';
      }
      if (disableFilterForUploader) {
        params['f_sfu'] = 'on';
      }
      if (disableFilterForTags) {
        params['f_sft'] = 'on';
      }
    }

    if (searchType == SearchType.favorite) {
      if (searchFavoriteCategoryIndex != null) {
        params['favcat'] = searchFavoriteCategoryIndex;
      }
    }

    return params;
  }

  String computeFullKeywordsWithLanguage() {
    if (language != null) {
      return 'language:"$language" ' + computeFullKeywords();
    } else {
      return computeFullKeywords();
    }
  }

  String computeFullKeywords() {
    return '${keyword ?? ''} ${computeTagKeywords(withTranslation: false, separator: ' ')}'.trim();
  }

  String computeTagKeywords({required bool withTranslation, required String separator}) {
    List<String> strs = [];

    tags?.forEach((tag) {
      /// manual input
      if (tag.namespace.isEmpty) {
        strs.add(tag.key);
        return;
      }

      if (withTranslation && tag.tagName != null) {
        strs.add('${tag.translatedNamespace}:${tag.tagName}');
        return;
      }

      strs.add('${tag.namespace}:"${tag.key}\$"');
    });

    return strs.join(separator);
  }

  int _computeFCats() {
    int fCats = 0;
    if (!includeMisc) {
      fCats += 1;
    }
    if (!includeDoujinshi) {
      fCats += 2;
    }
    if (!includeManga) {
      fCats += 4;
    }
    if (!includeArtistCG) {
      fCats += 8;
    }
    if (!includeGameCg) {
      fCats += 16;
    }
    if (!includeImageSet) {
      fCats += 32;
    }
    if (!includeCosplay) {
      fCats += 64;
    }
    if (!includeAsianPorn) {
      fCats += 128;
    }
    if (!includeNonH) {
      fCats += 256;
    }
    if (!includeWestern) {
      fCats += 512;
    }
    return fCats;
  }

  factory SearchConfig.fromJson(Map<String, dynamic> json) {
    return SearchConfig(
      searchType: SearchType.values[json["searchType"]],
      includeDoujinshi: json["includeDoujinshi"],
      includeManga: json["includeManga"],
      includeArtistCG: json["includeArtistCG"],
      includeGameCg: json["includeGameCg"],
      includeWestern: json["includeWestern"],
      includeNonH: json["includeNonH"],
      includeImageSet: json["includeImageSet"],
      includeCosplay: json["includeCosplay"],
      includeAsianPorn: json["includeAsianPorn"],
      includeMisc: json["includeMisc"],
      keyword: json["keyword"],
      tags: (json["tags"] as List?)?.map((e) => TagData.fromJson(e)).toList(),
      language: json["language"],
      onlySearchExpungedGalleries: json["searchExpungedGalleries"],
      onlyShowGalleriesWithTorrents: json["onlyShowGalleriesWithTorrents"],
      pageAtLeast: json["pageAtLeast"],
      pageAtMost: json["pageAtMost"],
      minimumRating: json["minimumRating"],
      disableFilterForLanguage: json["disableFilterForLanguage"],
      disableFilterForUploader: json["disableFilterForUploader"],
      disableFilterForTags: json["disableFilterForTags"],
      searchFavoriteCategoryIndex: json["searchFavoriteCategoryIndex"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "searchType": searchType.index,
      "includeDoujinshi": includeDoujinshi,
      "includeManga": includeManga,
      "includeArtistCG": includeArtistCG,
      "includeGameCg": includeGameCg,
      "includeWestern": includeWestern,
      "includeNonH": includeNonH,
      "includeImageSet": includeImageSet,
      "includeCosplay": includeCosplay,
      "includeAsianPorn": includeAsianPorn,
      "includeMisc": includeMisc,
      "keyword": keyword,
      "tags": tags,
      "language": language,
      "searchExpungedGalleries": onlySearchExpungedGalleries,
      "onlyShowGalleriesWithTorrents": onlyShowGalleriesWithTorrents,
      "pageAtLeast": pageAtLeast,
      "pageAtMost": pageAtMost,
      "minimumRating": minimumRating,
      "disableFilterForLanguage": disableFilterForLanguage,
      "disableFilterForUploader": disableFilterForUploader,
      "disableFilterForTags": disableFilterForTags,
      "searchFavoriteCategoryIndex": searchFavoriteCategoryIndex,
    };
  }

  SearchConfig copyWith({
    SearchType? searchType,
    bool? includeDoujinshi,
    bool? includeManga,
    bool? includeArtistCG,
    bool? includeGameCg,
    bool? includeWestern,
    bool? includeNonH,
    bool? includeImageSet,
    bool? includeCosplay,
    bool? includeAsianPorn,
    bool? includeMisc,
    String? keyword,
    List<TagData>? tags,
    String? language,
    bool? searchExpungedGalleries,
    bool? onlyShowGalleriesWithTorrents,
    int? pageAtLeast,
    int? pageAtMost,
    int? minimumRating,
    bool? disableFilterForLanguage,
    bool? disableFilterForUploader,
    bool? disableFilterForTags,
  }) {
    return SearchConfig(
      searchType: searchType ?? this.searchType,
      includeDoujinshi: includeDoujinshi ?? this.includeDoujinshi,
      includeManga: includeManga ?? this.includeManga,
      includeArtistCG: includeArtistCG ?? this.includeArtistCG,
      includeGameCg: includeGameCg ?? this.includeGameCg,
      includeWestern: includeWestern ?? this.includeWestern,
      includeNonH: includeNonH ?? this.includeNonH,
      includeImageSet: includeImageSet ?? this.includeImageSet,
      includeCosplay: includeCosplay ?? this.includeCosplay,
      includeAsianPorn: includeAsianPorn ?? this.includeAsianPorn,
      includeMisc: includeMisc ?? this.includeMisc,
      keyword: keyword ?? this.keyword,
      tags: tags ?? this.tags?.map((tag) => tag.copyWith()).toList(),
      language: language ?? this.language,
      onlySearchExpungedGalleries: searchExpungedGalleries ?? onlySearchExpungedGalleries,
      onlyShowGalleriesWithTorrents: onlyShowGalleriesWithTorrents ?? this.onlyShowGalleriesWithTorrents,
      pageAtLeast: pageAtLeast ?? this.pageAtLeast,
      pageAtMost: pageAtMost ?? this.pageAtMost,
      minimumRating: minimumRating ?? this.minimumRating,
      disableFilterForLanguage: disableFilterForLanguage ?? this.disableFilterForLanguage,
      disableFilterForUploader: disableFilterForUploader ?? this.disableFilterForUploader,
      disableFilterForTags: disableFilterForTags ?? this.disableFilterForTags,
      searchFavoriteCategoryIndex: searchFavoriteCategoryIndex ?? searchFavoriteCategoryIndex,
    );
  }

  @override
  String toString() {
    return 'SearchConfig{searchType: $searchType, includeDoujinshi: $includeDoujinshi, includeManga: $includeManga, includeArtistCG: $includeArtistCG, includeGameCg: $includeGameCg, includeWestern: $includeWestern, includeNonH: $includeNonH, includeImageSet: $includeImageSet, includeCosplay: $includeCosplay, includeAsianPorn: $includeAsianPorn, includeMisc: $includeMisc, keyword: $keyword, tags: $tags, language: $language, onlySearchExpungedGalleries: $onlySearchExpungedGalleries, onlyShowGalleriesWithTorrents: $onlyShowGalleriesWithTorrents, pageAtLeast: $pageAtLeast, pageAtMost: $pageAtMost, minimumRating: $minimumRating, disableFilterForLanguage: $disableFilterForLanguage, disableFilterForUploader: $disableFilterForUploader, disableFilterForTags: $disableFilterForTags, searchFavoriteCategoryIndex: $searchFavoriteCategoryIndex}';
  }
}
