# Multi-platform tmux build Dockerfile
# Supports: linux/amd64, linux/arm64
# macOS builds should use Homebrew or scripts/tmux.sh with --native flag
#
# Usage:
#   docker buildx build --platform linux/amd64 -f Dockerfile.tmux --output dist .
#   docker buildx build --platform linux/arm64 -f Dockerfile.tmux --output dist .
#
# References:
#   - https://github.com/tmux/tmux/wiki/Installing
#   - https://github.com/pythops/tmux-linux-binary
#   - https://github.com/mjakob-gh/build-static-tmux

ARG BASE_IMAGE=debian:bookworm-slim

# =============================================================================
# Build Stage
# =============================================================================
FROM ${BASE_IMAGE} AS builder

# Build arguments
ARG TMUX_VERSION=3.5a
ARG LIBEVENT_VERSION=2.1.12
ARG NCURSES_VERSION=6.5

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bison \
    build-essential \
    ca-certificates \
    curl \
    libevent-dev \
    libncurses-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Download and extract tmux source
RUN curl -sSL "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" \
    -o tmux.tar.gz \
    && tar xzf tmux.tar.gz \
    && rm tmux.tar.gz

# Build tmux with static linking
WORKDIR /build/tmux-${TMUX_VERSION}

RUN ./configure \
    --enable-static \
    --prefix=/opt/tmux \
    LDFLAGS="-static" \
    && make -j$(nproc) \
    && make install

# Strip the binary for smaller size
RUN strip /opt/tmux/bin/tmux

# =============================================================================
# Export Stage - Minimal image with just the binary
# =============================================================================
FROM scratch AS export

COPY --from=builder /opt/tmux/bin/tmux /tmux

# =============================================================================
# Runtime Stage - For testing the build
# =============================================================================
FROM ${BASE_IMAGE} AS runtime

# Install runtime dependencies (for dynamically linked builds)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libevent-2.1-7 \
    libncurses6 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/tmux/bin/tmux /usr/local/bin/tmux

# Verify the build
RUN tmux -V

ENTRYPOINT ["/usr/local/bin/tmux"]
