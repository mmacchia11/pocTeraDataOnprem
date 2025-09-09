"""Teradata connection utilities."""

import teradatasql


def get_connection(
    host: str = "localhost", user: str = "dbc", password: str = "dbc"
) -> teradatasql.TeradataConnection:
    """Get Teradata connection."""
    return teradatasql.connect(host=host, user=user, password=password, dbs_port="1025")


def test_connection(host: str = "localhost") -> bool:
    """Test Teradata connection."""
    try:
        with get_connection(host=host) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
                return True
    except Exception:
        return False
