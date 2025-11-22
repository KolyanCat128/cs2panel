FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git gcc musl-dev

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build
RUN CGO_ENABLED=1 GOOS=linux go build -o hypervisor-daemon .

FROM alpine:latest

RUN apk --no-cache add ca-certificates libvirt-client qemu-system-x86_64

WORKDIR /root/

COPY --from=builder /app/hypervisor-daemon .

# Create data directory
RUN mkdir -p /data

EXPOSE 8080 9090

CMD ["./hypervisor-daemon"]
