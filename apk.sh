version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)

flutter build apk -t lib/main.dart --split-per-abi \
&& cp build/app/outputs/apk/release/app-arm64-v8a-release.apk ~/Desktop/SkanaEH-${version}-arm64-v8a.apk \
&& cp build/app/outputs/apk/release/app-armeabi-v7a-release.apk ~/Desktop/SkanaEH-${version}-armeabi-v7a.apk \
&& cp build/app/outputs/apk/release/app-x86_64-release.apk ~/Desktop/SkanaEH-${version}-x86_64.apk \
