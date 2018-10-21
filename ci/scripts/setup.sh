#!/bin/bash

export BUILD_NUMBER=$(git rev-list --count HEAD)-$(git rev-parse --short HEAD)
export BUILD_TIME=$(date +"%a, %d %b %Y %X %z")
export VERSION_SUFFIX=continuous
export VERSION=$VERSION_SUFFIX-$BUILD_NUMBER

if [[ "${BUILD_TYPE}" == "AppImage" ]]; then
    sudo apt-get -y install qt56base qt56x11extras qt56tools qt56svg
    source /opt/qt*/bin/qt*-env.sh
    git clone git://anongit.kde.org/extra-cmake-modules
    cd extra-cmake-modules
    mkdir build && cd build
    cmake ..
    make && sudo make install
    cd ../..
    git clone git://github.com/DamirPorobic/kColorPicker
    cd kColorPicker
    mkdir build && cd build
    cmake ..
    make && sudo make install
    sudo ldconfig
    cd ../..
    git clone git://github.com/DamirPorobic/kImageAnnotator
    cd kImageAnnotator
    mkdir build && cd build
    cmake ..
    make && sudo make install
    sudo ldconfig
    cd ../..
elif [[ "${BUILD_TYPE}" == "deb" ]]; then
    git clone git://github.com/DamirPorobic/kColorPicker
    git clone git://github.com/DamirPorobic/kImageAnnotator
    mkdir debBuild
    cp -R CMakeLists.txt desktop/ icons/ LICENSE README.md src/ translations/ debBuild/
    tar -cvzf ksnip_1.5.0.orig.tar.gz debBuild/
    cp -R ci/debian debBuild/

    cp CHANGELOG.md changelog
    sed -i '1,2d' changelog  #Remove header and empty line ad the beginning
    sed -i 's/\[\(.*[^]]*\)\].*/\1)/g' changelog # Replace links to issues with only number
    sed -i "s/^[[:blank:]]*$/\n -- Damir Porobic <damir.porobic@gmx.com>  ${BUILD_TIME}\n/" changelog # After every release add time and author
    sed -i 's/## Release \([0-9]\.[0-9]\.[0-9]\)/ksnip (\1)  stretch; urgency=medium\n/' changelog # Rename rlease headers
    sed -i 's/^\(\* .*\)/  \1/' changelog # Add two spaces before every entry
    echo "\n -- Damir Porobic <damir.porobic@gmx.com>  ${BUILD_TIME}" >> changelog # Add time and author for the first release
    cp changelog debBuild/debian/
fi
