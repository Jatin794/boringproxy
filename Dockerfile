# Use a single, modern Go build environment. No multiple stages.
FROM golang:1.22-alpine

# Set the working directory for all subsequent commands.
WORKDIR /app

# Install necessary OS packages.
# ca-certificates: Fixes the "x509" error.
# git: Needed to ensure all build dependencies can be fetched.
RUN apk --no-cache add ca-certificates git

# Copy all source code into the working directory.
COPY . .

# Build the boringproxy binary. The output will be placed in the current
# working directory (/app/boringproxy). This is a simple, direct build.
RUN CGO_ENABLED=0 go build -o boringproxy ./cmd/boringproxy

# --- Security and User Context ---
# Create a non-root user to run the application securely.
RUN adduser -D boring
# Switch to this non-root user. This fixes the "Unable to get user" error.
USER boring

# --- Execution ---
# Set the entrypoint using an absolute path to the binary we just built.
# This is unambiguous and fixes any potential PATH or permission issues.
ENTRYPOINT ["/app/boringproxy"]
