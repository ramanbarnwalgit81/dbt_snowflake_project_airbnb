# 🏠 Airbnb Analytics — dbt + Snowflake Project

An end-to-end data transformation pipeline built with **dbt (v1.11)** and **Snowflake**, following the **Bronze → Silver → Gold** medallion architecture pattern on Airbnb booking data.

---

## 📐 Architecture

```
Sources (Staging)          Bronze              Silver               Gold
┌──────────────┐     ┌──────────────┐    ┌───────────────┐    ┌──────────────┐
│  bookings    │────▶│bronze_bookings│──▶│silver_bookings │──▶│              │
│  listings    │────▶│bronze_listings│──▶│silver_listings │──▶│   OBT        │──▶ Fact Table
│  hosts       │────▶│bronze_hosts   │──▶│silver_hosts    │──▶│              │    + Snapshots
└──────────────┘     └──────────────┘    └───────────────┘    └──────────────┘
     (raw)            (incremental)       (transformations)    (joins + dims)
```

### Layer Details

| Layer | Schema | Materialization | Purpose |
|-------|--------|-----------------|---------|
| **Bronze** | `AIRBNB.BRONZE` | Incremental | Raw data ingestion with incremental loads based on `CREATED_AT` |
| **Silver** | `AIRBNB.SILVER` | Incremental | Business logic — calculated fields, data cleansing, tagging |
| **Gold** | `AIRBNB.GOLD` | Table | Final analytics-ready tables — OBT (One Big Table), Fact table |

---

## 📁 Project Structure

```
aws_dbt_snowflake_project/
├── models/
│   ├── sources/
│   │   └── sources.yml              # Source definitions (staging schema)
│   ├── bronze/
│   │   ├── bronze_bookings.sql      # Incremental load from staging.bookings
│   │   ├── bronze_listings.sql      # Incremental load from staging.listings
│   │   └── bronze_hosts.sql         # Incremental load from staging.hosts
│   ├── silver/
│   │   ├── silver_bookings.sql      # Adds total_amount calc, cleaning_fee, service_fee
│   │   ├── silver_listings.sql      # Adds price_per_night_tag via macro
│   │   └── silver_hosts.sql         # Adds response_rate_quality, trimmed host_name
│   └── gold/
│       ├── obt.sql                  # One Big Table — joins all silver tables
│       ├── fact.sql                 # Fact table joining OBT with dimension snapshots
│       └── ephemeral/
│           ├── bookings.sql         # Ephemeral: booking dimensions from OBT
│           ├── listings.sql         # Ephemeral: listing dimensions from OBT
│           └── hosts.sql            # Ephemeral: host dimensions from OBT
├── snapshots/
│   ├── dim_bookings.yml             # SCD Type 2 snapshot on bookings
│   ├── dim_listings.yml             # SCD Type 2 snapshot on listings
│   └── dim_hosts.yml                # SCD Type 2 snapshot on hosts
├── macros/
│   ├── generate_schema_name.sql     # Custom schema naming (uses custom_schema directly)
│   ├── multiply.sql                 # Generic multiplication macro
│   ├── tag.sql                      # Price tagging macro (low/medium/high)
│   └── trimmer.sql                  # String trimming macro
├── data_tests/
│   └── source_tests.sql             # Singular test on source bookings data
├── analyses/
│   ├── explore.sql                  # Ad-hoc exploration queries
│   ├── if_else.sql                  # Jinja if/else examples
│   └── loop.sql                     # Jinja loop examples
├── dbt_project.yml                  # Project configuration
└── profiles.yml                     # Snowflake connection profile
```

---

## ✨ Key Features

### 🔄 Incremental Models
Bronze models use `is_incremental()` to only process new records based on `CREATED_AT`, avoiding full table scans on every run.

### 📸 SCD Type 2 Snapshots
Dimension tables (`dim_bookings`, `dim_listings`, `dim_hosts`) use dbt's **timestamp strategy** to track historical changes with `dbt_valid_from` / `dbt_valid_to` columns.

### 🧩 Dynamic SQL Generation
The OBT and Fact models use **Jinja loops over config arrays** to dynamically generate multi-table JOINs — making the SQL DRY and easily extensible.

### 🏷️ Custom Macros
- **`tag(col)`** — Categorizes numeric values into `low` / `medium` / `high`
- **`multiply(col1, col2, decimals)`** — Multiplies two columns with rounding
- **`trimmer(col)`** — Trims whitespace from string columns
- **`generate_schema_name`** — Routes models to their configured schema (bronze/silver/gold) without the default prefix

---

## 🚀 Getting Started

### Prerequisites
- Python 3.12+
- [uv](https://docs.astral.sh/uv/) (Python package manager)
- Snowflake account with the `AIRBNB` database and `STAGING` schema populated

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/ramanbarnwalgit81/dbt_snowflake_project_airbnb.git
cd dbt_snowflake_project_airbnb

# 2. Install dependencies
uv sync

# 3. Activate the virtual environment
# Windows PowerShell:
& ".venv\Scripts\Activate.ps1"
# macOS/Linux:
source .venv/bin/activate

# 4. Update profiles.yml with your Snowflake credentials
# Edit: aws_dbt_snowflake_project/profiles.yml

# 5. Navigate to the dbt project
cd aws_dbt_snowflake_project

# 6. Verify connection
dbt debug

# 7. Run the full pipeline
dbt run

# 8. Run snapshots
dbt snapshot

# 9. Run tests
dbt test
```

---

## 🔧 Useful Commands

| Command | Description |
|---------|-------------|
| `dbt run` | Run all models |
| `dbt run --select silver` | Run only silver layer models |
| `dbt run --select fact` | Run a specific model |
| `dbt snapshot` | Execute SCD Type 2 snapshots |
| `dbt test` | Run all data tests |
| `dbt compile --select <model>` | Compile Jinja to plain SQL (for debugging) |
| `dbt run --full-refresh` | Full refresh incremental models |

---

## 🛠️ Tech Stack

- **[dbt-core](https://www.getdbt.com/)** v1.11.7 — SQL transformation framework
- **[dbt-snowflake](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup)** v1.11.3 — Snowflake adapter
- **[Snowflake](https://www.snowflake.com/)** — Cloud data warehouse
- **[uv](https://docs.astral.sh/uv/)** — Fast Python package manager

---

## ⚠️ Security Note

> **Do not commit `profiles.yml` with real credentials.** Use environment variables or a `.env` file instead. The `profiles.yml` should be added to `.gitignore` in production environments.

---

## 📄 License

This project is for educational and demonstration purposes.
