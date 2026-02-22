import 'dart:ui';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(String langCode) {
    return AppLocalizations(langCode);
  }

  static String detectLanguage() {
    final locale = PlatformDispatcher.instance.locale;
    final code = locale.languageCode;
    if (['ko', 'en', 'ja', 'zh'].contains(code)) return code;
    return 'en';
  }

  static final Map<String, Map<String, String>> _translations = {
    // ===================== HOME =====================
    'appTitle': {
      'ko': 'AI & 스탬프 모바일 콘텐츠',
      'en': 'AI & Stamp Mobile Content',
      'ja': 'AI＆スタンプモバイルコンテンツ',
      'zh': 'AI和印章移动内容',
    },
    'aiImageExperience': {
      'ko': 'AI 이미지 체험',
      'en': 'AI Image Experience',
      'ja': 'AI画像体験',
      'zh': 'AI图像体验',
    },
    'stampRally': {
      'ko': '스탬프 랠리 체험',
      'en': 'Stamp Rally Experience',
      'ja': 'スタンプラリー体験',
      'zh': '集章打卡体验',
    },
    'selectExperience': {
      'ko': '체험을 선택해 주세요',
      'en': 'Select an experience',
      'ja': '体験を選択してください',
      'zh': '请选择体验',
    },

    // ===================== AI EXPERIENCE - Background Selection =====================
    'selectBackground': {
      'ko': '배경을 선택해 주세요',
      'en': 'Select a background',
      'ja': '背景を選択してください',
      'zh': '请选择背景',
    },
    'selectBackgroundDesc': {
      'ko': '서울 명소를 배경으로 선택하거나, 내 사진을 업로드하세요',
      'en': 'Choose a Seoul landmark or upload your own photo',
      'ja': 'ソウルの名所を選ぶか、自分の写真をアップロードしてください',
      'zh': '选择首尔景点或上传您自己的照片',
    },
    'backgroundSelection': {
      'ko': '배경',
      'en': 'Background',
      'ja': '背景',
      'zh': '背景',
    },
    'contentFiltered': {
      'ko': '안전 필터에 의해 콘텐츠가 차단되었습니다. 다른 사진을 시도해 주세요.',
      'en': 'Content was filtered by safety settings. Please try a different photo.',
      'ja': '安全フィルターによりコンテンツがブロックされました。別の写真をお試しください。',
      'zh': '内容被安全过滤器拦截。请尝试使用其他照片。',
    },

    // ===================== AI EXPERIENCE =====================
    'aiIntroTitle': {
      'ko': 'AI 이미지 체험',
      'en': 'AI Image Experience',
      'ja': 'AI画像体験',
      'zh': 'AI图像体验',
    },
    'aiIntroDesc': {
      'ko': '사진과 정보를 입력하면\nAI가 특별한 이미지를 만들어 드립니다',
      'en': 'Upload your photo and info\nAI will create a special image for you',
      'ja': '写真と情報を入力すると\nAIが特別な画像を作成します',
      'zh': '上传您的照片和信息\nAI将为您创建特别的图像',
    },
    'startExperience': {
      'ko': '체험 시작하기',
      'en': 'Start Experience',
      'ja': '体験を始める',
      'zh': '开始体验',
    },
    'photoUploadTitle': {
      'ko': '사진을 선택해 주세요',
      'en': 'Please select a photo',
      'ja': '写真を選択してください',
      'zh': '请选择照片',
    },
    'takePhoto': {
      'ko': '사진 촬영',
      'en': 'Take Photo',
      'ja': '写真を撮る',
      'zh': '拍照',
    },
    'chooseFromGallery': {
      'ko': '갤러리에서 선택',
      'en': 'Choose from Gallery',
      'ja': 'ギャラリーから選択',
      'zh': '从相册选择',
    },
    'next': {
      'ko': '다음',
      'en': 'Next',
      'ja': '次へ',
      'zh': '下一步',
    },
    'birthYearTitle': {
      'ko': '출생 연도를 입력해 주세요',
      'en': 'Please enter your birth year',
      'ja': '生年を入力してください',
      'zh': '请输入出生年份',
    },
    'birthYearHint': {
      'ko': '예: 1990',
      'en': 'e.g. 1990',
      'ja': '例：1990',
      'zh': '例如：1990',
    },
    'genderTitle': {
      'ko': '성별을 선택해 주세요',
      'en': 'Please select your gender',
      'ja': '性別を選択してください',
      'zh': '请选择您的性别',
    },
    'male': {
      'ko': '남성',
      'en': 'Male',
      'ja': '男性',
      'zh': '男',
    },
    'female': {
      'ko': '여성',
      'en': 'Female',
      'ja': '女性',
      'zh': '女',
    },
    'generating': {
      'ko': 'AI 이미지를 생성하고 있습니다...',
      'en': 'Generating AI image...',
      'ja': 'AI画像を生成しています...',
      'zh': '正在生成AI图像...',
    },
    'generatingDesc': {
      'ko': '잠시만 기다려 주세요',
      'en': 'Please wait a moment',
      'ja': 'しばらくお待ちください',
      'zh': '请稍候',
    },
    'aiImageReady': {
      'ko': 'AI 이미지가 완성되었습니다!',
      'en': 'Your AI image is ready!',
      'ja': 'AI画像が完成しました！',
      'zh': 'AI图像已完成！',
    },
    'saveImage': {
      'ko': '이미지 저장',
      'en': 'Save Image',
      'ja': '画像を保存',
      'zh': '保存图像',
    },
    'shareImage': {
      'ko': '이미지 공유',
      'en': 'Share Image',
      'ja': '画像を共有',
      'zh': '分享图像',
    },
    'premiumExperience': {
      'ko': '프리미엄 체험',
      'en': 'Premium Experience',
      'ja': 'プレミアム体験',
      'zh': '高级体验',
    },
    'premiumDesc': {
      'ko': 'LED 화면에 나의 AI 이미지를 송출해 보세요!',
      'en': 'Display your AI image on the LED screen!',
      'ja': 'LEDスクリーンにAI画像を表示しましょう！',
      'zh': '在LED屏幕上展示您的AI图像！',
    },
    'paymentMethod': {
      'ko': '결제 방식 선택',
      'en': 'Select Payment Method',
      'ja': '支払い方法の選択',
      'zh': '选择支付方式',
    },
    'creditCard': {
      'ko': '신용카드 결제',
      'en': 'Credit Card',
      'ja': 'クレジットカード',
      'zh': '信用卡支付',
    },
    'useCoupon': {
      'ko': '쿠폰 사용',
      'en': 'Use Coupon',
      'ja': 'クーポンを使う',
      'zh': '使用优惠券',
    },
    'enterCouponCode': {
      'ko': '쿠폰 코드를 입력해 주세요',
      'en': 'Please enter coupon code',
      'ja': 'クーポンコードを入力してください',
      'zh': '请输入优惠券代码',
    },
    'couponHint': {
      'ko': '쿠폰 코드 입력',
      'en': 'Enter coupon code',
      'ja': 'クーポンコード入力',
      'zh': '输入优惠券代码',
    },
    'apply': {
      'ko': '적용',
      'en': 'Apply',
      'ja': '適用',
      'zh': '应用',
    },
    'pay': {
      'ko': '결제하기',
      'en': 'Pay Now',
      'ja': '支払う',
      'zh': '立即支付',
    },
    'ledTransmitting': {
      'ko': 'LED 전송 중...',
      'en': 'Transmitting to LED...',
      'ja': 'LED送信中...',
      'zh': '正在传输到LED...',
    },
    'estimatedTime': {
      'ko': '예상 송출 시간',
      'en': 'Estimated display time',
      'ja': '表示予定時間',
      'zh': '预计显示时间',
    },
    'ledComplete': {
      'ko': 'LED 송출 완료!',
      'en': 'LED Display Complete!',
      'ja': 'LED表示完了！',
      'zh': 'LED显示完成！',
    },
    'ledCompleteDesc': {
      'ko': 'AI 이미지가 LED 화면에 송출되었습니다',
      'en': 'Your AI image has been displayed on the LED screen',
      'ja': 'AI画像がLEDスクリーンに表示されました',
      'zh': '您的AI图像已在LED屏幕上显示',
    },
    'backToHome': {
      'ko': '홈으로 돌아가기',
      'en': 'Back to Home',
      'ja': 'ホームに戻る',
      'zh': '返回首页',
    },
    'freeExperience': {
      'ko': '기본 체험 (무료)',
      'en': 'Basic Experience (Free)',
      'ja': '基本体験（無料）',
      'zh': '基础体验（免费）',
    },
    'premiumExperiencePaid': {
      'ko': '프리미엄 체험 (과금)',
      'en': 'Premium Experience (Paid)',
      'ja': 'プレミアム体験（有料）',
      'zh': '高级体验（付费）',
    },

    // ===================== STAMP RALLY =====================
    'stampIntroTitle': {
      'ko': '스탬프 랠리',
      'en': 'Stamp Rally',
      'ja': 'スタンプラリー',
      'zh': '集章活动',
    },
    'stampIntroDesc': {
      'ko': '3곳의 장소를 방문하고\nQR 코드를 스캔하여 스탬프를 모으세요!',
      'en': 'Visit 3 locations and\nscan QR codes to collect stamps!',
      'ja': '3箇所を訪問して\nQRコードをスキャンしてスタンプを集めよう！',
      'zh': '访问3个地点\n扫描QR码收集印章！',
    },
    'stampBoard': {
      'ko': '스탬프 보드',
      'en': 'Stamp Board',
      'ja': 'スタンプボード',
      'zh': '集章板',
    },
    'locationA': {
      'ko': '장소 A',
      'en': 'Location A',
      'ja': '場所A',
      'zh': '地点A',
    },
    'locationB': {
      'ko': '장소 B',
      'en': 'Location B',
      'ja': '場所B',
      'zh': '地点B',
    },
    'locationC': {
      'ko': '장소 C',
      'en': 'Location C',
      'ja': '場所C',
      'zh': '地点C',
    },
    'scanQR': {
      'ko': 'QR 코드 스캔',
      'en': 'Scan QR Code',
      'ja': 'QRコードスキャン',
      'zh': '扫描QR码',
    },
    'stampCollected': {
      'ko': '스탬프 획득!',
      'en': 'Stamp Collected!',
      'ja': 'スタンプ獲得！',
      'zh': '集章成功！',
    },
    'stampCollectedDesc': {
      'ko': '이 장소의 스탬프를 획득했습니다',
      'en': 'You have collected this location\'s stamp',
      'ja': 'この場所のスタンプを獲得しました',
      'zh': '您已收集此地点的印章',
    },
    'allStampsCollected': {
      'ko': '모든 스탬프를 모았습니다!',
      'en': 'All stamps collected!',
      'ja': 'すべてのスタンプを集めました！',
      'zh': '已收集所有印章！',
    },
    'rewardMessage': {
      'ko': '축하합니다! 🎉\nLED 송출 무료 쿠폰을 받으세요!',
      'en': 'Congratulations! 🎉\nGet your free LED display coupon!',
      'ja': 'おめでとうございます！🎉\nLED表示無料クーポンをゲット！',
      'zh': '恭喜！🎉\n获取免费LED展示优惠券！',
    },
    'getCoupon': {
      'ko': '쿠폰 받기',
      'en': 'Get Coupon',
      'ja': 'クーポンを受け取る',
      'zh': '领取优惠券',
    },
    'couponCode': {
      'ko': '쿠폰 코드',
      'en': 'Coupon Code',
      'ja': 'クーポンコード',
      'zh': '优惠券代码',
    },
    'couponDesc': {
      'ko': 'AI 이미지 체험의 프리미엄 LED 송출에서 사용하세요',
      'en': 'Use this for premium LED display in AI Image Experience',
      'ja': 'AI画像体験のプレミアムLED表示で使用してください',
      'zh': '在AI图像体验的高级LED展示中使用',
    },
    'copyCoupon': {
      'ko': '쿠폰 코드 복사',
      'en': 'Copy Coupon Code',
      'ja': 'クーポンコードをコピー',
      'zh': '复制优惠券代码',
    },
    'copied': {
      'ko': '복사 완료!',
      'en': 'Copied!',
      'ja': 'コピーしました！',
      'zh': '已复制！',
    },
    'notCollected': {
      'ko': '미획득',
      'en': 'Not collected',
      'ja': '未獲得',
      'zh': '未收集',
    },
    'collected': {
      'ko': '획득 완료',
      'en': 'Collected',
      'ja': '獲得済み',
      'zh': '已收集',
    },
    'confirm': {
      'ko': '확인',
      'en': 'Confirm',
      'ja': '確認',
      'zh': '确认',
    },

    // ===================== COMMON =====================
    'locationRequired': {
      'ko': '현장 반경 300m 내에서만 이용 가능합니다',
      'en': 'Available only within 300m of the venue',
      'ja': '会場の半径300m以内でのみ利用可能です',
      'zh': '仅在场地300米范围内可用',
    },
    'locationCheckFailed': {
      'ko': '위치 확인에 실패했습니다. GPS를 확인해 주세요.',
      'en': 'Location check failed. Please check your GPS.',
      'ja': '位置確認に失敗しました。GPSを確認してください。',
      'zh': '位置确认失败，请检查GPS。',
    },
    'cameraPermission': {
      'ko': '카메라 권한이 필요합니다',
      'en': 'Camera permission is required',
      'ja': 'カメラの許可が必要です',
      'zh': '需要相机权限',
    },
    'processing': {
      'ko': '처리 중...',
      'en': 'Processing...',
      'ja': '処理中...',
      'zh': '处理中...',
    },
    'error': {
      'ko': '오류가 발생했습니다',
      'en': 'An error occurred',
      'ja': 'エラーが発生しました',
      'zh': '发生错误',
    },
    'retry': {
      'ko': '다시 시도',
      'en': 'Retry',
      'ja': '再試行',
      'zh': '重试',
    },
    'cancel': {
      'ko': '취소',
      'en': 'Cancel',
      'ja': 'キャンセル',
      'zh': '取消',
    },
    'close': {
      'ko': '닫기',
      'en': 'Close',
      'ja': '閉じる',
      'zh': '关闭',
    },
    'paymentProcessing': {
      'ko': '결제 처리 중...',
      'en': 'Processing payment...',
      'ja': '決済処理中...',
      'zh': '正在处理支付...',
    },
    'paymentComplete': {
      'ko': '결제가 완료되었습니다',
      'en': 'Payment completed',
      'ja': '決済が完了しました',
      'zh': '支付完成',
    },
    'invalidCoupon': {
      'ko': '유효하지 않은 쿠폰입니다',
      'en': 'Invalid coupon',
      'ja': '無効なクーポンです',
      'zh': '无效优惠券',
    },
    'couponApplied': {
      'ko': '쿠폰이 적용되었습니다',
      'en': 'Coupon applied',
      'ja': 'クーポンが適用されました',
      'zh': '优惠券已应用',
    },
    'minutes': {
      'ko': '분',
      'en': 'min',
      'ja': '分',
      'zh': '分钟',
    },

    // ===================== CONSENT =====================
    'consentTitle': {
      'ko': '개인정보 수집 및 제3자 제공 동의',
      'en': 'Privacy Consent',
      'ja': '個人情報の収集・第三者提供への同意',
      'zh': '个人信息收集及第三方提供同意',
    },
    'consentIntro': {
      'ko': 'AI 이미지 합성 서비스를 이용하려면 아래 개인정보 처리에 동의해 주세요.',
      'en': 'To use the AI image service, please agree to the following data processing.',
      'ja': 'AI画像合成サービスを利用するには、以下の個人情報処理にご同意ください。',
      'zh': '要使用AI图像合成服务，请同意以下个人信息处理。',
    },
    'consentCollectedData': {
      'ko': '수집 항목',
      'en': 'Data Collected',
      'ja': '収集項目',
      'zh': '收集项目',
    },
    'consentCollectedDataValue': {
      'ko': '얼굴 사진 (업로드한 이미지)',
      'en': 'Face photo (uploaded image)',
      'ja': '顔写真（アップロード画像）',
      'zh': '面部照片（上传的图像）',
    },
    'consentRecipient': {
      'ko': '제3자 제공 대상',
      'en': 'Third-party recipient',
      'ja': '第三者提供先',
      'zh': '第三方接收方',
    },
    'consentRecipientValue': {
      'ko': 'Google LLC (Gemini AI)',
      'en': 'Google LLC (Gemini AI)',
      'ja': 'Google LLC（Gemini AI）',
      'zh': 'Google LLC（Gemini AI）',
    },
    'consentPurpose': {
      'ko': '이용 목적',
      'en': 'Purpose',
      'ja': '利用目的',
      'zh': '使用目的',
    },
    'consentPurposeValue': {
      'ko': 'AI 이미지 합성 및 생성',
      'en': 'AI image synthesis and generation',
      'ja': 'AI画像合成・生成',
      'zh': 'AI图像合成与生成',
    },
    'consentRetention': {
      'ko': '보유 기간',
      'en': 'Retention period',
      'ja': '保有期間',
      'zh': '保留期限',
    },
    'consentRetentionValue': {
      'ko': '처리 후 즉시 삭제 (Google 정책에 따름)',
      'en': 'Deleted immediately after processing (per Google policy)',
      'ja': '処理後即時削除（Googleポリシーに準拠）',
      'zh': '处理后立即删除（遵循Google政策）',
    },
    'consentAgree': {
      'ko': '동의합니다',
      'en': 'I Agree',
      'ja': '同意します',
      'zh': '我同意',
    },
    'consentDecline': {
      'ko': '거부합니다',
      'en': 'I Decline',
      'ja': '拒否します',
      'zh': '我拒绝',
    },
    'consentPrivacyPolicy': {
      'ko': '개인정보처리방침 보기',
      'en': 'View Privacy Policy',
      'ja': 'プライバシーポリシーを見る',
      'zh': '查看隐私政策',
    },
    'consentDeclinedNotice': {
      'ko': '동의가 필요합니다\n\nAI 이미지 체험을 이용하려면 개인정보 수집·제3자 제공에 동의하셔야 합니다.',
      'en': 'Consent required\n\nYou must agree to the data collection and sharing to use the AI image experience.',
      'ja': '同意が必要です\n\nAI画像体験を利用するには、個人情報の収集・提供に同意する必要があります。',
      'zh': '需要同意\n\n使用AI图像体验须同意个人信息的收集和共享。',
    },

    // ===================== SETTINGS =====================
    'settings': {
      'ko': '설정',
      'en': 'Settings',
      'ja': '設定',
      'zh': '设置',
    },
    'settingsAiConsent': {
      'ko': 'AI 데이터 수집 동의',
      'en': 'AI Data Collection Consent',
      'ja': 'AIデータ収集への同意',
      'zh': 'AI数据收集同意',
    },
    'settingsAiConsentDesc': {
      'ko': '얼굴 사진을 Google Gemini AI에 전송하는 것에 동의합니다.',
      'en': 'Agree to send face photo to Google Gemini AI.',
      'ja': '顔写真をGoogle Gemini AIに送信することに同意します。',
      'zh': '同意将面部照片发送至Google Gemini AI。',
    },
    'settingsConsentRevokeWarning': {
      'ko': '동의를 철회하면 AI 분석 및 사진 수정 기능을 사용할 수 없습니다.',
      'en': 'Revoking consent disables the AI analysis and photo editing features.',
      'ja': '同意を取り消すと、AI分析・写真編集機能が使用できなくなります。',
      'zh': '撤回同意后将无法使用AI分析和照片编辑功能。',
    },
    'settingsPrivacyPolicy': {
      'ko': '개인정보처리방침',
      'en': 'Privacy Policy',
      'ja': 'プライバシーポリシー',
      'zh': '隐私政策',
    },
  };

  String tr(String key) {
    return _translations[key]?[languageCode] ??
        _translations[key]?['en'] ??
        key;
  }
}
