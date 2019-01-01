FROM debian:latest

WORKDIR /build

ENV PS2DEV /usr/local/ps2dev
ENV PS2SDK ${PS2DEV}/ps2sdk
ENV PATH $PATH:${PS2DEV}/bin:${PS2DEV}/ee/bin:${PS2DEV}/iop/bin:${PS2DEV}/dvp/bin:${PS2SDK}/bin

RUN \
  apt update && \
  apt upgrade -y && \
  apt install -y gcc build-essential git musl-dev patch wget curl

RUN \
  git clone https://github.com/ps2dev/ps2toolchain && \
  cd ps2toolchain && \
    ./toolchain.sh && \
    cd .. && \
  rm -Rf ps2toolchain

RUN \
  curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y && \
        . $HOME/.cargo/env && \
        rustup component add rust-src && \
        cargo install cargo-xbuild

RUN \
  curl https://ftp.gnu.org/gnu/binutils/binutils-2.31.tar.gz | tar zx && \
        cd binutils-2.31 && \
        CC_FOR_TARGET=$PS2DEV/ee/bin/ee-gcc ./configure --target=mips64el-none-elf && \
        make && make install && \
        rm -rf binutils-2.31

CMD . $HOME/.cargo/env && cargo xbuild --target ps2.json
