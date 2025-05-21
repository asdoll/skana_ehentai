version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)

flutter build windows -t lib/main.dart \
&& cp -r build/windows/runner/Release/ ~/Desktop/SkanaEH_${version}_windows/ \
&& cd ~/Desktop \
&& zip -ro SkanaEH_${version}_windows.zip SkanaEH_${version}_windows \
&& rm -rf SkanaEH_${version}_windows
