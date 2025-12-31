# 🏗️ Databricks on AWS Architecture
## Component Hierarchy: One vs Many Instances

---

## 📊 Legend

- 🔴 **[ONE]** = Can have only ONE per region
- 🟢 **[MANY]** = Can have MANY instances
- ⚠️ **CRITICAL** = Important architectural constraint

---

## 🎯 Visual Component Hierarchy

```
📊 Databricks Account 🟢 [MANY]
│   └── Example: "acme-corp-databricks"
│
├── ☁️ AWS Account #1 - Production 🟢 [MANY]
│   │   └── Account ID: "111122223333"
│   │
│   ├── 🌍 Region: us-east-1 🟢 [MANY]
│   │   │
│   │   ├── ⚠️ 🔒 Unity Catalog Metastore 🔴 [ONE per Region]
│   │   │   │   └── "acme-metastore" (SHARED by all workspaces in region)
│   │   │   │
│   │   │   ├── 📚 Catalog: "production" 🟢 [MANY]
│   │   │   │   ├── 📁 Schema: "sales" 🟢 [MANY]
│   │   │   │   │   ├── 📋 Table: "transactions" 🟢 [MANY]
│   │   │   │   │   ├── 📋 Table: "customers" 🟢 [MANY]
│   │   │   │   │   ├── 📋 Table: "products" 🟢 [MANY]
│   │   │   │   │   ├── 👁️ View: "monthly_revenue" 🟢 [MANY]
│   │   │   │   │   ├── 👁️ View: "customer_segments" 🟢 [MANY]
│   │   │   │   │   └── ⚙️ Function: "calculate_commission" 🟢 [MANY]
│   │   │   │   │
│   │   │   │   ├── 📁 Schema: "marketing" 🟢 [MANY]
│   │   │   │   │   ├── 📋 Table: "campaigns" 🟢 [MANY]
│   │   │   │   │   └── 📋 Table: "leads" 🟢 [MANY]
│   │   │   │   │
│   │   │   │   └── 📁 Schema: "finance" 🟢 [MANY]
│   │   │   │       └── 📋 Table: "invoices" 🟢 [MANY]
│   │   │   │
│   │   │   ├── 📚 Catalog: "development" 🟢 [MANY]
│   │   │   │   └── 📁 Schema: "test_data" 🟢 [MANY]
│   │   │   │
│   │   │   └── 📚 Catalog: "sandbox" 🟢 [MANY]
│   │   │       └── 📁 Schema: "experiments" 🟢 [MANY]
│   │   │
│   │   ├── 💼 Databricks Workspace #1: "acme-prod-workspace" 🟢 [MANY]
│   │   │   └── (Connected to shared metastore above)
│   │   │
│   │   ├── 💼 Databricks Workspace #2: "acme-dev-workspace" 🟢 [MANY]
│   │   │   └── (Connected to shared metastore above)
│   │   │
│   │   └── 💼 Databricks Workspace #3: "acme-analytics-workspace" 🟢 [MANY]
│   │       └── (Connected to shared metastore above)
│   │
│   └── 🌍 Region: us-west-2 🟢 [MANY]
│       │
│       ├── ⚠️ 🔒 Unity Catalog Metastore 🔴 [ONE per Region]
│       │   └── "acme-west-metastore" (DIFFERENT from us-east-1 metastore!)
│       │
│       └── 💼 Databricks Workspace: "acme-west-workspace" 🟢 [MANY]
│
├── ☁️ AWS Account #2 - Development 🟢 [MANY]
│   │   └── Account ID: "444455556666"
│   │
│   └── 🌍 Region: us-east-1 🟢 [MANY]
│       │
│       └── 💼 Databricks Workspace: "acme-test-workspace" 🟢 [MANY]
│           └── (Can connect to the SAME metastore in us-east-1)
│
└── ☁️ AWS Account #3 - Testing 🟢 [MANY]
    └── Account ID: "777788889999"
```

---

## 🔴 Components with ONE Instance Limit

| Component | Scope | Important Notes |
|-----------|-------|-----------------|
| **Unity Catalog Metastore** | One per REGION | • This is the ONLY hard "one" limit<br>• Shared across all workspaces in the same region<br>• Different regions require separate metastores<br>• Cannot share metastore across regions |

---

## 🟢 Components that Support MANY Instances

| Component | Scope | Examples/Notes |
|-----------|-------|----------------|
| **Databricks Account** | Organization | • Usually one per organization<br>• Can have multiple for business unit isolation |
| **AWS Account** | Per Databricks Account | • Common: Dev, Test, Prod accounts<br>• Useful for billing and security isolation |
| **Region** | Per AWS Account | • us-east-1, us-west-2, eu-west-1, etc.<br>• Each region needs its own metastore |
| **Databricks Workspace** | Per Region | • Multiple workspaces per region<br>• All can share the region's single metastore<br>• Common: separate by team/project/environment |
| **Catalog** | Per Metastore | • Logical grouping of schemas<br>• Examples: production, development, raw_data |
| **Schema** | Per Catalog | • Logical grouping of tables<br>• Examples: sales, marketing, finance |
| **Table** | Per Schema | • Unlimited (within practical limits) |
| **View** | Per Schema | • Unlimited (within practical limits) |
| **Function** | Per Schema | • Unlimited (within practical limits) |

---

## ⚠️ Critical Architecture Patterns

### ✅ **VALID: Metastore Sharing (Same Region)**
```
Region: us-east-1
    └── Unity Catalog Metastore (ONLY ONE)
        ├── Connected to → Workspace-1
        ├── Connected to → Workspace-2
        ├── Connected to → Workspace-3
        └── Connected to → Workspace-4
```

### ❌ **INVALID: Metastore Sharing (Cross-Region)**
```
WRONG - This is NOT possible:
Unity Catalog Metastore in us-east-1
    ├── Connected to → Workspace in us-east-1 ✓
    └── Connected to → Workspace in us-west-2 ✗ (Cannot do this!)
```

### ✅ **VALID: Multi-Region Setup**
```
Region: us-east-1
    └── Metastore-1
        └── Multiple Workspaces

Region: us-west-2
    └── Metastore-2 (Completely separate)
        └── Multiple Workspaces
```

---

## 📝 Key Architectural Decisions

### 🎯 What You CAN Do:
- ✅ Create multiple Databricks accounts (though one is typical)
- ✅ Link multiple AWS accounts to one Databricks account
- ✅ Deploy to multiple AWS regions
- ✅ Create multiple workspaces per region
- ✅ Share ONE metastore across ALL workspaces in the SAME region
- ✅ Create unlimited catalogs, schemas, tables, views, and functions

### 🚫 What You CANNOT Do:
- ❌ Have more than ONE metastore per region
- ❌ Share a metastore across different regions
- ❌ Create a workspace without associating it with a region
- ❌ Use the same metastore for us-east-1 and us-west-2

---

## 💡 Best Practices

### 1. **Metastore Strategy** 🔒
- Plan carefully - it's the hardest component to change
- One per region is a hard limit
- Consider data residency requirements
- Plan for disaster recovery across regions

### 2. **Workspace Organization** 💼
```
Recommended Patterns:
├── By Environment
│   ├── Production Workspace
│   ├── Development Workspace
│   └── Testing Workspace
│
├── By Team
│   ├── Data Engineering Workspace
│   ├── Analytics Workspace
│   └── Data Science Workspace
│
└── By Project
    ├── Project-A Workspace
    └── Project-B Workspace
```

### 3. **Catalog Structure** 📚
```
Recommended Patterns:
├── By Environment
│   ├── production_catalog
│   ├── development_catalog
│   └── staging_catalog
│
└── By Data Stage
    ├── bronze_catalog (raw data)
    ├── silver_catalog (cleaned data)
    └── gold_catalog (business-ready data)
```

### 4. **AWS Account Strategy** ☁️
- **Production Account**: Isolated for security and compliance
- **Development Account**: For experimentation and development
- **Shared Services Account**: For common resources

---

## 🔄 Common Implementation Patterns

### Pattern 1: **Single Region, Multiple Environments**
```
AWS Account (Production)
└── Region: us-east-1
    ├── Metastore (SHARED)
    ├── Prod Workspace → production_catalog
    ├── Dev Workspace → development_catalog
    └── Test Workspace → testing_catalog
```

### Pattern 2: **Multi-Region for Disaster Recovery**
```
AWS Account (Production)
├── Region: us-east-1 (Primary)
│   ├── Metastore-1
│   └── Production Workspace
│
└── Region: us-west-2 (DR)
    ├── Metastore-2 (Separate)
    └── DR Workspace
```

### Pattern 3: **Multi-Account Isolation**
```
Databricks Account
├── AWS Account (Prod) → Prod Workspaces
├── AWS Account (Dev) → Dev Workspaces
└── AWS Account (Test) → Test Workspaces
    └── All can share metastore if in same region
```

---

## 📊 Quick Reference Table

| Level | Component | Can Have | Shared Across |
|-------|-----------|----------|---------------|
| 1 | Databricks Account | Many | - |
| 2 | AWS Account | Many | Databricks Account |
| 3 | Region | Many | AWS Account |
| 4 | **Metastore** | **ONE** | **All workspaces in region** |
| 4 | Workspace | Many | Region |
| 5 | Catalog | Many | Metastore |
| 6 | Schema | Many | Catalog |
| 7 | Table/View/Function | Many | Schema |

---

## 🚀 Implementation Checklist

When setting up Databricks on AWS, consider:

- [ ] How many AWS accounts do you need? (billing/security isolation)
- [ ] Which AWS regions will you deploy to?
- [ ] **Remember: ONE metastore per region only!**
- [ ] How many workspaces per region? (team/project/env isolation)
- [ ] Catalog naming strategy (by environment or data stage?)
- [ ] Schema organization (by business domain?)
- [ ] Cross-region disaster recovery needs?
- [ ] Data residency and compliance requirements?

---

## 📌 Remember

> **The Unity Catalog Metastore is the ONLY component with a hard "ONE per region" limit. Everything else can scale!**

This constraint is the most important architectural decision that will affect your entire Databricks deployment strategy.
