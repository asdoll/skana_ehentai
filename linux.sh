version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)

flutter build linux --release -t lib/main.dart \
&& mkdir ~/Desktop/SkanaEH_${version} \
&& cp -r build/linux/x64/release/bundle/* ~/Desktop/SkanaEH_${version}/ \
&& cd ~/Desktop \
&& zip -ro SkanaEH_${version}.zip SkanaEH_${version} \
&& rm -rf mkdir ~/Desktop/SkanaEH_${version}
