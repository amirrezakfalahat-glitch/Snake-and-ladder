# بازی مار و پله — راهنمای ساخت APK

## باگی که پیدا و اصلاح شد
کد اصلی از پکیج `canvas_confetti` استفاده می‌کرد که روی pub.dev وجود ندارد.
پکیج درست `flutter_confetti` است (همون که `Confetti.launch()` و `ConfettiOptions` رو داره).
این تغییر توی `lib/main.dart` و `pubspec.yaml` اعمال شده.

## راه ۱: ساخت خودکار با GitHub Actions (پیشنهادی، بدون نیاز به نصب چیزی)
1. یه ریپازیتوری جدید توی گیت‌هاب بساز.
2. کل این پوشه (`snake_ladder/`) رو توش آپلود/پوش کن (شامل فولدر مخفی `.github`).
3. برو تب **Actions** توی گیت‌هاب — یه workflow به اسم "Build APK" خودکار اجرا می‌شه.
4. بعد از چند دقیقه، از همون صفحه‌ی اجرا شده، بخش **Artifacts** پایین صفحه رو باز کن و فایل `snake-ladder-apk` رو دانلود کن. داخلش `app-release.apk` هست.

اجرای دستی هم می‌تونی بزنی: تب Actions → Build APK → Run workflow.

## راه ۲: روی سیستم خودت
اگه Flutter SDK نصب داری:
```bash
cd snake_ladder
flutter pub get
flutter build apk --release
```
فایل نهایی: `build/app/outputs/flutter-apk/app-release.apk`

## راه ۳: FlutLab.io
اگه نمی‌خوای چیزی نصب کنی، می‌تونی محتوای `lib/main.dart` و `pubspec.yaml` رو توی FlutLab.io (IDE آنلاین فلاتر) پیست کنی و از همون‌جا APK بگیری.
