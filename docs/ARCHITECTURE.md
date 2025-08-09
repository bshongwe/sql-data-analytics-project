# 🏗️ System Architecture

## 🌐 High-Level Architecture

```mermaid
C4Context
    title System Context Diagram - SQL Data Analytics Platform

    Person(user, "Data Analyst", "Analyzes business data")
    Person(devops, "DevOps Engineer", "Manages deployments")
    
    System(analytics, "SQL Analytics Platform", "Bronze-Silver-Gold data warehouse")
    
    System_Ext(github, "GitHub", "Source control & CI/CD")
    System_Ext(azure, "Azure Cloud", "Infrastructure hosting")
    System_Ext(terraform, "Terraform", "Infrastructure orchestration")
    
    Rel(user, analytics, "Queries data")
    Rel(devops, terraform, "Deploys infrastructure")
    Rel(terraform, github, "Triggers workflows")
    Rel(github, azure, "Deploys resources")
    Rel(azure, analytics, "Hosts platform")
```

## 🏢 Container Architecture

```mermaid
C4Container
    title Container Diagram - SQL Analytics Platform

    Container(web, "Analytics Dashboard", "Web App", "Business intelligence interface")
    Container(api, "Data API", "REST API", "Data access layer")
    
    ContainerDb(bronze, "Bronze Layer", "SQL Database", "Raw data storage")
    ContainerDb(silver, "Silver Layer", "SQL Database", "Cleaned data")
    ContainerDb(gold, "Gold Layer", "SQL Database", "Business-ready data")
    
    Container(etl, "ETL Pipeline", "GitHub Actions", "Data transformation")
    Container(storage, "File Storage", "Azure Blob", "CSV data files")
    
    Rel(web, api, "Queries", "HTTPS")
    Rel(api, gold, "Reads", "SQL")
    Rel(etl, bronze, "Loads", "BULK INSERT")
    Rel(etl, silver, "Transforms", "SQL")
    Rel(etl, gold, "Aggregates", "SQL")
    Rel(etl, storage, "Reads", "HTTPS")
```

## 🔄 Blue-Green Deployment Architecture

```mermaid
graph TB
    subgraph "Control Plane"
        T[🔧 Terraform]
        GH[⚙️ GitHub Actions]
        AG[🌐 Application Gateway]
    end
    
    subgraph "Blue Environment 🔵"
        BS[SQL Server Blue]
        BD[Database Blue]
        BST[Storage Blue]
    end
    
    subgraph "Green Environment 🟢"
        GS[SQL Server Green]
        GD[Database Green]
        GST[Storage Green]
    end
    
    subgraph "Shared Services"
        KV[🔐 Key Vault]
        MON[📊 Monitoring]
        LOG[📝 Logging]
    end
    
    T --> GH
    GH --> BS
    GH --> GS
    
    AG --> BS
    AG --> GS
    
    BS --> KV
    GS --> KV
    
    BS --> MON
    GS --> MON
    
    U[👥 Users] --> AG
    
    style BS fill:#87CEEB
    style BD fill:#87CEEB
    style BST fill:#87CEEB
    style GS fill:#90EE90
    style GD fill:#90EE90
    style GST fill:#90EE90
```

## 📊 Data Flow Architecture

```mermaid
flowchart TD
    subgraph "Data Sources"
        CSV1[📄 Customers CSV]
        CSV2[📄 Products CSV]
        CSV3[📄 Sales CSV]
    end
    
    subgraph "Bronze Layer 🥉"
        B1[raw_customers]
        B2[raw_products]
        B3[raw_sales]
    end
    
    subgraph "Silver Layer 🥈"
        S1[customers]
        S2[products]
        S3[sales]
    end
    
    subgraph "Gold Layer 🥇"
        G1[dim_customers]
        G2[dim_products]
        G3[fact_sales]
    end
    
    subgraph "Analytics Layer 📊"
        R1[Customer Reports]
        R2[Product Reports]
        R3[Sales Analytics]
    end
    
    CSV1 --> B1
    CSV2 --> B2
    CSV3 --> B3
    
    B1 --> S1
    B2 --> S2
    B3 --> S3
    
    S1 --> G1
    S2 --> G2
    S3 --> G3
    
    G1 --> R1
    G2 --> R2
    G3 --> R3
    
    style B1 fill:#CD853F
    style B2 fill:#CD853F
    style B3 fill:#CD853F
    style S1 fill:#C0C0C0
    style S2 fill:#C0C0C0
    style S3 fill:#C0C0C0
    style G1 fill:#FFD700
    style G2 fill:#FFD700
    style G3 fill:#FFD700
```

## 🔐 Security Architecture

```mermaid
graph TB
    subgraph "Identity & Access"
        AAD[Azure AD]
        SP[Service Principal]
        RBAC[Role-Based Access]
    end
    
    subgraph "Secret Management"
        KV[Key Vault]
        GHS[GitHub Secrets]
        ENV[Environment Variables]
    end
    
    subgraph "Network Security"
        NSG[Network Security Groups]
        PE[Private Endpoints]
        FW[Azure Firewall]
    end
    
    subgraph "Data Security"
        TDE[Transparent Data Encryption]
        MASK[Dynamic Data Masking]
        AUDIT[SQL Audit]
    end
    
    AAD --> SP
    SP --> RBAC
    
    KV --> GHS
    GHS --> ENV
    
    NSG --> PE
    PE --> FW
    
    TDE --> MASK
    MASK --> AUDIT
    
    style AAD fill:#4CAF50
    style KV fill:#FF9800
    style NSG fill:#2196F3
    style TDE fill:#9C27B0
```

## 🚀 Deployment Pipeline Architecture

```mermaid
gitgraph
    commit id: "Initial"
    branch blue
    checkout blue
    commit id: "Deploy Blue"
    commit id: "Test Blue"
    checkout main
    merge blue
    commit id: "Blue Live"
    
    branch green
    checkout green
    commit id: "Deploy Green"
    commit id: "Test Green"
    commit id: "Switch Traffic"
    checkout main
    merge green
    commit id: "Green Live"
    
    branch hotfix
    checkout hotfix
    commit id: "Rollback Blue"
    checkout main
    merge hotfix
    commit id: "Blue Restored"
```

## 📈 Monitoring Architecture

```mermaid
graph LR
    subgraph "Data Sources"
        APP[Application Logs]
        DB[Database Metrics]
        INFRA[Infrastructure Metrics]
    end
    
    subgraph "Collection"
        LA[Log Analytics]
        AI[Application Insights]
        MON[Azure Monitor]
    end
    
    subgraph "Visualization"
        DASH[Azure Dashboard]
        WORK[Workbooks]
        ALERT[Alerts]
    end
    
    subgraph "Actions"
        EMAIL[📧 Email]
        SLACK[💬 Slack]
        AUTO[🤖 Auto-Scale]
    end
    
    APP --> LA
    DB --> MON
    INFRA --> AI
    
    LA --> DASH
    MON --> WORK
    AI --> ALERT
    
    ALERT --> EMAIL
    ALERT --> SLACK
    ALERT --> AUTO
    
    style DASH fill:#4CAF50
    style ALERT fill:#FF5722
    style AUTO fill:#2196F3
```