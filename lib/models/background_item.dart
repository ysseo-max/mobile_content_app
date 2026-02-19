class BackgroundItem {
  final String id;
  final String url;
  final Map<String, String> title;
  final bool isCustom;

  const BackgroundItem({
    required this.id,
    required this.url,
    required this.title,
    this.isCustom = false,
  });

  String getTitle(String languageCode) {
    return title[languageCode] ?? title['en'] ?? '';
  }

  /// 사용자 갤러리에서 업로드한 커스텀 배경
  static BackgroundItem custom() {
    return const BackgroundItem(
      id: 'bg_custom',
      url: '',
      title: {
        'ko': '내 사진',
        'en': 'My Photo',
        'ja': 'マイフォト',
        'zh': '我的照片',
      },
      isCustom: true,
    );
  }

  /// 서울 대표 관광 명소 9곳
  static const List<BackgroundItem> defaults = [
    // 1. 경복궁 — 서울 대표 고궁, 한복 포토스팟
    BackgroundItem(
      id: 'bg_gyeongbokgung',
      url: 'https://images.unsplash.com/photo-1534274988757-a28bf1a57c17?w=800',
      title: {
        'ko': '경복궁',
        'en': 'Gyeongbokgung Palace',
        'ja': '景福宮',
        'zh': '景福宫',
      },
    ),
    // 2. 북촌 한옥마을 — 전통 한옥 골목 포토스팟
    BackgroundItem(
      id: 'bg_bukchon',
      url: 'https://images.unsplash.com/photo-1601042879364-f3947d3f9c16?w=800',
      title: {
        'ko': '북촌 한옥마을',
        'en': 'Bukchon Hanok Village',
        'ja': '北村韓屋村',
        'zh': '北村韩屋村',
      },
    ),
    // 3. N서울타워 (남산타워) — 서울 야경 대표 랜드마크
    BackgroundItem(
      id: 'bg_namsan',
      url: 'https://images.unsplash.com/photo-1517154421773-0529f29ea451?w=800',
      title: {
        'ko': 'N서울타워',
        'en': 'N Seoul Tower',
        'ja': 'Nソウルタワー',
        'zh': 'N首尔塔',
      },
    ),
    // 4. 창덕궁 — UNESCO 세계유산, 비원(후원)
    BackgroundItem(
      id: 'bg_changdeokgung',
      url: 'https://images.unsplash.com/photo-1572981779307-38b8cabb2407?w=800',
      title: {
        'ko': '창덕궁',
        'en': 'Changdeokgung Palace',
        'ja': '昌徳宮',
        'zh': '昌德宫',
      },
    ),
    // 5. DDP (동대문디자인플라자) — 미래적 건축물
    BackgroundItem(
      id: 'bg_ddp',
      url: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800',
      title: {
        'ko': '동대문 DDP',
        'en': 'Dongdaemun DDP',
        'ja': '東大門DDP',
        'zh': '东大门DDP',
      },
    ),
    // 6. 광화문광장 — 서울 중심 랜드마크
    BackgroundItem(
      id: 'bg_gwanghwamun',
      url: 'https://images.unsplash.com/photo-1546874177-9e664107314e?w=800',
      title: {
        'ko': '광화문광장',
        'en': 'Gwanghwamun Square',
        'ja': '光化門広場',
        'zh': '光化门广场',
      },
    ),
    // 7. 롯데월드타워 (서울스카이) — 초고층 전망대
    BackgroundItem(
      id: 'bg_lotte_tower',
      url: 'https://images.unsplash.com/photo-1562832135-14a35d25eead?w=800',
      title: {
        'ko': '롯데월드타워',
        'en': 'Lotte World Tower',
        'ja': 'ロッテワールドタワー',
        'zh': '乐天世界塔',
      },
    ),
    // 8. 이화벽화마을 — 알록달록 벽화 포토존
    BackgroundItem(
      id: 'bg_ihwa',
      url: 'https://images.unsplash.com/photo-1578037571214-25e07a2d872f?w=800',
      title: {
        'ko': '이화벽화마을',
        'en': 'Ihwa Mural Village',
        'ja': '梨花壁画村',
        'zh': '梨花壁画村',
      },
    ),
    // 9. 별마당도서관 (코엑스) — 인스타 인기 실내 포토스팟
    BackgroundItem(
      id: 'bg_starfield',
      url: 'https://images.unsplash.com/photo-1583037189850-1921ae7c6c22?w=800',
      title: {
        'ko': '별마당 도서관',
        'en': 'Starfield Library',
        'ja': 'ピョルマダン図書館',
        'zh': '星空图书馆',
      },
    ),
  ];
}
