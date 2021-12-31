# [netfx4sdk](https://github.com/3F/netfx4sdk)

A hack for dev environments to provide *.NET Framework 4.0* Developer Pack (SDK) support for modern versions of the Visual Studio 2022+ or another.

It doesn't require installation of outdated Visual Studio such as VS2019.

Two modes. Pure batch-scripts. Based on [hMSBuild](https://github.com/3F/hMSBuild) + [GetNuTool core](https://github.com/3F/GetNuTool)

```r
Copyright (c) 2021  Denis Kuzmin <x-3F@outlook.com> github/3F
```

[ 「 <sub>@</sub> ☕ 」 ](https://3F.github.io/Donation/) [![License](https://img.shields.io/badge/License-MIT-74A5C2.svg)](https://github.com/3F/netfx4sdk/blob/master/License.txt)

[![Build status](https://ci.appveyor.com/api/projects/status/8ac1021k385eyubm/branch/master?svg=true)](https://ci.appveyor.com/project/3Fs/netfx4sdk/branch/master)
[![release](https://img.shields.io/github/release/3F/netfx4sdk.svg)](https://github.com/3F/netfx4sdk/releases/latest)

## Why netfx4sdk ?

Microsoft officially dropped support of the **Developer Pack** (SDK) for .NET Framework 4.0.

* Now it can only be a **Runtime** version: https://dotnet.microsoft.com/en-us/download/visual-studio-sdks

Means you [can't simply **build** anything](https://ci.appveyor.com/project/3Fs/vssolutionbuildevent/builds/42027332#L121) along with pure VS2020 (eg. [VM image, clean VS2022 env](https://ci.appveyor.com/project/3Fs/vssolutionbuildevent/builds/42027332#L121))

> MSB3644: The reference assemblies for .NETFramework,Version=v4.0 were not found. To resolve this, **install the Developer Pack** (SDK/Targeting Pack) for this framework version or retarget your application. You can (\*no, you can't) download .NET Framework Developer Packs at https://aka.ms/msbuild/developerpacks

However, *netfx4sdk* can help you!

## Usage

Two modes.

`-mode sys` - Hack using assemblies for windows. Highly *recommended* because of

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
   * sys       - (Recommended) Hack using assemblies for windows.
   * package   - Apply obsolete remote package. Read [About modes] below.

 -force        - Aggressive behavior when applying etc.
 -rollback     - Rollback applied modifications.
 -debug        - To show debug information.
 -version      - Display version of netfx4sdk.cmd.
 -help         - Display this help. Aliases: -help -h -?
```

### Samples

```bat
netfx4sdk -mode sys
netfx4sdk -rollback
netfx4sdk -debug -force -mode package
```