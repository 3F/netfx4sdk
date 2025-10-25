# [netfx4sdk](https://github.com/3F/netfx4sdk)

An attempt to provide *.NET Framework 4.x* Developer Packs (SDKs) support for modern Visual Studio / MSBuild / etc.

* Various modes;
* Rollback support (changes can be easily undone at any time);
* Pure LF protected batch-script (.bat/.cmd) that does NOT require *powershell* or *dotnet-cli*;
* Portable and flexible solution;
  * Internet connection is NOT needed for system mode;
  * Lightweight and text-based, about ~11 KB + ~18 KB;
* Free and Open source https://github.com/3F/netfx4sdk

Based on [hMSBuild.bat](https://github.com/3F/hMSBuild) + [GetNuTool](https://github.com/3F/GetNuTool)

```r
Copyright (c) 2021-2025  Denis Kuzmin <x-3F@outlook.com> github/3F
```

[ 「 ❤ 」 ](https://3F.github.io/fund) [![License](https://img.shields.io/badge/License-MIT-74A5C2.svg)](https://github.com/3F/netfx4sdk/blob/master/License.txt)
[![Build status](https://ci.appveyor.com/api/projects/status/7d2jae48fii2m99o/branch/master?svg=true)](https://ci.appveyor.com/project/3Fs/netfx4sdk/branch/master)
[![release](https://img.shields.io/github/release/3F/netfx4sdk.svg)](https://github.com/3F/netfx4sdk/releases/latest)

## Quick start

* Using GetNuTool: [`gnt`](https://3F.github.io/GetNuTool/releases/latest/gnt/)`~netfx4sdk`
* Using hMSBuild: [`hMSBuild`](https://3F.github.io/hMSBuild/releases/latest/gnt/)`-GetNuTool ~netfx4sdk`
* GitHub Releases: https://github.com/3F/netfx4sdk/releases/latest

For example: [`gnt`](https://3F.github.io/GetNuTool/releases/latest/gnt/)`~netfx4sdk & netfx4sdk -mode sys-or-pkg`

Or build and use from source:

```bat
git clone https://github.com/3F/netfx4sdk.git src
cd src & build & cd bin\Release\raw\
netfx4sdk -help
```

Note: starting with 2.0, in addition to `-rollback`, you can also use `-stub` key to check the commands for all planned changes without actually affecting the file system.

## Why netfx4sdk

*netfx4sdk* allows you to easily use the legacy (deprecated) SDK for modern toolsets and IDEs such as VS2022+ / MSBuild 17+ / and other tools without installing any other outdated versions of Visual Studio.

Because Microsoft officially dropped support of the **Developer Pack** (SDK) for .NET Framework 4.0. Now it can only be a **Runtime** version: https://dotnet.microsoft.com/en-us/download/visual-studio-sdks

Means you [can't simply **build** anything](https://ci.appveyor.com/project/3Fs/vssolutionbuildevent/builds/42027332#L121) along with pure VS2022 (e.g. [VM image, clean VS2022 env](https://ci.appveyor.com/project/3Fs/vssolutionbuildevent/builds/42027332#L121))

> MSB3644: The reference assemblies for .NETFramework,Version=v4.0 were not found. To resolve this, **install the Developer Pack** (SDK/Targeting Pack) for this framework version or retarget your application. You can (\*no, you can't) download .NET Framework Developer Packs at https://aka.ms/msbuild/developerpacks

But *netfx4sdk* will try to eliminate this artificial limitation by a single command,

* Here's [**result**](https://ci.appveyor.com/project/3Fs/vssolutionbuildevent/builds/42060343#L6) using *netfx4sdk 1.0* for the same clean VS2022 VM image above.

### List of supported SDKs

1.x

* .NET Framework 4.0

2.0+

* .NET Framework 2.0
* .NET Framework 3.5
* .NET Framework 4.0
* .NET Framework 4.5
  * .NET Framework 4.5.1
  * .NET Framework 4.5.2
* .NET Framework 4.6
  * .NET Framework 4.6.1
  * .NET Framework 4.6.2
* .NET Framework 4.7
  * .NET Framework 4.7.1
  * .NET Framework 4.7.2
* .NET Framework 4.8
  * .NET Framework 4.8.1

### LF / CRLF

Starting with 2.0, *netfx4sdk.cmd* now fully supports LF and uses this by default instead of CRLF.

It means *.gitattributes* control for CRLF in *netfx4sdk.cmd* is not necessary anymore in cases when *core.autocrlf=input* etc.
See related: https://github.com/3F/hMSBuild/issues/2

Note: only *hMSBuild.bat* 2.5+ have the same protection. Full editions ([*hMSBuild.full.bat*](https://github.com/3F/hMSBuild/pull/11)) even for 2.5+ are not protected due to incorrect shiftings in cmd processor when switching to LF.

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

### -help

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
 -sdk-root   - Custom path to the SDK root directory.
 -no-acl     - Do not copy ownership and ACL information when direct copying.

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
netfx4sdk -mode pkg -tfm 3.5 -sdk-root "path\to" -no-mklink -no-acl
```

## Integration with scripts

### batch (.bat, .cmd)

*netfx4sdk.cmd* is a pure batch script. Therefore, you can easily combine this even inside other batch scripts. Or invoke this externally, there's nothing special:

```bat
set sdk=netfx4sdk -mode package -force -global -no-mklink

call %sdk% -tfm 4.5.2 || (
    echo Failed>&2
    call %sdk% -tfm 4.5.1 || goto fallback
)
```

More actual examples can be found in [tests/](tests/) folder.

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