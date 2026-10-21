from db import get_connection


def main():
    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT current_database(), current_user, version();")
                database, user, version = cur.fetchone()

                cur.execute("""
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = 'public'
                    ORDER BY table_name;
                """)
                tables = [row[0] for row in cur.fetchall()]

        print("Railway PostgreSQL connection successful!")
        print(f"Database: {database}")
        print(f"Connected user: {user}")
        print(f"Tables: {', '.join(tables) if tables else 'None found'}")
        print(f"Server: {version.split(',')[0]}")

    except Exception as exc:
        print(f"Connection failed: {type(exc).__name__}: {exc}")
        raise SystemExit(1)


if __name__ == "__main__":
    main()
