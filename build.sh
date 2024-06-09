# Build the circuits
echo "Building the circuits..."
./scripts/build_register_circuit.sh
./scripts/build_disclose_circuit.sh

# Copy register_sha256WithRSAEncryption_65537.cpp and disclose.cpp to /witnesscalc/src
echo "Copying register_sha256WithRSAEncryption_65537.cpp and disclose.cpp to /witnesscalc/src..."
cd witnesscalc
./patch_cpp.sh ../build/register_sha256WithRSAEncryption_65537_cpp/register_sha256WithRSAEncryption_65537.cpp > ./src/register_sha256WithRSAEncryption_65537.cpp
./patch_cpp.sh ../build/disclose_cpp/disclose.cpp > ./src/disclose.cpp

# Copy register_sha256WithRSAEncryption_65537.dat and disclose.dat to /witnesscalc/src
echo "Copying register_sha256WithRSAEncryption_65537.bat and disclose.bat to /witnesscalc/src..."
cp ../build/register_sha256WithRSAEncryption_65537_cpp/register_sha256WithRSAEncryption_65537.dat ./src/register_sha256WithRSAEncryption_65537.dat
cp ../build/disclose_cpp/disclose.dat ./src/disclose.dat

# Build the witnesscalc for iOS
echo "Building the witnesscalc for iOS..."
./build_gmp.sh ios
make ios
echo "Build completed. The generated project is here /build_witnesscalc_ios/witnesscalc.xcodeproj"

# Open the project in Xcode
echo "Opening the generated project in Xcode..."
echo "Make sure to set the development team in the Build Settings before building the project."
open ./witnesscalc/build_witnesscalc_ios/witnesscalc.xcodeproj

# Build the witnesscalc for Android
echo "Building the witnesscalc for Android..."
# Check ANDROID_HOME and NDK_VERSION is set
if [ -z "$ANDROID_HOME" ]; then
    echo "ANDROID_HOME is not set. Please set it to the Android SDK location."
    echo "Example: export ANDROID_HOME=/Users/username/Library/Android/sdk"
    exit 1
fi

if [ -z "$NDK_VERSION" ]; then
    echo "NDK_VERSION is not set. Please set it to the Android NDK version."
    echo "Example: export NDK_VERSION=26.3.11579264"
    exit 1
fi

export ANDROID_NDK=$ANDROID_HOME/ndk/$NDK_VERSION

./build_gmp.sh android
make android

echo "Build completed. You can find the relevant files in /witnesscalc/package_android"