"""ClickHouse Data Warehouse connection utilities."""

import requests


def get_connection(
    host: str = "localhost", user: str = "dbc", password: str = "dbc", port: int = 1025
) -> str:
    """Get ClickHouse connection URL."""
    return f"http://{user}:{password}@{host}:{port}"


def execute_query(
    query: str, host: str = "localhost", user: str = "dbc", password: str = "dbc"
) -> dict:
    """Execute query on ClickHouse."""
    url = f"http://{host}:1025"
    params = {"user": user, "password": password, "query": query}
    response = requests.post(url, params=params, timeout=30)
    return {"status": response.status_code, "data": response.text}


def test_connection(host: str = "localhost") -> bool:
    """Test ClickHouse connection."""
    try:
        result = execute_query("SELECT 1", host=host)
        return bool(result["status"] == 200)
    except Exception:
        return False
