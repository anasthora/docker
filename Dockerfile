FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    SOFT=/soft \
    PYTHONUNBUFFERED=1

# Установка общих зависимостей, Python 3 и pip 
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    autoconf \
    automake \
    pkg-config \
    wget \
    ca-certificates \
    bzip2 \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libncurses5-dev \
    perl \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    python-is-python3 \
    && mkdir -p "${SOFT}" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Установка общих Python-библиотек для работы скриптов 
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel cython \
    && pip3 install --no-cache-dir numpy pandas scipy

# libdeflate — версия 1.26 (дата релиза: 2026-08-22)
RUN mkdir -p /tmp/build && cd /tmp/build \
    && wget -q https://github.com/ebiggers/libdeflate/releases/download/v1.26/libdeflate-1.26.tar.gz \
    && tar -xzf libdeflate-1.26.tar.gz \
    && cd libdeflate-1.26 \
    && cmake -B build -DCMAKE_INSTALL_PREFIX="${SOFT}/libdeflate-1.26" \
    && cmake --build build -j"$(nproc)" \
    && cmake --install build \
    && rm -rf /tmp/build

ENV PATH="${SOFT}/libdeflate-1.26/bin:${PATH}" \
    LD_LIBRARY_PATH="${SOFT}/libdeflate-1.26/lib:${SOFT}/libdeflate-1.26/lib64:${LD_LIBRARY_PATH}" \
    CPATH="${SOFT}/libdeflate-1.26/include:${CPATH}" \
    LIBRARY_PATH="${SOFT}/libdeflate-1.26/lib:${SOFT}/libdeflate-1.26/lib64:${LIBRARY_PATH}" \
    LIBDEFLATE="${SOFT}/libdeflate-1.26/bin/libdeflate-gzip"

# HTSlib — версия 1.25 (дата релиза: 2026-10-27)
RUN mkdir -p /tmp/build && cd /tmp/build \
    && wget -q https://github.com/samtools/htslib/releases/download/1.25/htslib-1.25.tar.bz2 \
    && tar -xjf htslib-1.25.tar.bz2 \
    && cd htslib-1.25 \
    && ./configure --prefix="${SOFT}/htslib-1.25" \
        --with-libdeflate \
        --enable-libcurl \
        --enable-s3 \
        --enable-gcs \
        CPPFLAGS="-I${SOFT}/libdeflate-1.26/include" \
        LDFLAGS="-L${SOFT}/libdeflate-1.26/lib -L${SOFT}/libdeflate-1.26/lib64 -Wl,-rpath,${SOFT}/libdeflate-1.26/lib -Wl,-rpath,${SOFT}/libdeflate-1.26/lib64" \
    && make -j"$(nproc)" \
    && make install \
    && rm -rf /tmp/build

ENV PATH="${SOFT}/htslib-1.25/bin:${PATH}" \
    LD_LIBRARY_PATH="${SOFT}/htslib-1.25/lib:${LD_LIBRARY_PATH}" \
    PKG_CONFIG_PATH="${SOFT}/htslib-1.25/lib/pkgconfig:${PKG_CONFIG_PATH}" \
    BGZIP="${SOFT}/htslib-1.25/bin/bgzip" \
    TABIX="${SOFT}/htslib-1.25/bin/tabix" \
    HTSFILE="${SOFT}/htslib-1.25/bin/htsfile"

# SAMtools — версия 1.25 (дата релиза: 2026-10-27)
RUN mkdir -p /tmp/build && cd /tmp/build \
    && wget -q https://github.com/samtools/samtools/releases/download/1.25/samtools-1.25.tar.bz2 \
    && tar -xjf samtools-1.25.tar.bz2 \
    && cd samtools-1.25 \
    && ./configure --prefix="${SOFT}/samtools-1.25" \
        --with-htslib="${SOFT}/htslib-1.25" \
        LDFLAGS="-Wl,-rpath,${SOFT}/htslib-1.25/lib -Wl,-rpath,${SOFT}/libdeflate-1.26/lib -Wl,-rpath,${SOFT}/libdeflate-1.26/lib64" \
    && make -j"$(nproc)" \
    && make install \
    && rm -rf /tmp/build

ENV PATH="${SOFT}/samtools-1.25/bin:${PATH}" \
    SAMTOOLS="${SOFT}/samtools-1.25/bin/samtools"

# BCFtools — версия 1.25 (дата релиза: 2026-10-27)
RUN mkdir -p /tmp/build && cd /tmp/build \
    && wget -q https://github.com/samtools/bcftools/releases/download/1.25/bcftools-1.25.tar.bz2 \
    && tar -xjf bcftools-1.25.tar.bz2 \
    && cd bcftools-1.25 \
    && ./configure --prefix="${SOFT}/bcftools-1.25" \
        --with-htslib="${SOFT}/htslib-1.25" \
        LDFLAGS="-Wl,-rpath,${SOFT}/htslib-1.25/lib -Wl,-rpath,${SOFT}/libdeflate-1.26/lib -Wl,-rpath,${SOFT}/libdeflate-1.26/lib64" \
    && make -j"$(nproc)" \
    && make install \
    && rm -rf /tmp/build

ENV PATH="${SOFT}/bcftools-1.25/bin:${PATH}" \
    BCFTOOLS="${SOFT}/bcftools-1.25/bin/bcftools"

# VCFtools — версия 0.1.17 (дата релиза: 2025-05-14)
RUN mkdir -p /tmp/build && cd /tmp/build \
    && wget -q https://github.com/vcftools/vcftools/releases/download/v0.1.17/vcftools-0.1.17.tar.gz \
    && tar -xzf vcftools-0.1.17.tar.gz \
    && cd vcftools-0.1.17 \
    && ./configure --prefix="${SOFT}/vcftools-0.1.17" \
    && make -j"$(nproc)" \
    && make install \
    && rm -rf /tmp/build

ENV PATH="${SOFT}/vcftools-0.1.17/bin:${PATH}" \
    PERL5LIB="${SOFT}/vcftools-0.1.17/share/perl5:${PERL5LIB}" \
    VCFTOOLS="${SOFT}/vcftools-0.1.17/bin/vcftools"

# pysam — версия 0.24.1 (дата релиза: 2026-09-07)
RUN mkdir -p /tmp/build "${SOFT}/pysam-0.24.1" && cd /tmp/build \
    && wget -q https://github.com/pysam-developers/pysam/archive/refs/tags/v0.24.1.tar.gz \
    && tar -xzf v0.24.1.tar.gz \
    && cd pysam-0.24.1 \
    && HTSLIB_MODE=shared \
       HTSLIB_LIBRARY_DIR="${SOFT}/htslib-1.25/lib" \
       HTSLIB_INCLUDE_DIR="${SOFT}/htslib-1.25/include" \
       pip3 install --no-cache-dir --no-build-isolation --target="${SOFT}/pysam-0.24.1" . \
    && rm -rf /tmp/build

ENV PYTHONPATH="${SOFT}/pysam-0.24.1:${PYTHONPATH}" \
    PYSAM="${SOFT}/pysam-0.24.1"

WORKDIR /data
CMD ["/bin/bash"]