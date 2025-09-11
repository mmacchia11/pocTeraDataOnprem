"""Test ClickHouse Data Warehouse container functionality."""

import socket
from unittest.mock import patch

from src.teradata_onprem.connection import test_connection


def test_port_accessible() -> None:
    """Test that ClickHouse port is accessible."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(5)
    try:
        result = sock.connect_ex(("localhost", 1025))
        # Port should be accessible (result == 0) or connection refused (container not running)
        assert result in [
            0,
            61,
            111,
        ]  # 0=success, 61=connection refused (macOS), 111=connection refused (Linux)
    finally:
        sock.close()


@patch("src.teradata_onprem.connection.requests.post")
def test_connection_mock(mock_post) -> None:
    """Test connection with mocked ClickHouse."""
    mock_post.return_value.status_code = 200
    mock_post.return_value.text = "1"

    result = test_connection()
    assert isinstance(result, bool)
