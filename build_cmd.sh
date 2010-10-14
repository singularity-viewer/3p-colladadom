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

case "$AUTOBUILD_PLATFORM" in
    "windows")
        build_sln "projects/vc8/dom.sln" "Debug 1.4"
        build_sln "projects/vc8/dom.sln" "Release 1.4"
        
		mkdir -p stage/libraries/i686-win32/lib/{debug,release}
		cp "external-libs/boost/lib/vc8/libboost_filesystem-d.lib" \
				"stage/libraries/i686-win32/lib/debug/libboost_filesystem.lib"
		cp "external-libs/boost/lib/vc8/libboost_system-d.lib" \
				"stage/libraries/i686-win32/lib/debug/libboost_system.lib"
		cp "build/vc8-1.4-d/libcollada14dom21-d.lib" \
				"stage/libraries/i686-win32/lib/debug/libcollada14dom21.lib"
		cp "build/vc8-1.4-d/libcollada14dom21-d.dll" \
				"stage/libraries/i686-win32/lib/debug/libcollada14dom21.dll"
				
		

		cp "external-libs/boost/lib/vc8/libboost_filesystem.lib" \
				"stage/libraries/i686-win32/lib/release/libboost_filesystem.lib"
		cp "external-libs/boost/lib/vc8/libboost_system.lib" \
				"stage/libraries/i686-win32/lib/release/libboost_system.lib"
		cp "build/vc8-1.4/libcollada14dom21.lib" \
				"stage/libraries/i686-win32/lib/release/libcollada14dom21.lib"
		cp "build/vc8-1.4/libcollada14dom21.dll" \
				"stage/libraries/i686-win32/lib/release/libcollada14dom21.dll"			
        
    ;;
#        "darwin")
#			libdir="$top/stage/libraries/universal-darwin/"
#            mkdir -p "$libdir"/lib_{debug,release}
#			make -C lib
#			make -C tests
#			tests/release/llconvexdecompositionstubtest
#			cp "lib/debug/libllconvexdecompositionstub.a" \
#				"$libdir/lib_debug/libllconvexdecomposition.a"
#			cp "lib/release/libllconvexdecompositionstub.a" \
#				"$libdir/lib_release/libllconvexdecomposition.a"
#		;;
#        "linux")
#			libdir="$top/stage/libraries/i686-linux/"
#            mkdir -p "$libdir"/lib_{debug,release}_client
#			make -C lib
#			make -C tests
#			tests/release/llconvexdecompositionstubtest
#			cp "lib/debug/libllconvexdecomposition.a" \
#				"$libdir/lib_debug_client/libllconvexdecomposition.a"
#			cp "lib/release/libllconvexdecomposition.a" \
#				"$libdir/lib_release_client/libllconvexdecomposition.a"
#			cp "lib/debug_stub/libllconvexdecompositionstub.a" \
#				"$libdir/lib_debug_client/libllconvexdecompositionstub.a"
#			cp "lib/release_stub/libllconvexdecompositionstub.a" \
#				"$libdir/lib_release_client/libllconvexdecompositionstub.a"
#        ;;
esac
mkdir -p "stage/libraries/include/"
cp -R "include" "stage/libraries/include/collada"
mkdir -p stage/LICENSES
cp "license/scea-shared-source-lic1.0.txt" "stage/LICENSES/collada.txt"
mkdir -p stage/LICENSES/collada-other
cp "license/boost-license.txt" "stage/LICENSES/collada-other/boost-license.txt"
cp "license/pcre-license.txt" "stage/LICENSES/collada-other/pcre-license.txt"

pass

