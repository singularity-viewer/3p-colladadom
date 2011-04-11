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

#execute build from top-level checkout
cd "$(dirname "$0")"

# load autbuild provided shell functions and variables
set +x
eval "$("$AUTOBUILD" source_environment)"
set -x
top="$(pwd)"

case "$AUTOBUILD_PLATFORM" in
    "windows")
        build_sln "projects/vc10-1.4/dom.sln" "Debug|Win32"
        build_sln "projects/vc10-1.4/dom.sln" "Release|Win32"
        
		mkdir -p stage/lib/{debug,release}
		cp "build/vc10-1.4-d/libcollada14dom22-d.lib" \
				"stage/lib/debug/libcollada14dom22-d.lib"
		cp "build/vc10-1.4-d/libcollada14dom22-d.dll" \
				"stage/lib/debug/libcollada14dom22-d.dll"
				
		

		cp "build/vc10-1.4/libcollada14dom22.lib" \
				"stage/lib/release/libcollada14dom22.lib"
		cp "build/vc10-1.4/libcollada14dom22.dll" \
				"stage/lib/release/libcollada14dom22.dll"			
        
    ;;
        "darwin")
			libdir="$top/stage"
            mkdir -p "$libdir"/lib/{debug,release}
			make

			cp "build/mac-1.4-d/Collada14Dom-d.dylib" \
				"$libdir/lib/debug/Collada4Dom-d.dylib"

			cp "build/mac-1.4/Collada14Dom.dylib" \
				"$libdir/lib/release/Collada4Dom.dylib"
		;;
        "linux")
			libdir="$top/stage"
            mkdir -p "$libdir"/lib/{debug,release}
			make 

			cp "build/linux-1.4/libcollada14dom.so" \
				"$libdir/lib/release/libcollada14dom.so"
			cp "build/linux-1.4/libcollada14dom.so.2" \
				"$libdir/lib/release/libcollada14dom.so.2"
			cp "build/linux-1.4/libcollada14dom.so.2.1" \
				"$libdir/lib/release/libcollada14dom.so.2.1"


			cp "build/linux-1.4-d/libcollada14dom-d.so" \
				"$libdir/lib/debug/libcollada14dom-d.so"
			cp "build/linux-1.4-d/libcollada14dom-d.so.2" \
				"$libdir/lib/debug/libcollada14dom-d.so.2"
			cp "build/linux-1.4-d/libcollada14dom-d.so.2.1" \
				"$libdir/lib/debug/libcollada14dom-d.so.2.1"
        ;;

esac
mkdir -p "stage/include/collada"
cp -R "include" "stage/include/collada"
mkdir -p stage/LICENSES
cp "license.txt" "stage/LICENSES/collada.txt"
mkdir -p stage/LICENSES/collada-other
cp "license/boost-license.txt" "stage/LICENSES/collada-other"
cp "license/pcre-license.txt" "stage/LICENSES/collada-other"
cp "license/minizip-license.txt" "stage/LICENSES/collada-other"
cp "license/tinyxml-license.txt" "stage/LICENSES/collada-other"

pass

