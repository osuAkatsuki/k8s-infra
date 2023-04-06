#!/usr/bin/env python3

# This script can be quite useful in tandem with
# mysqldump -u root -p --opt --where="1 limit 50000" akatsuki > local.sql

import argparse
import asyncio
import logging
import secrets

from databases import Database

SERVICES = (  # used to create read & write users
    "users-service",
    "akatsuki-api",
    "hanayo",
    "bancho-service",
    "score-service",
)
INITIALLY_AVAILABLE_DB = "defaultdb"


def get_dsn(
    scheme: str,
    username: str,
    password: str,
    host: str,
    port: int,
    database: str,
) -> str:
    return f"{scheme}://{username}:{password}@{host}:{port}/{database}"


async def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--scheme",
        default="postgresql",
        help="Database scheme",
    )
    parser.add_argument(
        "--username",
        default="postgres",
        help="Database username",
    )
    parser.add_argument(
        "--password",
        default="postgres",
        help="Database password",
    )
    parser.add_argument(
        "--host",
        default="localhost",
        help="Database host",
    )
    parser.add_argument(
        "--port",
        default=5432,
        help="Database port",
    )
    parser.add_argument(
        "--database",
        default="akatsuki",
        help="Database name",
    )

    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO)

    async with Database(
        url=get_dsn(
            scheme=args.scheme,
            username=args.username,
            password=args.password,
            host=args.host,
            port=args.port,
            database=INITIALLY_AVAILABLE_DB,
        )
    ) as db:
        logging.info("Creating akatsuki database...")
        await db.execute("CREATE DATABASE akastuki")
        await db.execute("use akatsuki")

        logging.info("Creating read & write users...")

        for service in SERVICES:
            logging.info(f"Creating users for {service}...")
            # read user
            await db.execute(
                "CREATE USER :username@'%' IDENTIFIED BY :password",
                {"username": f"{service}_read", "password": secrets.token_urlsafe(32)},
            )
            await db.execute(
                "GRANT SELECT ON akatsuki.* TO :username@'%'",
                {"username": f"{service}_read"},
            )

            # write user
            await db.execute(
                "CREATE USER :username@'%' IDENTIFIED BY :password",
                {"username": f"{service}_write", "password": secrets.token_urlsafe(32)},
            )
            await db.execute(
                # NOTE: the write usually ideally should not have DELETE
                #       as the system should be soft-deleting all entities.
                #       unfortunately, many legacy portions of our codebase hard-delete.
                "GRANT INSERT, UPDATE, DELETE ON akatsuki.* TO :username@'%'",
                {"username": f"{service}_write"},
            )

        logging.info("Importing database schema...")

        # run the database import
        await db.execute("source akatsuki.sql")

        logging.info("Done!")


if __name__ == "__main__":
    raise SystemExit(asyncio.run(main()))
