FROM clickhouse/clickhouse-server:latest

# Set environment variables for ClickHouse (Data Warehouse)
ENV CLICKHOUSE_DB=sample_dw
ENV CLICKHOUSE_USER=dbc
ENV CLICKHOUSE_PASSWORD=dbc
ENV CLICKHOUSE_HTTP_PORT=1025
ENV CLICKHOUSE_TCP_PORT=1026

# Install required packages
USER root
RUN apt-get update && apt-get install -y bash openssl && rm -rf /var/lib/apt/lists/*

# Create directory for initialization scripts
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy initialization scripts
COPY docker/init-scripts/ /docker-entrypoint-initdb.d/

# Make credential generation script executable
RUN chmod +x /docker-entrypoint-initdb.d/00-generate-credentials.sh

# Create volume for credentials
VOLUME ["/tmp/credentials"]

# Expose ClickHouse ports (simulating Teradata DW)
EXPOSE 1025 1026

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD clickhouse-client --host localhost --port 1026 --query "SELECT 1" || exit 1

# Switch back to clickhouse user
USER clickhouse

# Start ClickHouse
CMD ["/entrypoint.sh"]
