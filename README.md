
# DarkTrace Database Schema

## Overview

This project contains the PostgreSQL database schema for the DarkTrace application. The database is hosted on Railway.

The schema defines three tables: `users`, `source`, and `crawl_job`.

## Database Tables

### 1. users
Stores user account information, including:
- User ID, username, and email
- Password hash
- User role and account status
- Multi-factor authentication setting
- Account creation and last login timestamps

### 2. source
Stores the sources that the application monitors or crawls, including:
- Source name and type
- Onion address, when applicable
- Authentication reference
- Crawl policy and health information in JSONB format
- Source status
- The user who created the source

### 3. crawl_job
Stores crawl job information, including:
- Job ID and intent ID
- Associated source
- Job type and current state
- Attempt count and statistics
- Error information
- Start and finish timestamps

## Relationships

- `source.created_by` references `users.usr_id`.
- `crawl_job.source_id` references `source.source_id`.

These foreign keys help maintain referential integrity between the tables.

## Database Features

- Primary keys identify records.
- Unique constraints prevent duplicate usernames and email addresses.
- CHECK constraints restrict roles, source types, statuses, job types, and job states to allowed values.
- Default values are defined for applicable columns.
- Indexes support queries on user roles, source statuses, crawl job sources, and crawl job states.
- `TIMESTAMPTZ` stores timezone-aware timestamps.
- `JSONB` stores structured crawl policies, health information, and job statistics.

## Project Structure

```text
darktrace-database/
├── README.md
└── database/
    └── schema.sql
```

## Railway Hosting

The PostgreSQL database is hosted on Railway. The three tables and their relationships have been created in the hosted database.

## Recreating the Schema

The `database/schema.sql` file contains the SQL definitions needed to create the tables, constraints, and indexes in a new, empty PostgreSQL database.

**Important:** Do not run this script against the existing database where these tables already exist.

## Security

- Never commit database passwords or connection strings.
- Store passwords as secure hashes, not plaintext.
- Keep database credentials in environment variables or a secure secrets manager.
