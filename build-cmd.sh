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

        prefix="$top/stage/libraries/i686-win32"
        
        mkdir -p "$prefix/include/collada"
        cp -R include/* "$prefix/include/collada"

        libdir="$prefix/lib"
        mkdir -p "$libdir"/{debug,release}
                
        mkdir -p $prefix/lib/{debug,release}
        cp "build/vc10-1.4-d/libcollada14dom22-d.lib" \
                        "$prefix/lib/debug/libcollada14dom22-d.lib"
        cp "build/vc10-1.4-d/libcollada14dom22-d.dll" \
                        "$prefix/lib/debug/libcollada14dom22-d.dll"
                        
        cp "build/vc10-1.4/libcollada14dom22.lib" \
                        "$prefix/lib/release/libcollada14dom22.lib"
        cp "build/vc10-1.4/libcollada14dom22.dll" \
                        "$prefix/lib/release/libcollada14dom22.dll"			
        
    ;;
    "windows64")
        build_sln "projects/vc11-1.4/dom.sln" "Debug|x64"
        build_sln "projects/vc11-1.4/dom.sln" "Release|x64"
        
		mkdir -p stage/lib/{debug,release}
		cp "build/vc11-1.4-d/libcollada14dom22-d.lib" \
				"stage/lib/debug/libcollada14dom22-d.lib"
		cp "build/vc11-1.4-d/libcollada14dom22-d.dll" \
				"stage/lib/debug/libcollada14dom22-d.dll"
				
		cp "build/vc11-1.4/libcollada14dom22.lib" \
				"stage/lib/release/libcollada14dom22.lib"
		cp "build/vc11-1.4/libcollada14dom22.dll" \
				"stage/lib/release/libcollada14dom22.dll"			
        
    ;;
        "darwin")

	prefix="$top/stage/libraries/universal-darwin"
	libdir="$prefix/lib"
        mkdir -p "$libdir"/{debug,release}
	make -j6 packageprefix=stage/packages/libraries/universal-darwin

	mkdir -p "$prefix/include/collada"
	cp -R include/* "$prefix/include/collada"


	install_name_tool -id "@executable_path/../Resources/libcollada14dom-d.dylib" "build/mac-1.4-d/libcollada14dom-d.dylib" 
	install_name_tool -id "@executable_path/../Resources/libcollada14dom.dylib" "build/mac-1.4/libcollada14dom.dylib" 

	cp "build/mac-1.4-d/libcollada14dom-d.dylib" \
	    "$libdir/debug/libcollada14dom-d.dylib"
	cp "build/mac-1.4-d/libminizip-d.a" \
	    "$libdir/debug/libminizip-d.a"

	cp "build/mac-1.4/libcollada14dom.dylib" \
	    "$libdir/release/libcollada14dom.dylib"
	cp "build/mac-1.4/libminizip.a" \
	    "$libdir/release/libminizip.a"
		;;
        "linux")
	    export MAKEFLAGS="-j8"
	    export LDFLAGS=-m32
	    prefix="$top/stage/libraries/i686-linux"
	    libdir="$prefix/lib"
            mkdir -p "$libdir"/{debug,release}
	    make arch=x86 packageprefix="stage/packages/libraries/i686-linux"

	    mkdir -p "$prefix/include/collada"
	    cp -R include/* "$prefix/include/collada"
	    for lib in libcollada14dom.so libcollada14dom.so.2 libcollada14dom.so.2.2 libminizip.so libminizip.so.1 libminizip.so.1.2.3; do
		cp -d "build/linux-1.4/$lib" "$libdir/release"
		cp -d "build/linux-1.4-d/${lib/\.so/-d.so}" "$libdir/debug"
	    done
        ;;
        "linux64")
	    export MAKEFLAGS="-j8"
	    export LDFLAGS=-m64
	    prefix="$top/stage/libraries/x86_64-linux"
	    libdir="$prefix/lib"
            mkdir -p "$libdir"/{debug,release}
	    make arch=x64 packageprefix="stage/packages/libraries/x86_64-linux"

	    mkdir -p "$prefix/include/collada"
	    cp -R include/* "$prefix/include/collada"
	    for lib in libcollada14dom.so libcollada14dom.so.2 libcollada14dom.so.2.2 libminizip.so libminizip.so.1 libminizip.so.1.2.3; do
		cp -d "build/linux-1.4/$lib" "$libdir/release"
		cp -d "build/linux-1.4-d/${lib/\.so/-d.so}" "$libdir/debug"
	    done
        ;;

esac
mkdir -p stage/LICENSES
cp "license.txt" "stage/LICENSES/collada.txt"
mkdir -p stage/LICENSES/collada-other
cp "license/minizip-license.txt" "stage/LICENSES/collada-other/minizip.txt"

pass

