version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)

flutter build macos --release -t lib/main.dart \
&& hdiutil create -size 150m -fs HFS+ -volname SkanaEH SkanaEH.dmg \
&& hdiutil attach SkanaEH.dmg \
&& cp -R build/macos/Build/Products/Release/skana_ehentai.app /Volumes/SkanaEH \
&& pkgbuild --install-location /Applications/SkanaEH.app --identifier com.skanaone.skana_ehentai --version ${version} --root /Volumes/SkanaEH/skana_ehentai.app build/macos/SkanaEH-${version}.pkg \
&& hdiutil detach /Volumes/SkanaEH
