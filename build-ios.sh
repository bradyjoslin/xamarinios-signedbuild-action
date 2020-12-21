#!/bin/bash

set -e

pwd

# Regenerate the mobileprovision from base64
cd "$RUNNER_TEMP" || exit 1
echo -n "$MOBILEPROVISION" | base64 --decode --output CI.mobileprovision
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp CI.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles

# Regenerate the p12 from base64 and install in new temp keychain
KEYCHAIN_PATH=$RUNNER_TEMP/temp
echo -n "$CERT_P12" | base64 --decode --output cicert.p12
security create-keychain -p "$KEYCHAIN_PASS" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASS" "$KEYCHAIN_PATH"
security import cicert.p12 -P "$P12_PASS" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security list-keychain -d user -s "$KEYCHAIN_PATH"

# Setup build tools
export PATH="$PATH:~/.dotnet/tools"
dotnet tool install --global boots

if [ -n "$MONO_VERSION" ]
then
    case "$MONO_VERSION" in
        stable)
            boots --stable Mono
            ;;
        preview)
            boots --preview Mono
            ;;
        *)
            boots "$MONO_VERSION"
            ;;
    esac
else
    boots --stable Mono
fi

if [ -n "$XAMARIN_IOS_VERSION" ]
then
    case "$XAMARIN_IOS_VERSION" in
        stable)
            boots --stable XamariniOS
            ;;
        preview)
            boots --preview XamariniOS
            ;;
        *)
            boots "$XAMARIN_IOS_VERSION"
            ;;
    esac
else
    boots --stable XamariniOS
fi

# Build iOS
CSPROJ_DIR=$(dirname "$CSPROJ_PATH")
CSPROJ_FILENAME=$(basename "$CSPROJ_PATH")

cd "$CSPROJ_DIR" && cd ../ || exit 1
nuget restore

if [ -z "$CONFIGURATION" ]
then
    CONFIGURATION=Release
fi

echo "csproj $CSPROJ_DIR"

cd "$CSPROJ_DIR" || exit 1
msbuild "$CSPROJ_FILENAME" /verbosity:normal /t:Rebuild /p:Platform=iPhone /p:Configuration="$CONFIGURATION" /p:BuildIpa=true

# Clean up
rm ~/Library/MobileDevice/Provisioning\ Profiles/CI.mobileprovision
