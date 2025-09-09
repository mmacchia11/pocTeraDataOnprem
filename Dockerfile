FROM teradata/teradata-server:17.20.00.00

# Set environment variables
ENV ACCEPT_EULA=Y
ENV TD_SETUP=Y

# Create directory for initialization scripts
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy initialization scripts
COPY docker/init-scripts/ /docker-entrypoint-initdb.d/

# Make credential generation script executable
RUN chmod +x /docker-entrypoint-initdb.d/00-generate-credentials.sh

# Create volume for credentials
VOLUME ["/tmp/credentials"]

# Expose Teradata ports
EXPOSE 1025 1026

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /opt/teradata/tdat/bin/tdsqlc -h localhost -u dbc -p dbc -c "SELECT 1;" || exit 1

# Start Teradata
CMD ["/usr/sbin/init"]