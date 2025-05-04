# --- Build stage ---
FROM golang:1.19 AS builder

WORKDIR /src
COPY . .

# Build statisch gelinktes Binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o hdg-exporter-raspi

# --- Final stage ---
FROM scratch

LABEL maintainer="Benjamin Goetzinger <benjamin.goetzinger@gmx.de>"
LABEL org.opencontainers.image.source="https://github.com/phish77/hdg-exporter-raspi"
LABEL org.opencontainers.image.description="Prometheus Exporter for HDG Bavaria heating systems (Raspberry Pi)"
LABEL org.opencontainers.image.version="1.0"

EXPOSE 8080

# Copy binary from builder stage 
COPY --from=builder /src/hdg-exporter-raspi /hdg-exporter-raspi

# Optional: add timezone data or certs if needed (see Hinweis unten)

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost:8080/health || exit 1

ENTRYPOINT ["/hdg-exporter-raspi"]
