# Xamarin.iOS Signed Build GitHub Action

Creates signed `ipa` files for Xamarin.iOS projects using GitHub Actions.

## Usage

Example usage in a worfklow:

```yaml
name: Build

on:
  workflow_dispatch

jobs:   
  iOS:
    name: iOS
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - uses: bradyjoslin/xamarinios-signedbuild-action@v1
        with:
          csproj_path: src/sample.iOS/sample.iOS.csproj
          mobileprovision: ${{ secrets.MOBILEPROVISION }}
          cert_p12: ${{ secrets.CERT_P12 }}
          p12_pass: ${{ secrets.P12_PASS }}
          configuration: 'Release'
          mono_version: 'preview'
          xamarin_ios_version: 'preview'
      - uses: actions/upload-artifact@v2
        with:
          name: ipa
          path: src/*.iOS/bin/iPhone/Release/**.ipa
```

## Inputs

| input               | value                                                                             | required?             |
| ------------------- | --------------------------------------------------------------------------------- | --------------------- |
| csproj_path         | Path to csproj file                                                               | Y                     |
| mobileprovision     | Base64 representation of mobile provisioning file                                 | Y                     |
| cert_p12            | Base64 representation p12 distribution cert                                       | Y                     |
| p12_pass            | Password used when exporting p12 distribution cert from keychain                  | Y                     |
| configuration       | Build configuration                                                               | N - Default `Release` |
| mono_version        | Version of mono to use for build. `stable`, `preview` or url to mono pkg          | N - Default `stable`  |
| xamarin_ios_version | Version of Xamarin.iOS to use for build. `stable`, `preview` or url to mono pkg   | N - Default `stable`  |

##  FAQ

**How do you create base64 of p12 or mobileprovision file?**

`base64 cert.12 > cert.txt`

The contents of the text file is the p12 file in base64 format, which you can store as a GitHub Secret.

**How do I use specific versions of mono/Xamarin.iOS for my build?**

This action uses [boots](https://github.com/jonathanpeppers/boots/).  To install a specific version of mono and Xamarin.iOS pass in the URL to the package of the version you would like to use.  For details on how to find the URL to use, see the [boots doc](https://github.com/jonathanpeppers/boots/blob/master/docs/HowToFindBuilds.md).
