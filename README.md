# SSL Infrastructure — Terraform + GitHub Actions (OIDC)

Deploys AWS infrastructure across **Dev**, **UAT**, and **Production** environments using Terraform via GitHub Actions with OIDC authentication (no AWS access keys).

---

## 🏗️ What Gets Provisioned

Each environment gets its own isolated stack:

| Resource         | Dev            | UAT            | Prod           |
|------------------|----------------|----------------|----------------|
| VPC              | 10.0.0.0/16    | 10.1.0.0/16    | 10.2.0.0/16    |
| Public Subnet    | 10.0.1.0/24    | 10.1.1.0/24    | 10.2.1.0/24    |
| Private Subnet   | 10.0.2.0/24    | 10.1.2.0/24    | 10.2.2.0/24    |
| Internet Gateway | ✅             | ✅             | ✅             |
| EC2 Instance     | t2.micro       | t2.micro       | t2.small       |
| Security Group   | SSH + HTTP     | SSH + HTTP     | SSH + HTTP     |
| S3 App Bucket    | ✅ versioned   | ✅ versioned   | ✅ versioned   |

---

## 🔐 Authentication — OIDC (No Access Keys)

This project uses **OpenID Connect (OIDC)** so GitHub Actions can assume an AWS IAM role directly without storing any AWS credentials in GitHub Secrets.

```
Git Push → GitHub Actions → OIDC Token → AWS STS → IAM Role → Terraform → AWS
```

---

## 🚀 How to Deploy

### Dev
Push to the `develop` branch:
```bash
git push origin develop
```

### UAT
Push to the `uat` branch:
```bash
git push origin uat
```

### Production (Manual Only)
1. Push to `main`
2. Go to **GitHub → Actions → AWS Terraform CI/CD → Run workflow**
3. Select:
   - environment: `production`
   - destroy: `false`
4. Click **Run workflow**

---

## 💣 How to Destroy Infrastructure

1. Go to **GitHub → Actions → AWS Terraform CI/CD → Run workflow**
2. Select:
   - environment: `production`
   - destroy: `true`
3. Click **Run workflow**

> ⚠️ This will permanently destroy all provisioned resources in that environment.

---

## 🗄️ Remote State Backend

Terraform state is stored remotely in S3 with DynamoDB locking:

| Environment | S3 Bucket              | DynamoDB Table    | State Key            |
|-------------|------------------------|-------------------|----------------------|
| Dev         | ssl-dev-app-buckettt   | ssl-dev-app-dbb   | dev/terraform.tfstate|
| UAT         | ssl-uat-app-buckettt   | ssl-uat-app-dbb   | uat/terraform.tfstate|
| Prod        | ssl-prod-app-buckettt  | ssl-prod-app-dbb  |prod/terraform.tfstate|

---

## 📁 Project Structure

```
ssl-allinone/
├── .github/
│   └── workflows/
│       └── deploy.yml       # CI/CD pipeline
├── Dev/
│   ├── backend.tf           # S3 remote state config
│   ├── main.tf              # VPC, EC2, S3 resources
│   ├── variables.tf         # Input variables
│   └── outputs.tf           # Resource outputs
├── UAT/
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── Prod/
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── README.md
```

---

## ✅ Pre-requisites Checklist

- [ ] AWS OIDC Identity Provider created
- [ ] IAM Role `GitHubActionsRole` created with trust policy
- [ ] S3 buckets created (dev/uat/prod) with versioning enabled
- [ ] DynamoDB tables created (dev/uat/prod) with LockID partition key
- [ ] `REPLACE_ACCOUNT_ID` updated in `.github/workflows/deploy.yml`
