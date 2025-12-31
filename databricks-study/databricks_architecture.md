# 🏗️ Databricks Architecture on AWS

## Understanding Key Databricks Terms and Components

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    🏛️ LAKEHOUSE PLATFORM (Databricks)                    │
│      Unified platform combining data lake + data warehouse capabilities  │
│                                                                          │
│  ┌─────────────────────────────────┬─────────────────────────────────┐   │
│  │  🎛️ CONTROL PLANE               │  ⚡ COMPUTE/DATA PLANE           │   │
│  │  (Databricks Managed)           │  (Your AWS Account)             │   │
│  ├─────────────────────────────────┼─────────────────────────────────┤   │
│  │                                 │                                 │   │
│  │  ┌─────────────────────────┐    │  ┌─────────────────────────┐    │   │
│  │  │ 📋 Workspace            │    │  │ 💻 Databricks Compute   │    │   │
│  │  │                         │    │  │    Cluster              │    │   │
│  │  │ • Notebooks             │    │  │                         │    │   │
│  │  │ • Dashboards            │    │  │ EC2 instances running   │    │   │
│  │  │ • Libraries             │    │  │ your Spark jobs and     │    │   │
│  │  │ • Configurations        │    │  │ ML workloads            │    │   │
│  │  │ • Web UI interface      │    │  │                         │    │   │
│  │  └─────────────────────────┘    │  │ Types:                  │    │   │
│  │                                 │  │ • All-purpose clusters  │    │   │
│  │  ┌─────────────────────────┐    │  │ • Job clusters          │    │   │
│  │  │ 🔧 Cluster Management   │    │  │ • SQL warehouses        │    │   │
│  │  │                         │    │  └─────────────────────────┘    │   │
│  │  │ • Create/configure      │    │                                 │   │
│  │  │ • Autoscaling           │    │  ┌─────────────────────────┐    │   │
│  │  │ • Termination policies  │    │  │ 🚀 Databricks Runtime   │    │   │
│  │  │ • Monitoring            │    │  │                         │    │   │
│  │  └─────────────────────────┘    │  │ Software stack:         │    │   │
│  │                                 │  │ • Apache Spark          │    │   │
│  │  ┌─────────────────────────┐    │  │ • Delta Lake            │    │   │
│  │  │ ⚙️ Jobs Scheduler       │    │  │ • Python/Scala/R/SQL    │    │   │
│  │  │                         │    │  │ • ML libraries          │    │   │
│  │  │ • Workflow orchestration│    │  │ • Photon engine         │    │   │
│  │  │ • Job runs              │    │  │ • Optimizations         │    │   │
│  │  │ • Execution history     │    │  └─────────────────────────┘    │   │
│  │  └─────────────────────────┘    │                                 │   │
│  │                                 │  ┌─────────────────────────┐    │   │
│  │  ┌─────────────────────────┐    │  │ 🗄️ Databricks Storage   │    │   │
│  │  │ 🔐 Security & Access    │    │  │                         │    │   │
│  │  │    Control              │    │  │ S3 Buckets containing:  │    │   │
│  │  │                         │    │  │ • Delta Lake tables     │    │   │
│  │  │ • Authentication        │    │  │ • Raw data files        │    │   │
│  │  │ • Authorization         │    │  │   (parquet, JSON, CSV)  │    │   │
│  │  │ • Audit logging         │    │  │ • ML models & artifacts │    │   │
│  │  └─────────────────────────┘    │  │ • Notebook results      │    │   │
│  │                                 │  └─────────────────────────┘    │   │
│  │                                 │                                 │   │
│  │                                 │  ┌─────────────────────────┐    │   │
│  │                                 │  │ 📊 Metastore            │    │   │
│  │                                 │  │                         │    │   │
│  │                                 │  │ AWS Glue or Hive        │    │   │
│  │                                 │  │ • Table metadata        │    │   │
│  │                                 │  │ • Schema definitions    │    │   │
│  │                                 │  │ • Data locations        │    │   │
│  │                                 │  └─────────────────────────┘    │   │
│  └─────────────────────────────────┴─────────────────────────────────┘   │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────┐
│                  ☁️ CLOUD PROVIDER: Amazon Web Services (AWS)              │
│                                                                            │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐  ┌───────────┐ │
│  │ 🖥️ EC2         │  │ 💾 S3          │  │ 🔒 IAM         │  │ 🌐 VPC    │ │
│  │                │  │                │  │                │  │           │ │
│  │ Virtual servers│  │ Object storage │  │ Identity &     │  │ Virtual   │ │
│  │ for compute    │  │ for data lakes │  │ Access         │  │ Network   │ │
│  │ clusters       │  │ and files      │  │ Management     │  │           │ │
│  └────────────────┘  └────────────────┘  └────────────────┘  └───────────┘ │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Typical Data Processing Flow

```
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│   User writes    │         │   Submits to     │         │    Launches      │
│   code in        │  ────>  │   Control Plane  │  ────>  │    Compute       │
│   Workspace      │         │                  │         │    Cluster       │
└──────────────────┘         └──────────────────┘         └──────────────────┘
                                                                    │
                                                                    ↓
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│   Results back   │         │   Reads/Writes   │         │    Runtime       │
│   to Workspace   │  <────  │   S3 Storage     │  <───>  │    executes code │
│                  │         │                  │         │    on cluster    │
└──────────────────┘         └──────────────────┘         └──────────────────┘
```

---

## 📚 Detailed Term Definitions

### 🏛️ Lakehouse Platform
**What it is:** The unified Databricks architecture that combines the flexibility of data lakes with the performance and structure of data warehouses.

**Key characteristics:**
- Single platform for all data, analytics, and AI workloads
- ACID transactions on data lakes via Delta Lake
- Direct querying of raw data files
- Supports batch and streaming data
- Eliminates data silos

---

### 🎛️ Control Plane
**What it is:** The Databricks-managed infrastructure that handles orchestration, management, and user interactions.

**Location:** Hosted and managed by Databricks (not in your AWS account)

**Responsibilities:**
- Serving the web UI/workspace
- Managing cluster lifecycle
- Job scheduling and orchestration
- Security and access control
- Monitoring and logging

**Why it matters:** You don't need to maintain this infrastructure; Databricks handles it for you.

---

### ⚡ Compute/Data Plane
**What it is:** The actual compute and storage resources that run in YOUR AWS account.

**Location:** Your AWS VPC (Virtual Private Cloud)

**Contains:**
- EC2 instances running Databricks clusters
- S3 buckets storing your data
- Network configurations
- IAM roles and permissions

**Why it matters:** Your data never leaves your AWS account. You have full control over security, compliance, and costs.

---

### 📋 Workspace
**What it is:** Your collaborative development environment accessible through a web browser.

**Contains:**
- **Notebooks:** Interactive documents combining code, visualizations, and markdown
- **Dashboards:** Visual reports and KPIs
- **Libraries:** Custom packages and dependencies
- **Data:** Data browser and table catalog
- **Jobs:** Scheduled workflows
- **Experiments:** ML experiment tracking

**Think of it as:** Your IDE in the cloud, but for data engineering and data science.

---

### 💻 Databricks Compute Cluster
**What it is:** A set of EC2 instances (virtual machines) that execute your data processing workloads.

**Physical reality:** These are actual EC2 servers running in your AWS account's VPC.

**Types:**

1. **All-Purpose Clusters**
   - For interactive development
   - Used with notebooks
   - Can be shared among users
   - Stay running until manually terminated

2. **Job Clusters**
   - For automated production workloads
   - Automatically terminated after job completes
   - Optimized for cost efficiency

3. **SQL Warehouses**
   - Specialized for SQL queries
   - Optimized for BI and analytics

**Configuration includes:**
- Instance types (compute-optimized, memory-optimized, GPU)
- Number of workers (autoscaling range)
- Databricks runtime version
- Libraries and dependencies

---

### 🚀 Databricks Runtime
**What it is:** The pre-configured software environment installed on every cluster node.

**Contains:**
- **Apache Spark:** Distributed computing engine
- **Delta Lake:** Storage layer providing ACID transactions
- **Language support:** Python, Scala, R, SQL, Java
- **ML libraries:** scikit-learn, TensorFlow, PyTorch, MLflow
- **Photon:** Databricks' high-performance query engine
- **Optimizations:** Performance enhancements beyond vanilla Spark

**Versions:**
- **Databricks Runtime:** Standard for data engineering
- **Databricks Runtime ML:** Pre-installed ML libraries
- **Databricks Runtime for Genomics:** Specialized for genomic analysis
- **Photon Runtime:** With Photon query engine enabled

**Think of it as:** The operating system and software stack that makes your cluster powerful and easy to use.

---

### 🗄️ Databricks Storage
**What it is:** S3 buckets in your AWS account where all your data physically resides.

**Stores:**

1. **Delta Lake Tables**
   - Optimized Parquet files with transaction logs
   - ACID-compliant table format
   - Time travel and versioning

2. **Raw Data Files**
   - CSV, JSON, Parquet, Avro, ORC
   - Images, videos, documents
   - Log files and streaming data

3. **ML Artifacts**
   - Trained models
   - Feature tables
   - Experiment results

4. **Metadata**
   - Cluster logs
   - Notebook outputs
   - Job results

**Storage architecture:**
- **Workspace storage:** Databricks-managed S3 for workspace artifacts
- **User storage:** Your own S3 buckets (recommended for data)
- **Root storage:** Default storage for clusters and jobs

---

### ☁️ Cloud Provider (AWS)
**What it is:** The underlying infrastructure provider (in this case, Amazon Web Services).

**Databricks leverages these AWS services:**

| AWS Service | Purpose in Databricks |
|-------------|----------------------|
| **EC2** | Compute instances for clusters |
| **S3** | Object storage for data and artifacts |
| **IAM** | Identity and access management, roles for clusters |
| **VPC** | Network isolation and security |
| **Security Groups** | Firewall rules for cluster access |
| **CloudWatch** | Monitoring and logging |
| **KMS** | Encryption key management |
| **Glue Catalog** | Optional metastore for table metadata |
| **STS** | Temporary security credentials |

**Multi-cloud note:** Databricks also supports Azure and Google Cloud Platform with similar architectures.

---

## 🔑 Key Takeaways

### Architecture Summary

1. **Control Plane (Databricks-managed)**
   - Handles UI, orchestration, and management
   - You don't manage this infrastructure
   - Hosted by Databricks

2. **Data/Compute Plane (Your AWS account)**
   - Runs actual workloads on EC2
   - Stores data in S3
   - You control security and compliance

3. **Separation of Concerns**
   - Management (Control Plane) vs. Execution (Compute Plane)
   - Enables security and compliance
   - Your data never leaves your cloud account

### Data Flow

```
User → Workspace (Control) → Cluster Management (Control) → 
Compute Cluster (Data Plane) → Runtime Execution → S3 Storage (Data Plane) → 
Results → Workspace
```

### Cost Implications

- **Databricks charges:** For platform features (DBUs - Databricks Units)
- **AWS charges:** For EC2 instances, S3 storage, data transfer
- **Total cost:** Databricks DBUs + AWS infrastructure costs

---

## 🎯 Common Use Cases

### 1. Data Engineering
```
Raw data (S3) → Cluster with Runtime → 
Transform with Spark → Clean Delta Tables (S3)
```

### 2. Data Science
```
Data (S3) → Notebook in Workspace → 
ML Runtime Cluster → Train models → 
Store models (S3) + MLflow tracking
```

### 3. BI & Analytics
```
Delta Tables (S3) → SQL Warehouse → 
Dashboards in Workspace → Business insights
```

### 4. Real-time Streaming
```
Kinesis/Kafka → Cluster with Runtime → 
Structured Streaming → Delta Lake (S3) → Real-time dashboards
```

---

## 🔒 Security Model

**Control Plane Security (Databricks manages):**
- User authentication (SSO, SAML)
- Workspace access controls
- API token management

**Data Plane Security (You manage in AWS):**
- VPC configuration and network isolation
- IAM roles and policies
- S3 bucket encryption
- Security groups
- Private connectivity (AWS PrivateLink)

**Data never crosses planes:** Your actual data stays in your AWS account.

---

## 🚀 Getting Started Flow

1. **Setup:** Create Databricks workspace linked to your AWS account
2. **Configure:** Set up VPC, IAM roles, S3 buckets
3. **Create:** Launch a cluster with appropriate runtime
4. **Develop:** Write code in notebooks in your workspace
5. **Execute:** Run code on clusters, data processes in data plane
6. **Store:** Results saved to S3 in Delta Lake format
7. **Monitor:** Track performance and costs in workspace and AWS console

---

## 📖 Glossary Quick Reference

| Term | One-Line Definition |
|------|---------------------|
| **Lakehouse Platform** | Unified architecture combining data lake + data warehouse |
| **Control Plane** | Databricks-managed orchestration and UI layer |
| **Data/Compute Plane** | Your AWS account's compute (EC2) and storage (S3) |
| **Workspace** | Web-based collaborative development environment |
| **Compute Cluster** | EC2 instances executing your data workloads |
| **Runtime** | Pre-configured software stack (Spark, Delta, ML libs) on clusters |
| **Storage** | S3 buckets holding your data and Delta tables |
| **Cloud Provider** | AWS infrastructure services (EC2, S3, IAM, VPC) |

---

## 💡 Best Practices

### Cluster Management
- Use **job clusters** for production workloads (auto-terminate)
- Use **all-purpose clusters** for development (can be shared)
- Enable **autoscaling** to optimize costs
- Set **auto-termination** timeouts to avoid idle costs

### Storage Organization
- Use **Delta Lake** format for structured data
- Organize data in **medallion architecture** (bronze/silver/gold)
- Implement **partitioning** for large datasets
- Enable **optimization** and **vacuum** commands regularly

### Security
- Use **AWS IAM instance profiles** for cluster access to S3
- Enable **encryption at rest** (S3) and **in transit** (TLS)
- Implement **workspace access controls** by role
- Use **secrets management** for credentials

---

*This document provides a comprehensive overview of Databricks architecture on AWS. For production deployments, consult Databricks and AWS documentation for detailed configuration and security requirements.*
