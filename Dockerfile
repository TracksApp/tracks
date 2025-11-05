# Build stage
FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git gcc musl-dev sqlite-dev

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o tracks ./cmd/tracks

# Runtime stage
FROM alpine:latest

# Install runtime dependencies
RUN apk --no-cache add ca-certificates sqlite-libs

# Create app user
RUN addgroup -g 1000 tracks && \
    adduser -D -u 1000 -G tracks tracks

# Set working directory
WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/tracks .

# Create data directory
RUN mkdir -p /app/data /app/uploads && \
    chown -R tracks:tracks /app

# Switch to non-root user
USER tracks

# Expose port
EXPOSE 3000

# Run the application
CMD ["./tracks"]
