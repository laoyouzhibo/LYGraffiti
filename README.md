#  如何生成LYGraffiti.xcframework
1. cd /LYGraffitiDemo/LYGraffiti
2. xcodebuild archive -scheme LYGraffiti -archivePath "./build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO 
3. xcodebuild archive -scheme LYGraffiti -archivePath "./build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO
4. xcodebuild -create-xcframework -framework "./build/ios.xcarchive/Products/Library/Frameworks/LYGraffiti.framework" -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/LYGraffiti.framework" -output "./build/LYGraffiti.xcframework" 
