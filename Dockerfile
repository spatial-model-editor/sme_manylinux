FROM quay.io/pypa/manylinux_2_28_x86_64:2024-01-29-1785b0b as builder

LABEL org.opencontainers.image.source=https://github.com/spatial-model-editor/sme_manylinux2014_x86_64
LABEL org.opencontainers.image.description="manylinux_2_28_x86_64-based image for compiling Spatial Model Editor python wheels"
LABEL org.opencontainers.image.licenses=MIT

ARG NPROCS=24
ARG BUILD_DIR=/opt/smelibs
ARG TMP_DIR=/opt/tmpwd

RUN /opt/python/cp311-cp311/bin/pip install ninja \
    && ln -fs /opt/python/cp311-cp311/bin/ninja /usr/bin/ninja

RUN yum update \
    && yum install -y flex-2.6.1 \
    && yum clean all

ARG CEREAL_VERSION="v1.3.2"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $CEREAL_VERSION \
        --depth=1 \
        https://github.com/USCiLab/cereal.git \
    && cd cereal \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DJUST_INSTALL_CEREAL=ON \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        .. \
    && ninja install \
    && rm -rf $TMP_DIR

ARG FUNCTION2_VERSION="4.2.4"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $FUNCTION2_VERSION \
        --depth=1 \
        https://github.com/Naios/function2.git \
    && cd function2 \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_TESTING=OFF \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        .. \
    && ninja install \
    && rm -rf $TMP_DIR

ARG GMP_VERSION="6.3.0"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && curl -L \
        https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.bz2 \
        --output gmp.tar.bz2 \
    && tar xjf gmp.tar.bz2 \
    && cd gmp-${GMP_VERSION} \
    && ./configure \
        --prefix=$BUILD_DIR \
        --disable-shared \
        --host=x86_64-unknown-linux-gnu \
        --enable-static \
        --with-pic \
        --enable-cxx \
    && make -j$NPROCS \
    && make check \
    && make install \
    && rm -rf $TMP_DIR

ARG MPFR_VERSION="4.2.1"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && curl \
        https://www.mpfr.org/mpfr-${MPFR_VERSION}/mpfr-${MPFR_VERSION}.tar.bz2 \
        --output mpfr.tar.bz2 \
    && tar xjf mpfr.tar.bz2 \
    && cd mpfr-${MPFR_VERSION} \
    && ./configure \
        --prefix=$BUILD_DIR \
        --disable-shared \
        --host=x86_64-unknown-linux-gnu \
        --enable-static \
        --with-pic \
        --with-gmp-lib=$BUILD_DIR/lib \
        --with-gmp-include=$BUILD_DIR/include \
    && make -j$NPROCS \
    && make check \
    && make install \
    && rm -rf $TMP_DIR

ARG BOOST_VERSION="1.84.0"
ARG BOOST_VERSION_="1_84_0"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && curl -L \
        "https://boostorg.jfrog.io/artifactory/main/release/${BOOST_VERSION}/source/boost_${BOOST_VERSION_}.tar.bz2" \
        --output boost.tar.bz2 \
    && tar xjf boost.tar.bz2 \
    && cd boost_${BOOST_VERSION_} \
    && ./bootstrap.sh --prefix="$BUILD_DIR" --with-libraries=serialization \
    && ./b2 link=static install \
    && rm -rf $TMP_DIR

ARG CGAL_VERSION="v5.6"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $CGAL_VERSION \
        --depth=1 \
        https://github.com/CGAL/cgal.git \
    && cd cgal \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        .. \
    && ninja \
    && ninja install \
    && rm -rf $TMP_DIR

ARG LIBEXPAT_VERSION="R_2_5_0"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $LIBEXPAT_VERSION \
        --depth=1 \
        https://github.com/libexpat/libexpat.git \
    && cd libexpat \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DEXPAT_BUILD_DOCS=OFF \
        -DEXPAT_BUILD_EXAMPLES=OFF \
        -DEXPAT_BUILD_TOOLS=OFF \
        -DEXPAT_SHARED_LIBS=OFF \
        ../expat \
    && ninja \
    && ninja test \
    && ninja install \
    && rm -rf $TMP_DIR

ARG LIBTIFF_VERSION="v4.6.0"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $LIBTIFF_VERSION \
        --depth=1 \
        https://gitlab.com/libtiff/libtiff.git \
    && cd libtiff \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -Djpeg=OFF \
        -Djpeg12=OFF \
        -Djbig=OFF \
        -Dlzma=OFF \
        -Dlibdeflate=OFF \
        -Dpixarlog=OFF \
        -Dold-jpeg=OFF \
        -Dzstd=OFF \
        -Dmdi=OFF \
        -Dwebp=OFF \
        -Dzlib=OFF \
        -DGLUT_INCLUDE_DIR=GLUT_INCLUDE_DIR-NOTFOUND \
        -DOPENGL_INCLUDE_DIR=OPENGL_INCLUDE_DIR-NOTFOUND \
        .. \
    && ninja \
    && ninja test \
    && ninja install \
    && rm -rf $TMP_DIR

ARG LLVM_VERSION="17.0.6"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b llvmorg-$LLVM_VERSION \
        --depth=1 \
        https://github.com/llvm/llvm-project.git \
    && cd llvm-project/llvm \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DPython3_EXECUTABLE:FILEPATH=/opt/python/cp311-cp311/bin/python \
        -DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-unknown-linux-gnu \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_BUILD_TOOLS=OFF \
        -DLLVM_INCLUDE_TOOLS=OFF \
        -DLLVM_BUILD_EXAMPLES=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_BUILD_TESTS=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_BUILD_UTILS=OFF \
        -DLLVM_INCLUDE_UTILS=OFF \
        -DLLVM_INCLUDE_GO_TESTS=OFF \
        -DLLVM_BUILD_BENCHMARKS=OFF \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_ENABLE_LIBPFM=OFF \
        -DLLVM_ENABLE_ZLIB=OFF \
        -DLLVM_ENABLE_ZSTD=OFF \
        -DLLVM_ENABLE_DIA_SDK=OFF \
        -DLLVM_BUILD_INSTRUMENTED_COVERAGE=OFF \
        -DLLVM_ENABLE_BINDINGS=OFF \
        -DLLVM_ENABLE_RTTI=ON \
        -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_LIBXML2=OFF \
        -DLLVM_ENABLE_WARNINGS=OFF \
        .. \
    && ninja \
    && ninja install \
    && rm -rf $TMP_DIR

ARG TBB_VERSION="fix_1145_missing_threads_dependency_static_build"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $TBB_VERSION \
        --depth=1 \
        https://github.com/lkeegan/oneTBB.git \
    && cd oneTBB \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DTBB_ENABLE_IPO=ON \
        -DTBB_STRICT=OFF \
        -DTBB_TEST=OFF \
        .. \
    && ninja \
    && ninja install \
    && rm -rf $TMP_DIR

ARG DPL_VERSION="oneDPL-2022.2.0-rc1"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $DPL_VERSION \
        --depth 1 \
        https://github.com/oneapi-src/oneDPL.git \
    && cd oneDPL \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DCMAKE_PREFIX_PATH=$BUILD_DIR \
        -DONEDPL_BACKEND="tbb" \
        .. \
    && ninja \
    && ninja install \
    && rm -rf $TMP_DIR

ARG PAGMO_VERSION="v2.19.0"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $PAGMO_VERSION \
        --depth 1 \
        https://github.com/esa/pagmo2.git \
    && cd pagmo2 \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DPAGMO_BUILD_STATIC_LIBRARY=ON \
        -DPAGMO_BUILD_TESTS=OFF \
        .. \
    && ninja \
    && ninja install \
    && rm -rf $TMP_DIR

ARG ZLIB_VERSION="v1.2.13"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $ZLIB_VERSION \
        --depth 1 \
        https://github.com/madler/zlib.git \
    && cd zlib \
    && mkdir build \
    && cd build \
    && cmake .. \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
    && ninja zlibstatic \
    && cp libz.a $BUILD_DIR/lib/libz.a \
    && cp zconf.h $BUILD_DIR/include/. \
    && cp ../zlib.h $BUILD_DIR/include/. \
    && rm -rf $TMP_DIR

ARG QT_VERSION="v6.6.1"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $QT_VERSION \
        --depth 1 \
        https://code.qt.io/qt/qt5.git \
    && cd qt5 \
    && git submodule update --depth 1 --init qtbase \
    && cd .. \
    && mkdir build \
    && cd build \
    && cmake ../qt5/qtbase \
        -GNinja \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${BUILD_DIR} \
        -DFEATURE_system_doubleconversion=OFF \
        -DFEATURE_system_harfbuzz=OFF \
        -DFEATURE_system_jpeg=OFF \
        -DFEATURE_system_libb2=OFF \
        -DFEATURE_system_pcre2=OFF \
        -DFEATURE_system_png=OFF \
        -DFEATURE_system_proxies=OFF \
        -DFEATURE_system_textmarkdownreader=OFF \
        -DFEATURE_system_zlib=ON \
        -DZLIB_INCLUDE_DIR=${BUILD_DIR}/include \
        -DZLIB_LIBRARY_RELEASE=${BUILD_DIR}/lib/libz.a \
        -DFEATURE_zstd=OFF \
        -DFEATURE_openssl=OFF \
        -DFEATURE_sql=OFF \
        -DFEATURE_icu=OFF \
        -DFEATURE_testlib=ON \
        -DBUILD_WITH_PCH=OFF \
        -DFEATURE_xcb=OFF \
    && ninja \
    && ninja install \
    && rm -rf $TMP_DIR

ARG BZIP2_VERSION="1.0.8"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && curl -L \
        https://sourceware.org/pub/bzip2/bzip2-${BZIP2_VERSION}.tar.gz \
        --output bzip2.tar.gz \
    && tar xf bzip2.tar.gz \
    && cd bzip2-${BZIP2_VERSION} \
    && make CFLAGS="-O2 -g -D_FILE_OFFSET_BITS=64 -fPIC" -j$NPROCS \
    && make install PREFIX="$BUILD_DIR" \
    && rm -rf $TMP_DIR

ARG OPENCV_VERSION="4.9.0"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $OPENCV_VERSION \
        --depth=1 \
        https://github.com/opencv/opencv.git \
    && cd opencv \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DBUILD_opencv_apps=OFF \
        -DBUILD_opencv_calib3d=OFF \
        -DBUILD_opencv_core=ON \
        -DBUILD_opencv_dnn=OFF \
        -DBUILD_opencv_features2d=OFF \
        -DBUILD_opencv_flann=OFF \
        -DBUILD_opencv_gapi=OFF \
        -DBUILD_opencv_highgui=OFF \
        -DBUILD_opencv_imgcodecs=OFF \
        -DBUILD_opencv_imgproc=ON \
        -DBUILD_opencv_java_bindings_generator=OFF \
        -DBUILD_opencv_js=OFF \
        -DBUILD_opencv_ml=OFF \
        -DBUILD_opencv_objdetect=OFF \
        -DBUILD_opencv_photo=OFF \
        -DBUILD_opencv_python_bindings_generator=OFF \
        -DBUILD_opencv_python_tests=OFF \
        -DBUILD_opencv_stitching=OFF \
        -DBUILD_opencv_ts=OFF \
        -DBUILD_opencv_video=OFF \
        -DBUILD_opencv_videoio=OFF \
        -DBUILD_opencv_world=OFF \
        -DBUILD_CUDA_STUBS:BOOL=OFF \
        -DBUILD_DOCS:BOOL=OFF \
        -DBUILD_EXAMPLES:BOOL=OFF \
        -DBUILD_FAT_JAVA_LIB:BOOL=OFF \
        -DBUILD_IPP_IW:BOOL=OFF \
        -DBUILD_ITT:BOOL=OFF \
        -DBUILD_JASPER:BOOL=OFF \
        -DBUILD_JAVA:BOOL=OFF \
        -DBUILD_JPEG:BOOL=OFF \
        -DBUILD_OPENEXR:BOOL=OFF \
        -DBUILD_PACKAGE:BOOL=OFF \
        -DBUILD_PERF_TESTS:BOOL=OFF \
        -DBUILD_PNG:BOOL=OFF \
        -DBUILD_PROTOBUF:BOOL=OFF \
        -DBUILD_SHARED_LIBS:BOOL=OFF \
        -DBUILD_TBB:BOOL=OFF \
        -DBUILD_TESTS:BOOL=OFF \
        -DBUILD_TIFF:BOOL=OFF \
        -DBUILD_USE_SYMLINKS:BOOL=OFF \
        -DBUILD_WEBP:BOOL=OFF \
        -DBUILD_WITH_DEBUG_INFO:BOOL=OFF \
        -DBUILD_WITH_DYNAMIC_IPP:BOOL=OFF \
        -DBUILD_ZLIB:BOOL=OFF \
        -DWITH_1394:BOOL=OFF \
        -DWITH_ADE:BOOL=OFF \
        -DWITH_ARAVIS:BOOL=OFF \
        -DWITH_CLP:BOOL=OFF \
        -DWITH_CUDA:BOOL=OFF \
        -DWITH_EIGEN:BOOL=OFF \
        -DWITH_FFMPEG:BOOL=OFF \
        -DWITH_FREETYPE:BOOL=OFF \
        -DWITH_GDAL:BOOL=OFF \
        -DWITH_GDCM:BOOL=OFF \
        -DWITH_GPHOTO2:BOOL=OFF \
        -DWITH_GSTREAMER:BOOL=OFF \
        -DWITH_GTK:BOOL=OFF \
        -DWITH_GTK_2_X:BOOL=OFF \
        -DWITH_HALIDE:BOOL=OFF \
        -DWITH_HPX:BOOL=OFF \
        -DWITH_IMGCODEC_HDR:BOOL=OFF \
        -DWITH_IMGCODEC_PFM:BOOL=OFF \
        -DWITH_IMGCODEC_PXM:BOOL=OFF \
        -DWITH_IMGCODEC_SUNRASTER:BOOL=OFF \
        -DWITH_INF_ENGINE:BOOL=OFF \
        -DWITH_IPP:BOOL=OFF \
        -DWITH_ITT:BOOL=OFF \
        -DWITH_JASPER:BOOL=OFF \
        -DWITH_JPEG:BOOL=OFF \
        -DWITH_LAPACK:BOOL=OFF \
        -DWITH_LIBREALSENSE:BOOL=OFF \
        -DWITH_MFX:BOOL=OFF \
        -DWITH_NGRAPH:BOOL=OFF \
        -DWITH_OPENCL:BOOL=OFF \
        -DWITH_OPENCLAMDBLAS:BOOL=OFF \
        -DWITH_OPENCLAMDFFT:BOOL=OFF \
        -DWITH_OPENCL_SVM:BOOL=OFF \
        -DWITH_OPENEXR:BOOL=OFF \
        -DWITH_OPENGL:BOOL=OFF \
        -DWITH_OPENJPEG:BOOL=OFF \
        -DWITH_OPENMP:BOOL=OFF \
        -DWITH_OPENNI:BOOL=OFF \
        -DWITH_OPENNI2:BOOL=OFF \
        -DWITH_OPENVX:BOOL=OFF \
        -DWITH_PLAIDML:BOOL=OFF \
        -DWITH_PNG:BOOL=OFF \
        -DWITH_PROTOBUF:BOOL=OFF \
        -DWITH_PTHREADS_PF:BOOL=OFF \
        -DWITH_PVAPI:BOOL=OFF \
        -DWITH_QT:BOOL=OFF \
        -DWITH_QUIRC:BOOL=OFF \
        -DWITH_TBB:BOOL=OFF \
        -DWITH_TIFF:BOOL=OFF \
        -DWITH_V4L:BOOL=OFF \
        -DWITH_VA:BOOL=OFF \
        -DWITH_VA_INTEL:BOOL=OFF \
        -DWITH_VTK:BOOL=OFF \
        -DWITH_VULKAN:BOOL=OFF \
        -DWITH_WEBP:BOOL=OFF \
        -DWITH_XIMEA:BOOL=OFF \
        -DWITH_XINE:BOOL=OFF \
        -DZLIB_INCLUDE_DIR=$BUILD_DIR/include \
        -DZLIB_LIBRARY_RELEASE=$BUILD_DIR/lib/libz.a \
        .. \
    && ninja \
    && ninja install \
    && rm -rf $TMP_DIR

ARG FMT_VERSION="10.2.1"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $FMT_VERSION \
        --depth=1 \
        https://github.com/fmtlib/fmt.git \
    && cd fmt \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DCMAKE_CXX_STANDARD=17 \
        -DFMT_DOC=OFF \
        .. \
    && ninja \
    && ninja test \
    && ninja install \
    && rm -rf $TMP_DIR

ARG SPDLOG_VERSION="v1.12.0"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $SPDLOG_VERSION \
        --depth=1 \
        https://github.com/gabime/spdlog.git \
    && cd spdlog \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DSPDLOG_BUILD_TESTS=ON \
        -DSPDLOG_BUILD_EXAMPLE=OFF \
        -DSPDLOG_FMT_EXTERNAL=ON \
        -DSPDLOG_NO_THREAD_ID=ON \
        -DSPDLOG_NO_ATOMIC_LEVELS=ON \
        -DCMAKE_PREFIX_PATH=$BUILD_DIR \
        .. \
    && ninja \
    && ninja test \
    && ninja install \
    && rm -rf $TMP_DIR

ARG SYMENGINE_VERSION="master"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $SYMENGINE_VERSION \
        --depth=1 \
        https://github.com/symengine/symengine.git \
    && cd symengine \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DBUILD_BENCHMARKS=OFF \
        -DGMP_INCLUDE_DIR=$BUILD_DIR/include \
        -DGMP_LIBRARY=$BUILD_DIR/lib/libgmp.a \
        -DCMAKE_PREFIX_PATH=$BUILD_DIR \
        -DWITH_LLVM=ON \
        -DWITH_COTIRE=OFF \
        -DWITH_SYSTEM_CEREAL=ON \
        -DWITH_SYMENGINE_THREAD_SAFE=ON \
        .. \
    && ninja \
    && ninja test \
    && ninja install \
    && rm -rf $TMP_DIR

ARG SCOTCH_VERSION="v7.0.4"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $SCOTCH_VERSION \
        --depth=1 \
        https://gitlab.inria.fr/scotch/scotch.git \
    && cd scotch \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DBUILD_PTSCOTCH=OFF \
        -DBUILD_LIBESMUMPS=OFF \
        -DUSE_LZMA=OFF \
        -DUSE_ZLIB=ON \
        -DZLIB_INCLUDE_DIR=${BUILD_DIR}/include \
        -DZLIB_LIBRARY_RELEASE=${BUILD_DIR}/lib/libz.a \
        -DUSE_BZ2=ON \
        -DBZIP2_INCLUDE_DIR=${BUILD_DIR}/include \
        -DBZIP2_LIBRARY_RELEASE=${BUILD_DIR}/lib/libbz2.a \
        .. \
    && ninja \
    && ninja test \
    && ninja install \
    && rm -rf $TMP_DIR

ARG DUNE_COPASI_VERSION="master"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && export DUNE_COPASI_USE_STATIC_DEPS=ON \
    && export CMAKE_INSTALL_PREFIX=$BUILD_DIR \
    && export MAKE_FLAGS="-j$NPROCS VERBOSE=1" \
    && export DUNE_USE_FALLBACK_FILESYSTEM=ON \
    && export CMAKE_CXX_FLAGS="'-fvisibility=hidden -D_GLIBCXX_USE_TBB_PAR_BACKEND=0'" \
    && export CMAKE_FLAGS="-GNinja" \
    && export CMAKE_DISABLE_FIND_PACKAGE_MPI=ON \
    && export DUNE_ENABLE_PYTHONBINDINGS=OFF \
    && export DUNE_PDELAB_ENABLE_TRACING=OFF \
    && export DUNE_COPASI_DISABLE_FETCH_PACKAGE_ExprTk=ON \
    && export DUNE_COPASI_DISABLE_FETCH_PACKAGE_parafields=ON \
    && export DUNE_COPASI_GRID_DIMENSIONS='"2;3"' \
    && git clone \
        -b $DUNE_COPASI_VERSION \
        --depth 1 \
        https://gitlab.dune-project.org/copasi/dune-copasi.git \
    && cd dune-copasi \
    && bash dune-copasi.opts \
    && bash .ci/setup_dune "$PWD"/dune-copasi.opts \
    && bash .ci/install "$PWD"/dune-copasi.opts \
    && bash .ci/test "$PWD"/dune-copasi.opts \
    && rm -rf $TMP_DIR

ARG LIBSBML_VERSION="development"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $LIBSBML_VERSION \
        --depth=1 \
        https://github.com/sbmlteam/libsbml.git \
    && cd libsbml \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DCMAKE_PREFIX_PATH=$BUILD_DIR \
        -DENABLE_SPATIAL=ON \
        -DWITH_CPP_NAMESPACE=ON \
        -DWITH_THREADSAFE_PARSER=ON \
        -DLIBSBML_SKIP_SHARED_LIBRARY=ON \
        -DWITH_BZIP2=ON \
        -DLIBBZ_INCLUDE_DIR=$BUILD_DIR/include \
        -DLIBBZ_LIBRARY=$BUILD_DIR/lib/libbz2.a \
        -DWITH_ZLIB=ON \
        -DLIBZ_INCLUDE_DIR=$BUILD_DIR/include \
        -DLIBZ_LIBRARY=$BUILD_DIR/lib/libz.a \
        -DWITH_SWIG=OFF \
        -DWITH_LIBXML=OFF \
        -DWITH_EXPAT=ON \
        -DEXPAT_INCLUDE_DIR=$BUILD_DIR/include \
        -DEXPAT_LIBRARY=$BUILD_DIR/lib64/libexpat.a \
        .. \
    && ninja \
    && ninja install \
    && rm -rf $TMP_DIR

ARG COMBINE_VERSION="master"
ARG ZIPPER_VERSION="master"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $COMBINE_VERSION \
        --depth=1 \
        https://github.com/sbmlteam/libCombine.git \
    && cd libCombine \
    && git submodule update --init submodules/zipper \
    && cd submodules/zipper \
    && git checkout $ZIPPER_VERSION \
    && cd ../../ \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DCMAKE_PREFIX_PATH="$BUILD_DIR;$BUILD_DIR/lib/cmake" \
        -DLIBCOMBINE_SKIP_SHARED_LIBRARY=ON \
        -DEXTRA_LIBS="$BUILD_DIR/lib/libz.a;$BUILD_DIR/lib/libbz2.a;$BUILD_DIR/lib64/libexpat.a" \
        -DWITH_CPP_NAMESPACE=ON \
        -DZLIB_INCLUDE_DIR=$BUILD_DIR/include \
        -DZLIB_LIBRARY=$BUILD_DIR/lib/libz.a \
        .. \
    && ninja \
    && ninja test \
    && ninja install \
    && rm -rf $TMP_DIR

ARG CATCH2_VERSION="v3.5.1"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $CATCH2_VERSION \
        --depth=1 \
        https://github.com/catchorg/Catch2.git \
    && cd Catch2 \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DCATCH_INSTALL_DOCS=OFF \
        -DCATCH_INSTALL_EXTRAS=ON \
        .. \
    && ninja \
    && ninja install \
    && rm -rf $TMP_DIR

FROM quay.io/pypa/manylinux_2_28_x86_64:2024-01-29-1785b0b

ARG BUILD_DIR=/opt/smelibs
ARG TMP_DIR=/opt/tmpwd

ARG CCACHE_VERSION="4.9.1"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && curl \
        -L https://github.com/ccache/ccache/releases/download/v${CCACHE_VERSION}/ccache-${CCACHE_VERSION}-linux-x86_64.tar.xz \
        --output ccache.tar.xz \
    && tar xJf ccache.tar.xz \
    && cd ccache-${CCACHE_VERSION}-linux-x86_64 \
    && make install \
    && rm -rf $TMP_DIR

# SME static libs
COPY --from=builder $BUILD_DIR $BUILD_DIR
ENV CMAKE_PREFIX_PATH="$BUILD_DIR;$BUILD_DIR/lib64/cmake"
ENV CCACHE_DIR=/host/opt/ccache