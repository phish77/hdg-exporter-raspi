FROM golang:1.19 AS builder
WORKDIR /hdg-exporter-raspi
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o hdg-exporter-raspi

FROM scratch
LABEL maintainer="dein.name@example.com"
LABEL version="1.0"
LABEL description="HDG Exporter for Raspberry Pi"

EXPOSE 8080

COPY --from=builder /hdg-exporter-raspi/hdg-exporter-raspi /hdg-exporter-raspi

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["/hdg-exporter-raspi"]
