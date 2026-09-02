# Build stage
FROM golang:1.26-alpine AS builder

WORKDIR /build
COPY go.mod ./
RUN go mod download
RUN go mod tidy

COPY src/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -o fintech-api main.go

# Runtime stage
FROM alpine:3.18

RUN apk add --no-cache ca-certificates

WORKDIR /app
COPY --from=builder /build/fintech-api .

EXPOSE 8080

ENV PORT=8080 \
    DB_PORT=5432 \
    REDIS_PORT=6378

CMD ["./fintech-api"]
