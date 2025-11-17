ARG VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT=""
ARG TARGETPLATFORM

# Build stage
FROM rust:alpine AS builder

RUN apk add --no-cache git build-base

WORKDIR /build

# Clone kosync from upstream
RUN git clone https://github.com/lzyor/kosync.git .

# Build release binary with musl target for static linking
RUN rustup target add x86_64-unknown-linux-musl && \
    cargo update && cargo build --release --target x86_64-unknown-linux-musl

# Final stage
FROM alpine:latest

RUN apk add --no-cache curl

WORKDIR /srv

# Copy the compiled binary from builder
COPY --from=builder /build/target/x86_64-unknown-linux-musl/release/kosync /srv/kosync

# Set default environment variable (can be overridden at runtime)
ENV KOSYNC_ADDR=0.0.0.0:3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -s http://localhost:3000/healthcheck > /dev/null || exit 1

CMD ["/srv/kosync"]
