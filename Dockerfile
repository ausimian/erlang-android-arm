FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
	coreutils\
	build-essential\
	autoconf\
	automake\
	libtool\
	curl\
	tar\
	unzip\
	ncurses-dev\
	sed 

WORKDIR /build
RUN curl -L -s -o android-ndk.zip https://dl.google.com/android/repository/android-ndk-r21b-linux-x86_64.zip &&\
    unzip -qq android-ndk.zip &&\
    rm android-ndk.zip

RUN curl -L -s -o openssl.tar.gz https://github.com/openssl/openssl/archive/OpenSSL_1_1_1g.tar.gz &&\
    tar xzf openssl.tar.gz &&\
    rm openssl.tar.gz

RUN curl -L -s -o otp.tar.gz https://github.com/erlang/otp/releases/download/OTP-23.0/OTP-23.0.0-bundle.tar.gz &&\
    tar xzf otp.tar.gz &&\
    rm otp.tar.gz

ENV NDK_ABI_PLAT=androideabi16 NDK_PLAT=android-16 NDK_ROOT=/build/android-ndk-r21b
ENV ANDROID_NDK_HOME=/build/android-ndk-r21b
ENV PATH="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:${PATH}"

RUN cd openssl-OpenSSL_1_1_1g &&\
    ./Configure --prefix=/build/openssl/build android-arm -D__ANDROID_API__=16 &&\
    make -j &&\
    make install_sw

COPY erl-xcomp-arm-android-with-ssl.conf /build/otp/xcomp

WORKDIR /build/otp

RUN ./otp_build autoconf
RUN ./otp_build configure --xcomp-conf=xcomp/erl-xcomp-arm-android-with-ssl.conf
RUN MAKEFLAGS=-j ./otp_build boot -a

ENTRYPOINT ./otp_build release -a /otp/erlang && cd /otp/erlang && ./Install -cross -minimal /data/local/tmp/erlang
