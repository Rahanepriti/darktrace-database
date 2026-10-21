import json
from typing import Any

from .redis_client import get_redis_client


def save_record(
    key: str,
    data: dict[str, Any],
    ttl_seconds: int | None = 3600,
) -> None:
    """Save a JSON record in Redis, optionally with an expiry."""
    if not key:
        raise ValueError("key must not be empty")

    if ttl_seconds is not None and ttl_seconds <= 0:
        raise ValueError("ttl_seconds must be greater than zero")

    client = get_redis_client()
    value = json.dumps(data)

    if ttl_seconds is None:
        client.set(key, value)
    else:
        client.set(key, value, ex=ttl_seconds)


def get_record(key: str) -> dict[str, Any] | None:
    """Retrieve a JSON record, returning None if it doesn't exist."""
    if not key:
        raise ValueError("key must not be empty")

    client = get_redis_client()
    value = client.get(key)

    if value is None:
        return None

    record = json.loads(value)

    if not isinstance(record, dict):
        raise ValueError("Stored Redis record must be a JSON object")

    return record


def delete_record(key: str) -> bool:
    """Delete a record and return True if it existed."""
    if not key:
        raise ValueError("key must not be empty")

    return bool(get_redis_client().delete(key))
