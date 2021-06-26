param (
    [Parameter(Mandatory)] $architecture,
    [Parameter(Mandatory)] $vs
)

$ErrorActionPreference = "Stop"

if ($architecture -eq "x86") {
    $platform = "Win32"
} else {
    $platform = "x64"
}

if ($vs -eq "vs16") {
    $generator = "Visual Studio 16 2019"
} else {
}

Set-Location "ext"
git clone -b "v2.0.2" --depth 1 "https://aomedia.googlesource.com/aom"
Set-Location "aom"
New-Item "build.libavif" -ItemType "directory"
Set-Location "build.libavif"
$on = if ($architecture -eq "x64") {"1"} else {"0"}
cmake "-G" "$generator" "-A" "$platform" "-DENABLE_DOCS=0" "-DENABLE_EXAMPLES=0" "-DENABLE_TESTDATA=0" "-DENABLE_TESTS=0" "-DENABLE_TOOLS=0" "-DENABLE_NASM=1" "-DENABLE_SSE2=$on" "-DENABLE_SSE3=$on" "-DENABLE_SSSE3=$on" "-DENABLE_SSE4_1=$on" "-DENABLE_SSE4_2=$on" "-DENABLE_AVX=$on" "-DENABLE_AVX2=$on" ".."
msbuild "/t:Build" "/p:Configuration=Release" "/p:Platform=$platform" "AOM.sln"
xcopy "Release\*.lib" "."
xcopy "Release\aom.lib" ".\aom_a.lib*"
xcopy ".\aom_a.lib" "..\..\..\winlibs\lib\"
Set-Location "..\..\.."

cmake "$generator" -A "$platform" -DAVIF_CODEC_AOM=1 -DAVIF_LOCAL_AOM=1 -DAVIF_ENABLE_WERROR=0 -DBUILD_SHARED_LIBS=0 .
msbuild "/t:Build" "/p:Configuration=RelWithDebInfo" "/p:Platform=$platform" "libavif.sln"
xcopy "include\avif\avif.h" "winlibs\include\avif\*"
xcopy "RelWithDebInfo\avif*.??b" "winlibs\lib\*"
