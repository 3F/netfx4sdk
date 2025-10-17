# [netfx4sdk](https://github.com/3F/netfx4sdk)

An attempt to provide *.NET Framework 4.x* Developer Packs (SDKs) support for modern Visual Studio / MSBuild / etc.

* Various modes;
* Rollback support (changes can be easily undone at any time);
* Pure batch-script;
* Portable and flexible solution;
* Free and Open source https://github.com/3F/netfx4sdk

Based on [hMSBuild](https://github.com/3F/hMSBuild) + [GetNuTool](https://github.com/3F/GetNuTool)

```r
Copyright (c) 2021-2025  Denis Kuzmin <x-3F@outlook.com> github/3F
```

[`gnt`](https://3F.github.io/GetNuTool/releases/latest/gnt/)`~netfx4sdk`

[ 「 ❤ 」 ](https://3F.github.io/fund) [![License](https://img.shields.io/badge/License-MIT-74A5C2.svg)](https://github.com/3F/netfx4sdk/blob/master/License.txt)
[![Build status](https://ci.appveyor.com/api/projects/status/7d2jae48fii2m99o/branch/master?svg=true)](https://ci.appveyor.com/project/3Fs/netfx4sdk/branch/master)
[![release](https://img.shields.io/github/release/3F/netfx4sdk.svg)](https://github.com/3F/netfx4sdk/releases/latest)

## Why netfx4sdk

*netfx4sdk* allows you to easily use the legacy (deprecated) SDK for modern toolsets and IDEs such as VS2022+ / MSBuild 17+ / and other tools without installing any other outdated versions of Visual Studio.

Because Microsoft officially dropped support of the **Developer Pack** (SDK) for .NET Framework 4.0. Now it can only be a **Runtime** version: https://dotnet.microsoft.com/en-us/download/visual-studio-sdks

Means you [can't simply **build** anything](https://ci.appveyor.com/project/3Fs/vssolutionbuildevent/builds/42027332#L121) along with pure VS2022 (e.g. [VM image, clean VS2022 env](https://ci.appveyor.com/project/3Fs/vssolutionbuildevent/builds/42027332#L121))

> MSB3644: The reference assemblies for .NETFramework,Version=v4.0 were not found. To resolve this, **install the Developer Pack** (SDK/Targeting Pack) for this framework version or retarget your application. You can (\*no, you can't) download .NET Framework Developer Packs at https://aka.ms/msbuild/developerpacks

But *netfx4sdk* will try to eliminate this artificial limitation by a single command,

* Here's [**result**](https://ci.appveyor.com/project/3Fs/vssolutionbuildevent/builds/42060343#L6) using *netfx4sdk 1.0* for the same clean VS2022 VM image above.

## Usage

`-mode sys` Hack using assemblies for Windows. Highly *recommended* because:

* [++] All modules are under Windows support.
* [+] It does not require internet connection (portable).
* [+] No decompression required (faster) compared to package mode.
* [-] This is behavior-based hack;

`-mode pkg` will try to apply remote package to the environment.

* [-] Officially dropped support since VS2022.
* [-] Requires internet connection to receive ~30 MB via GetNuTool.
* [-] Requires decompression of received data to 178 MB before use.
* [+] Well known official behavior.

### Keys

```bat
 -mode {value}
   * system            - (Recommended) Hack using assemblies for Windows.
   * package           - Apply remote package. Read [About modes] below.
   * sys               - Alias to 'system'.
   * pkg               - Alias to 'package'.
   * system-or-package - Fallback to 'system'. Use 'package' if 'system' failed.
   * package-or-system - Fallback to 'package'. Use 'system' if 'package' failed.
   * sys-or-pkg        - Alias to 'system-or-package'.
   * pkg-or-sys        - Alias to 'package-or-system'.

 -tfm {version}
   * 4.0 - Process for .NET Framework 4.0 (default)
   * 2.0, 3.5, 4.5, 4.6, 4.7, 4.8
   * 4.5.1, 4.5.2, 4.6.1, 4.6.2, 4.7.1, 4.7.2, 4.8.1

 -force      - Aggressive behavior when applying etc.
 -rollback   - Rollback applied modifications.
 -global     - To use the global toolset, like hMSBuild.
 -no-mklink  - Use direct copying instead of mklink (junction / symbolic).
 -stub       - Use a stub instead of actual processing.

 -pkg-version {arg} - Specific package version in pkg mode. Where {arg}:
     * 1.0.3 ...
     * latest - (keyword) To use latest version;

 -debug    - To show debug information.
 -version  - Display version of netfx4sdk.cmd.
 -help     - Display this help. Aliases: -help -h -?
```

### Examples

```bat
netfx4sdk -mode sys
netfx4sdk -rollback
netfx4sdk -debug -force -mode package
netfx4sdk -mode pkg -pkg-version 1.0.2
netfx4sdk -mode pkg -tfm 4.5
netfx4sdk -global -mode pkg -tfm 3.5 -no-mklink -force
call netfx4sdk -mode sys || call netfx4sdk -mode pkg
netfx4sdk -mode sys-or-pkg
```

## Get netfx4sdk

* Using GetNuTool: [`gnt`](https://3F.github.io/GetNuTool/releases/latest/gnt/)`~netfx4sdk`
* Using hMSBuild: [`hMSBuild`](https://3F.github.io/hMSBuild/releases/latest/gnt/)`-GetNuTool ~netfx4sdk`
* GitHub Releases: https://github.com/3F/netfx4sdk/releases/latest

## Build and Use from source

```bat
git clone https://github.com/3F/netfx4sdk.git src
cd src & build & cd bin\Release\raw\
netfx4sdk -help
```

### .sha1 official distribution

*netfx4sdk* releases are now accompanied by a *.sha1* file in the official distribution; At the same time, commits from which releases are published are signed with the committer's verified signature (GPG).

Make sure you are using official, unmodified, safe versions.

Note: *.sha1* file is a text list of published files with checksums in the format: 

`40-hexadecimal-digits` `<space>` `file`

```
e9e533b0da8e5546eff821a40fbf7ca20ab9cf7e path\file
...
```

#### netfx4sdk.cmd validation

Since *netfx4sdk.cmd* relies on the [hMSBuild](https://github.com/3F/hMSBuild) and [GetNuTool](https://github.com/3F/GetNuTool), you can validate it like: 

> hMSBuild -GetNuTool ~& svc.gnt -sha1-cmp netfx4sdk.cmd sha1 -package-as-path

or

> gnt ~& svc.gnt -sha1-cmp netfx4sdk.cmd sha1 -package-as-path

Where *sha1* is the checksum from the [official distribution](https://github.com/3F/netfx4sdk).

Or, the official [package](https://www.nuget.org/packages/netfx4sdk/) (`gnt +netfx4sdk`) provides *validate.hMSBuild.bat*; this is wrapper of the command above.

How safe is it?

* [hMSBuild.bat self validation](https://github.com/3F/hMSBuild/?tab=readme-ov-file#hmsbuildbat-self-validation)
* [gnt.bat self validation](https://github.com/3F/GetNuTool?tab=readme-ov-file#gntbat-self-validation)

## Contributing

[*netfx4sdk*](https://github.com/3F/netfx4sdk) is waiting for your awesome contributions!