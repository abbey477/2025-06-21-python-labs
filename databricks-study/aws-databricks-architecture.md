# AWS Databricks Architecture and Components

## Overview
This document provides a comprehensive breakdown of AWS Databricks architecture, components, and terminology.

---

## Complete AWS Databricks Component Tree

```
Databricks Account (e.g., "acme-corp-databricks")
│
├── AWS Account (e.g., "111122223333" - Production)
│   │
│   ├── Region: us-east-1
│   │   │
│   │   ├── Databricks Workspace (e.g., "acme-prod-workspace")
│   │   │   │
│   │   │   ├── Unity Catalog Metastore (e.g., "acme-metastore")
│   │   │   │   │
│   │   │   │   ├── Catalog: "production"
│   │   │   │   │   ├── Schema: "sales"
│   │   │   │   │   │   ├── Table: "transactions"
│   │   │   │   │   │   ├── Table: "customers"
│   │   │   │   │   │   ├── Table: "products"
│   │   │   │   │   │   ├── View: "monthly_revenue"
│   │   │   │   │   │   ├── View: "customer_segments"
│   │   │   │   │   │   └── Function: "calculate_commission"
│   │   │   │   │   │
│   │   │   │   │   ├── Schema: "finance"
│   │   │   │   │   │   ├── Table: "invoices"
│   │   │   │   │   │   ├── Table: "payments"
│   │   │   │   │   │   ├── Table: "budgets"
│   │   │   │   │   │   └── Function: "calculate_tax"
│   │   │   │   │   │
│   │   │   │   │   ├── Schema: "marketing"
│   │   │   │   │   │   ├── Table: "campaigns"
│   │   │   │   │   │   ├── Table: "leads"
│   │   │   │   │   │   ├── Table: "conversions"
│   │   │   │   │   │   └── View: "campaign_roi"
│   │   │   │   │   │
│   │   │   │   │   └── Schema: "hr"
│   │   │   │   │       ├── Table: "employees"
│   │   │   │   │       ├── Table: "departments"
│   │   │   │   │       └── Table: "performance_reviews"
│   │   │   │   │
│   │   │   │   ├── Catalog: "staging"
│   │   │   │   │   ├── Schema: "sales_staging"
│   │   │   │   │   │   └── Table: "transactions_temp"
│   │   │   │   │   └── Schema: "etl_staging"
│   │   │   │   │       ├── Table: "raw_imports"
│   │   │   │   │       └── Table: "validation_errors"
│   │   │   │   │
│   │   │   │   ├── Catalog: "development"
│   │   │   │   │   └── Schema: "experiments"
│   │   │   │   │       ├── Table: "test_data"
│   │   │   │   │       └── Table: "ml_features"
│   │   │   │   │
│   │   │   │   └── Catalog: "raw_data"
│   │   │   │       ├── Schema: "external_sources"
│   │   │   │       │   ├── Table: "s3_csv_data"
│   │   │   │       │   ├── Table: "api_json_data"
│   │   │   │       │   └── Table: "ftp_files"
│   │   │   │       └── Schema: "streaming"
│   │   │   │           ├── Table: "kinesis_events"
│   │   │   │           └── Table: "kafka_messages"
│   │   │   │
│   │   │   ├── Compute Resources
│   │   │   │   ├── All-Purpose Clusters
│   │   │   │   │   ├── Cluster: "data-engineering-cluster"
│   │   │   │   │   │   ├── Driver: i3.xlarge
│   │   │   │   │   │   ├── Workers: 2-8 i3.xlarge (autoscaling)
│   │   │   │   │   │   ├── Spark Version: 3.4.1
│   │   │   │   │   │   └── Runtime: 13.3 LTS
│   │   │   │   │   │
│   │   │   │   │   └── Cluster: "ml-gpu-cluster"
│   │   │   │   │       ├── Driver: g4dn.xlarge
│   │   │   │   │       ├── Workers: 1-4 g4dn.xlarge
│   │   │   │   │       └── Runtime: 13.3 LTS ML
│   │   │   │   │
│   │   │   │   ├── Job Clusters (ephemeral)
│   │   │   │   │   ├── "nightly-etl-cluster"
│   │   │   │   │   └── "weekly-reporting-cluster"
│   │   │   │   │
│   │   │   │   ├── SQL Warehouses
│   │   │   │   │   ├── Warehouse: "analytics-warehouse"
│   │   │   │   │   │   ├── Size: Medium
│   │   │   │   │   │   ├── Clusters: 1-3 (autoscaling)
│   │   │   │   │   │   └── Type: Pro
│   │   │   │   │   └── Warehouse: "executive-dashboard"
│   │   │   │   │       ├── Size: Small
│   │   │   │   │       └── Type: Classic
│   │   │   │   │
│   │   │   │   └── Cluster Policies
│   │   │   │       ├── Policy: "cost-optimized"
│   │   │   │       └── Policy: "performance-optimized"
│   │   │   │
│   │   │   ├── Workspace Files & Notebooks
│   │   │   │   ├── /Workspace
│   │   │   │   │   ├── /Users
│   │   │   │   │   │   ├── /john.doe@acme.com
│   │   │   │   │   │   │   ├── notebook: "sales_analysis.py"
│   │   │   │   │   │   │   ├── notebook: "data_cleaning.sql"
│   │   │   │   │   │   │   └── folder: "/projects"
│   │   │   │   │   │   │       └── notebook: "q4_forecast.py"
│   │   │   │   │   │   │
│   │   │   │   │   │   └── /jane.smith@acme.com
│   │   │   │   │   │       ├── notebook: "ml_model_training.py"
│   │   │   │   │   │       └── notebook: "feature_engineering.py"
│   │   │   │   │   │
│   │   │   │   │   └── /Shared
│   │   │   │   │       ├── /ETL_Pipelines
│   │   │   │   │       │   ├── notebook: "daily_ingestion.py"
│   │   │   │   │       │   ├── notebook: "data_validation.py"
│   │   │   │   │       │   └── notebook: "error_handling.py"
│   │   │   │   │       │
│   │   │   │   │       ├── /ML_Models
│   │   │   │   │       │   ├── notebook: "customer_churn.py"
│   │   │   │   │       │   └── notebook: "recommendation_engine.py"
│   │   │   │   │       │
│   │   │   │   │       └── /Dashboards
│   │   │   │   │           └── notebook: "executive_dashboard.sql"
│   │   │   │   │
│   │   │   │   └── /Repos (Git Integration)
│   │   │   │       └── /acme-analytics-repo
│   │   │   │           ├── /src
│   │   │   │           │   ├── utils.py
│   │   │   │           │   └── transformations.py
│   │   │   │           ├── /notebooks
│   │   │   │           │   └── etl_pipeline.py
│   │   │   │           └── /tests
│   │   │   │               └── test_transformations.py
│   │   │   │
│   │   │   ├── Jobs & Workflows
│   │   │   │   ├── Job: "nightly_data_refresh"
│   │   │   │   │   ├── Task 1: "extract_from_s3"
│   │   │   │   │   ├── Task 2: "transform_data"
│   │   │   │   │   └── Task 3: "load_to_delta"
│   │   │   │   │
│   │   │   │   ├── Job: "weekly_ml_retrain"
│   │   │   │   │   ├── Task 1: "feature_prep"
│   │   │   │   │   └── Task 2: "model_training"
│   │   │   │   │
│   │   │   │   └── Job: "real_time_streaming"
│   │   │   │       └── Continuous Task: "process_kinesis"
│   │   │   │
│   │   │   ├── Delta Live Tables
│   │   │   │   ├── Pipeline: "sales_aggregation"
│   │   │   │   │   ├── Dataset: "bronze_sales"
│   │   │   │   │   ├── Dataset: "silver_sales"
│   │   │   │   │   └── Dataset: "gold_sales_summary"
│   │   │   │   │
│   │   │   │   └── Pipeline: "streaming_ingestion"
│   │   │   │       └── Streaming Table: "live_events"
│   │   │   │
│   │   │   ├── MLflow
│   │   │   │   ├── Experiment: "/sales_forecasting"
│   │   │   │   │   ├── Run: "run_001"
│   │   │   │   │   └── Run: "run_002"
│   │   │   │   │
│   │   │   │   └── Model Registry
│   │   │   │       ├── Model: "customer_churn_model"
│   │   │   │       │   ├── Version: 1 (Staging)
│   │   │   │       │   └── Version: 2 (Production)
│   │   │   │       └── Model: "recommendation_model"
│   │   │   │
│   │   │   ├── Security & Access Control
│   │   │   │   ├── Users
│   │   │   │   │   ├── "john.doe@acme.com"
│   │   │   │   │   ├── "jane.smith@acme.com"
│   │   │   │   │   └── "admin@acme.com"
│   │   │   │   │
│   │   │   │   ├── Groups
│   │   │   │   │   ├── "data-engineers"
│   │   │   │   │   ├── "data-scientists"
│   │   │   │   │   ├── "analysts"
│   │   │   │   │   └── "admins"
│   │   │   │   │
│   │   │   │   └── Service Principals
│   │   │   │       ├── "etl-service-principal"
│   │   │   │       └── "ml-service-principal"
│   │   │   │
│   │   │   └── Secrets Management
│   │   │       └── Secret Scope: "application-secrets"
│   │   │           ├── Secret: "api-key"
│   │   │           └── Secret: "db-password"
│   │   │
│   │   ├── S3 Buckets
│   │   │   ├── "acme-databricks-root"
│   │   │   │   ├── /unity-catalog/
│   │   │   │   ├── /managed-tables/
│   │   │   │   └── /checkpoints/
│   │   │   │
│   │   │   ├── "acme-raw-data"
│   │   │   │   ├── /csv/
│   │   │   │   ├── /json/
│   │   │   │   └── /parquet/
│   │   │   │
│   │   │   ├── "acme-processed-data"
│   │   │   │   ├── /silver/
│   │   │   │   └── /gold/
│   │   │   │
│   │   │   └── "acme-ml-artifacts"
│   │   │       ├── /models/
│   │   │       └── /features/
│   │   │
│   │   ├── IAM Roles & Policies
│   │   │   ├── Role: "databricks-cross-account-role"
│   │   │   │   └── Trust Relationship: Databricks Account
│   │   │   │
│   │   │   ├── Role: "databricks-instance-profile"
│   │   │   │   └── Attached to: EC2 Instances
│   │   │   │
│   │   │   └── Policy: "databricks-s3-access"
│   │   │       └── Permissions: Read/Write S3 Buckets
│   │   │
│   │   └── VPC & Networking
│   │       ├── VPC: "databricks-vpc"
│   │       ├── Subnets: 
│   │       │   ├── "databricks-private-subnet-1a"
│   │       │   └── "databricks-private-subnet-1b"
│   │       ├── Security Groups:
│   │       │   ├── "databricks-sg"
│   │       │   └── "databricks-workspace-sg"
│   │       └── NAT Gateway: "databricks-nat"
│   │
│   └── Region: us-west-2 (Disaster Recovery)
│       └── Databricks Workspace (e.g., "acme-dr-workspace")
│           └── [Similar structure to primary workspace]
│
├── AWS Account (e.g., "444455556666" - Development)
│   └── Region: us-east-1
│       └── Databricks Workspace (e.g., "acme-dev-workspace")
│           └── [Similar structure with dev resources]
│
└── AWS Account (e.g., "777788889999" - QA/Staging)
    └── Region: us-east-1
        └── Databricks Workspace (e.g., "acme-qa-workspace")
            └── [Similar structure with QA resources]
```

---

## Component Descriptions

### 1. **Databricks Account**
- Top-level entity that manages all your Databricks resources
- Controls billing, user management, and workspace creation
- Single account can manage multiple AWS accounts

### 2. **AWS Account**
- Your AWS account that hosts Databricks resources
- Contains compute (EC2), storage (S3), and networking resources
- Can have multiple workspaces across different regions

### 3. **Region**
- AWS geographic location (e.g., us-east-1, eu-west-1)
- Each workspace is deployed in a specific region
- Consider data residency and latency when choosing regions

### 4. **Databricks Workspace**
- Isolated environment for teams or projects
- Contains notebooks, clusters, jobs, and data
- Common patterns: separate workspaces for dev/staging/prod

### 5. **Unity Catalog**
- Unified governance solution for data and AI assets
- Provides centralized metadata and access control
- Can be shared across multiple workspaces

#### Unity Catalog Hierarchy:
```
Metastore (Account Level)
  └── Catalog (Database Collection)
      └── Schema/Database (Table Collection)
          └── Table/View/Function (Data Assets)
```

### 6. **Compute Resources**

#### All-Purpose Clusters
- Interactive development and ad-hoc analysis
- Stays running until manually terminated
- Shared among users
- Best for: notebooks, experimentation

#### Job Clusters
- Created for specific job execution
- Automatically terminates after job completion
- Cost-effective for scheduled workloads
- Best for: ETL, batch processing

#### SQL Warehouses
- Optimized for SQL workloads and BI tools
- Auto-scaling and auto-suspend capabilities
- Supports concurrent queries
- Best for: dashboards, reporting, SQL analytics

### 7. **Storage Architecture**

#### S3 Bucket Types:
- **Root Bucket**: Databricks managed storage
- **Data Buckets**: Your raw and processed data
- **Checkpoint Buckets**: Streaming application state
- **ML Artifact Buckets**: Models and experiment tracking

### 8. **Networking Components**
- **VPC**: Isolated network for Databricks resources
- **Subnets**: Private subnets for compute instances
- **Security Groups**: Firewall rules for network traffic
- **NAT Gateway**: Outbound internet access for private resources

---

## Key Concepts and Relationships

### Catalog vs Database vs Schema
```
Traditional Database World:
  Database → Schema → Table

Databricks Unity Catalog:
  Catalog → Schema (aka Database) → Table

Why the difference?
- Extra layer (Catalog) for better multi-environment separation
- Schema and Database are synonymous in Databricks
```

### User Access Hierarchy
```
User/Group → Workspace Access
    └── Catalog Permissions
        └── Schema Permissions
            └── Table/View Permissions
```

### Data Flow Architecture
```
Raw Data (S3) 
  → Bronze Tables (Raw)
    → Silver Tables (Cleaned)
      → Gold Tables (Business-Ready)
        → BI/ML Applications
```

---

## Common SQL Commands

### Catalog Operations
```sql
-- List all catalogs
SHOW CATALOGS;

-- Create a new catalog
CREATE CATALOG IF NOT EXISTS my_catalog;

-- Use a catalog
USE CATALOG my_catalog;

-- Grant permissions on catalog
GRANT USE CATALOG ON CATALOG my_catalog TO `data-engineers`;
```

### Schema/Database Operations
```sql
-- Create schema in current catalog
CREATE SCHEMA IF NOT EXISTS sales;

-- Create schema with full path
CREATE SCHEMA IF NOT EXISTS my_catalog.sales;

-- List schemas in current catalog
SHOW SCHEMAS;

-- Use a schema
USE SCHEMA sales;
-- or
USE my_catalog.sales;
```

### Table Operations
```sql
-- Create a managed table
CREATE TABLE IF NOT EXISTS my_catalog.sales.transactions (
    id BIGINT,
    customer_id INT,
    amount DECIMAL(10,2),
    transaction_date DATE
) USING DELTA;

-- Create external table pointing to S3
CREATE TABLE IF NOT EXISTS my_catalog.raw_data.csv_data
USING CSV
LOCATION 's3://acme-raw-data/csv/sales/';

-- Query with full path
SELECT * FROM my_catalog.sales.transactions;

-- Query with current catalog/schema context
USE CATALOG my_catalog;
USE SCHEMA sales;
SELECT * FROM transactions;
```

---

## Best Practices

### 1. **Environment Separation**
```
Production Workspace
  └── production catalog (read-only for most users)

Staging Workspace  
  └── staging catalog (for testing)

Development Workspace
  └── development catalog (sandbox for developers)
```

### 2. **Naming Conventions**
```
Catalogs: environment_businessunit (e.g., prod_finance)
Schemas: datasource_layer (e.g., salesforce_bronze)
Tables: entity_type (e.g., customers_fact, orders_dim)
```

### 3. **Access Control Strategy**
- Use groups, not individual users for permissions
- Grant minimum necessary privileges
- Use service principals for automated jobs
- Regularly audit access permissions

### 4. **Cost Optimization**
- Use job clusters for scheduled workloads
- Enable autoscaling and auto-termination
- Use spot instances for fault-tolerant workloads
- Implement cluster policies to control costs

---

## Troubleshooting Quick Reference

### Common Issues and Solutions

| Issue | Likely Cause | Solution |
|-------|--------------|----------|
| "Schema not found" | Wrong catalog context | Check current catalog with `SELECT current_catalog()` |
| "Table not found" | Missing permissions or wrong path | Verify full path: catalog.schema.table |
| "Access denied" | Insufficient privileges | Check grants with `SHOW GRANTS ON TABLE table_name` |
| Cluster won't start | AWS limits or VPC issues | Check AWS service quotas and VPC configuration |
| Slow queries | No statistics or wrong cluster size | Run `ANALYZE TABLE` and optimize cluster configuration |

---

## Additional Resources

- [Databricks on AWS Documentation](https://docs.databricks.com/administration-guide/cloud-configurations/aws/index.html)
- [Unity Catalog Documentation](https://docs.databricks.com/data-governance/unity-catalog/index.html)
- [AWS Databricks Architecture](https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html)
- [Best Practices Guide](https://docs.databricks.com/best-practices/index.html)

---

## Glossary

- **Catalog**: Top-level container for organizing data in Unity Catalog
- **Schema/Database**: Collection of tables, views, and functions (these terms are interchangeable)
- **Metastore**: Central repository for Unity Catalog metadata
- **Workspace**: Isolated Databricks environment for a team or project
- **Cluster**: Group of compute resources for running Spark jobs
- **SQL Warehouse**: Compute endpoint optimized for SQL analytics
- **Delta Table**: Table format providing ACID transactions and time travel
- **Bronze/Silver/Gold**: Data quality tiers in medallion architecture
- **Service Principal**: Non-human identity for automated processes
- **Secret Scope**: Secure storage for credentials and API keys

---

*Last Updated: December 2024*
*Version: 1.0*