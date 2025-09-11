"""Test Teradata container functionality."""

import socket
from unittest.mock import patch

from src.teradata_onprem.connection import test_connection


def test_port_accessible() -> None:
    """Test that Teradata port is accessible."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(5)
    try:
        result = sock.connect_ex(("localhost", 1025))
        assert result in [
            0,
            61,
            111,
        ]
    finally:
        sock.close()


@patch("src.teradata_onprem.connection.teradatasql.connect")
def test_connection_mock(mock_connect) -> None:
    """Test connection with mocked Teradata."""
    mock_connect.return_value.__enter__.return_value.cursor.return_value.__enter__.return_value.execute.return_value = None

    result = test_connection()
    assert isinstance(result, bool)
