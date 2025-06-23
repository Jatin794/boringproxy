# --- Stage 1: The Builder ---
# Use a modern, standard Go image to compile the application.
FROM golang:1.22-alpine AS builder

WORKDIR /src
COPY . .

# Build a static, CGO-disabled binary. This is correct.
RUN CGO_ENABLED=0 go build -o /boringproxy .

# --- Stage 2: The Final Image ---
# Use Alpine as the base. It's minimal but includes essential OS tools.
FROM alpine:latest

# FIX #1: Install the CA certificates bundle to fix the "x509" error.
RUN apk --no-cache add ca-certificates

# Copy the compiled binary from the builder stage.
COPY --from=builder /boringproxy /usr/local/bin/

# FIX #2: Create a non-root user and switch to it. This fixes the "Unable to get current user" error.
RUN adduser -D boring
USER boring

# Set the entrypoint to the application.
ENTRYPOINT ["boringproxy"]
