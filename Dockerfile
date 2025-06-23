# --- Stage 1: The Builder ---
# Use a modern, standard Go image to compile the application.
FROM golang:1.22-alpine AS builder

WORKDIR /src
COPY . .

# Build a static, CGO-disabled binary.
RUN CGO_ENABLED=0 go build -o /boringproxy .

# --- Stage 2: The Final Image ---
# Use Alpine as the base. It's minimal but includes essential OS tools.
FROM alpine:latest

# Install the CA certificates bundle to fix the "x509" error.
RUN apk --no-cache add ca-certificates

# Copy the compiled binary from the builder stage.
COPY --from=builder /boringproxy /usr/local/bin/boringproxy

# --- THE FIX ---
# Add execute permissions to the binary. This solves the "permission denied" error.
RUN chmod +x /usr/local/bin/boringproxy

# Create a non-root user to fix the "Unable to get current user" error.
RUN adduser -D boring
USER boring

# Use the absolute path for the entrypoint. This solves the "not found in $PATH" error.
ENTRYPOINT ["/usr/local/bin/boringproxy"]
