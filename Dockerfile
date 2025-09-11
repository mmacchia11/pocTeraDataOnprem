FROM postgres:15-alpine

# Set environment variables for PostgreSQL (simulating Teradata)
ENV POSTGRES_DB=sample_db
ENV POSTGRES_USER=dbc
ENV POSTGRES_PASSWORD=dbc
ENV PGPORT=1025

# Install required packages
RUN apk add --no-cache bash openssl

# Create directory for initialization scripts
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy initialization scripts
COPY docker/init-scripts/ /docker-entrypoint-initdb.d/

# Make credential generation script executable
RUN chmod +x /docker-entrypoint-initdb.d/00-generate-credentials.sh

# Create volume for credentials
VOLUME ["/tmp/credentials"]

# Expose PostgreSQL port (simulating Teradata)
EXPOSE 1025

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD pg_isready -h localhost -p 1025 -U dbc || exit 1

# Start PostgreSQL
CMD ["docker-entrypoint.sh", "postgres", "-p", "1025"]