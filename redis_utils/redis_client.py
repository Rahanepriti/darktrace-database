import os

import redis
from dotenv import load_dotenv

load_dotenv()


def get_redis_client() -> redis.Redis:
    """Create a Redis client using REDIS_URL from the environment."""
    redis_url = os.getenv("REDIS_URL")

    if not redis_url:
        raise RuntimeError("REDIS_URL is missing from the environment")

    return redis.Redis.from_url(
        redis_url,
        decode_responses=True,
        socket_connect_timeout=5,
        socket_timeout=5,
        health_check_interval=30,
    )
