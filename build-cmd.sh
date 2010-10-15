#!/bin/sh

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e

if [ -z "$AUTOBUILD" ] ; then 
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

# load autbuild provided shell functions and variables
set +x
eval "$("$AUTOBUILD" source_environment)"
set -x
top="$(pwd)"

case "$AUTOBUILD_PLATFORM" in
    "windows")
        build_sln "projects/vc8/dom.sln" "Debug 1.4"
        build_sln "projects/vc8/dom.sln" "Release 1.4"
        
		mkdir -p stage/libraries/i686-win32/lib/{debug,release}
		cp "external-libs/boost/lib/vc8/libboost_filesystem-d.lib" \
				"stage/libraries/i686-win32/lib/debug/libboost_filesystem-d.lib"
		cp "external-libs/boost/lib/vc8/libboost_system-d.lib" \
				"stage/libraries/i686-win32/lib/debug/libboost_system-d.lib"
		cp "build/vc8-1.4-d/libcollada14dom21-d.lib" \
				"stage/libraries/i686-win32/lib/debug/libcollada14dom21-d.lib"
		cp "build/vc8-1.4-d/libcollada14dom21-d.dll" \
				"stage/libraries/i686-win32/lib/debug/libcollada14dom21-d.dll"
				
		

		cp "external-libs/boost/lib/vc8/libboost_filesystem.lib" \
				"stage/libraries/i686-win32/lib/release/libboost_filesystem.lib"
		cp "external-libs/boost/lib/vc8/libboost_system.lib" \
				"stage/libraries/i686-win32/lib/release/libboost_system.lib"
		cp "build/vc8-1.4/libcollada14dom21.lib" \
				"stage/libraries/i686-win32/lib/release/libcollada14dom21.lib"
		cp "build/vc8-1.4/libcollada14dom21.dll" \
				"stage/libraries/i686-win32/lib/release/libcollada14dom21.dll"			
        
    ;;
        "darwin")
			libdir="$top/stage/libraries/universal-darwin/"
            mkdir -p "$libdir"/lib_{debug,release}
			make

			cp "external-libs/boost/lib/mac/libboost_system.a" \
				"$libdir/lib_debug/libboost_system.a"
			cp "external-libs/boost/lib/mac/libboost_filesystem.a" \
				"$libdir/lib_debug/libboost_filesystem.a"
			cp "build/mac-1.4-d/Collada4Dom-d.dylib" \
				"$libdir/lib_debug/Collada4Dom-d.dylib"
			cp "build/mac-1.4-d/Collada4Dom-d.framework" \
				"$libdir/lib_debug/Collada4Dom-d.framework"

			cp "external-libs/boost/lib/mac/libboost_system.a" \
				"$libdir/lib_release/libboost_system.a"
			cp "external-libs/boost/lib/mac/libboost_filesystem.a" \
				"$libdir/lib_release/libboost_filesystem.a"
			cp "build/mac-1.4/Collada4Dom.dylib" \
				"$libdir/lib_release/Collada4Dom.dylib"
			cp "build/mac-1.4/Collada4Dom.framework" \
				"$libdir/lib_release/Collada4Dom.framework"
		;;
        "linux")
			libdir="$top/stage/libraries/i686-linux/"
            mkdir -p "$libdir"/lib_{debug,release}_client
			make 

			cp "external-libs/boost/lib/mingw/libboost_filesystem.a" \
				"$libdir/lib_release_client/libboost_filesystem.a"
			cp "external-libs/boost/lib/mingw/libboost_system.a" \
				"$libdir/lib_release_client/libboost_system.a"

			cp "build/linux-1.4/libcollada14dom.so" \
				"$libdir/lib_release_client/libcollada14dom.so"
			cp "build/linux-1.4/libcollada14dom.so.2" \
				"$libdir/lib_release_client/libcollada14dom.so.2"
			cp "build/linux-1.4/libcollada14dom.so.2.1" \
				"$libdir/lib_release_client/libcollada14dom.so.2.1"


			cp "external-libs/boost/lib/mingw/libboost_filesystem.a" \
				"$libdir/lib_debug_client/libboost_filesystem.a"
			cp "external-libs/boost/lib/mingw/libboost_system.a" \
				"$libdir/lib_debug_client/libboost_system.a"

			cp "build/linux-1.4-d/libcollada14dom-d.so" \
				"$libdir/lib_debug_client/libcollada14dom-d.so"
			cp "build/linux-1.4-d/libcollada14dom-d.so.2" \
				"$libdir/lib_debug_client/libcollada14dom-d.so.2"
			cp "build/linux-1.4-d/libcollada14dom-d.so.2.1" \
				"$libdir/lib_debug_client/libcollada14dom-d.so.2.1"
        ;;

esac
mkdir -p "stage/libraries/include/"
cp -R "include" "stage/libraries/include/collada"
mkdir -p stage/LICENSES
cp "license/scea-shared-source-lic1.0.txt" "stage/LICENSES/collada.txt"
mkdir -p stage/LICENSES/collada-other
cp "license/boost-license.txt" "stage/LICENSES/collada-other/boost-license.txt"
cp "license/pcre-license.txt" "stage/LICENSES/collada-other/pcre-license.txt"

pass

