# [netfx4sdk](https://github.com/3F/netfx4sdk)

An attempt to provide *.NET Framework 4.0* Developer Pack (SDK) support for modern Visual Studio / MSBuild / etc.

Two modes! Pure batch-scripts! Portable and Flexible (changes can be easily undone) ! Free and Open !

Based on [hMSBuild](https://github.com/3F/hMSBuild) + [GetNuTool](https://github.com/3F/GetNuTool)

```r
Copyright (c) 2021-2025  Denis Kuzmin <x-3F@outlook.com> github/3F
```

[ 「 ❤ 」 ](https://3F.github.io/fund) [![License](https://img.shields.io/badge/License-MIT-74A5C2.svg)](https://github.com/3F/netfx4sdk/blob/master/License.txt)
[![Build status](https://ci.appveyor.com/api/projects/status/7d2jae48fii2m99o/branch/master?svg=true)](https://ci.appveyor.com/project/3Fs/netfx4sdk/branch/master)
[![release](https://img.shields.io/github/release/3F/netfx4sdk.svg)](https://github.com/3F/netfx4sdk/releases/latest)

## Why netfx4sdk

*netfx4sdk* allows you to use easily a deprecated SDK for modern toolsets and IDEs such as VS2022+ / MSBuild 17+ / and other tools without installing any other outdated versions of Visual Studio.

Microsoft officially dropped support of the **Developer Pack** (SDK) for .NET Framework 4.0. Now it can only be a **Runtime** version: https://dotnet.microsoft.com/en-us/download/visual-studio-sdks

Means you [can't simply **build** anything](https://ci.appveyor.com/project/3Fs/vssolutionbuildevent/builds/42027332#L121) along with pure VS2022 (e.g. [VM image, clean VS2022 env](https://ci.appveyor.com/project/3Fs/vssolutionbuildevent/builds/42027332#L121))

> MSB3644: The reference assemblies for .NETFramework,Version=v4.0 were not found. To resolve this, **install the Developer Pack** (SDK/Targeting Pack) for this framework version or retarget your application. You can (\*no, you can't) download .NET Framework Developer Packs at https://aka.ms/msbuild/developerpacks

But *netfx4sdk* will try to eliminate this artificial limitation by a single command,

* Here's [**result**](https://ci.appveyor.com/project/3Fs/vssolutionbuildevent/builds/42060343#L6) using *netfx4sdk 1.0* for the same clean VS2022 VM image above.

## Usage

`-mode sys` - Hack using assemblies for windows. Highly *recommended* because

* [++] All modules are under windows support.
* [+] It does not require internet connection (portable).
* [+] No decompression required (faster) compared to package mode.
* [-] This is behavior-based hack;

`-mode package` will try to apply obsolete package to the environment.

* [-] Officially dropped support since VS2022.
* [-] Requires internet connection to receive ~30 MB via GetNuTool.
* [-] Requires decompression of received data to 178 MB before use.
* [+] Well known official behavior.

### Arguments

```bat
 -mode {value}
  * system   - (Recommended) Hack using assemblies for windows.
  * package  - Apply obsolete remote package. Read [About modes] below.
  * sys      - Alias to `system`
  * pkg      - Alias to `package`

 -force    - Aggressive behavior when applying etc.
 -rollback - Rollback applied modifications.
 -global   - To use the global toolset, like hMSBuild.

 -pkg-version {arg} - Specific package version. Where {arg}:
     * 1.0.3 ...
     * latest - (keyword) To use latest version;

 -debug    - To show debug information.
 -version  - Display version of netfx4sdk.cmd.
 -help     - Display this help. Aliases: -help -h -?
```

### Samples

```bat
netfx4sdk -mode sys
netfx4sdk -rollback
netfx4sdk -debug -force -mode package
netfx4sdk -mode pkg -pkg-version 1.0.2
```

## Download

https://github.com/3F/netfx4sdk/releases/latest

## Build and Use from source

```bat
git clone https://github.com/3F/netfx4sdk.git src
cd src & build & bin\Release\raw\netfx4sdk -help
```

### .sha1 official distribution

*netfx4sdk* releases are now accompanied by a *.sha1* file in the official distribution; At the same time, commits from which releases are published are signed with the committer's verified signature (GPG).

Make sure you are using official, unmodified, safe versions.

Note: *.sha1* file is a text list of published files with checksums in the format: 

`40-hexadecimal-digits` `<space>` `file`

```
eead8f5c1fdff2abd4da7d799fbbe694d392c792 path\file
...
```

## Contributing

[*netfx4sdk*](https://github.com/3F/netfx4sdk) is waiting for your awesome contributions!