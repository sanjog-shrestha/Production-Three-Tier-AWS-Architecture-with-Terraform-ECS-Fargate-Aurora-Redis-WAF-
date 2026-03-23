# 🏭 Production Three-Tier AWS Architecture with Terraform (ECS Fargate + Aurora + Redis + WAF)

## 📌 Overview

This project demonstrates how to deploy a **production-grade, three-tier cloud application** on **Amazon Web Services (AWS)** using **HashiCorp Terraform** Infrastructure as Code (IaC).

Terraform provisions and configures a fully isolated, highly available infrastructure across three network tiers — a public web tier, a private application tier, and a private data tier — with enterprise-grade security controls, automated scaling, full observability, and trusted HTTPS via CloudFront.

The infrastructure includes:
- Custom VPC with 6 subnets across 3 tiers and 2 Availability Zones
- AWS WAFv2 protecting the ALB with managed rule groups and rate limiting
- **AWS CloudFront distribution providing free trusted HTTPS — no custom domain required**
- Application Load Balancer (ALB) in the public tier
- ECS Fargate tasks in private application subnets with NAT Gateway outbound access
- Aurora MySQL Serverless v2 cluster (writer + reader) in the private data tier
- ElastiCache Redis replication group (Multi-AZ, encrypted) in the private data tier
- Three-policy auto scaling (CPU, memory, and request count) between 2–20 tasks
- CloudWatch alarms for CPU high/low monitoring
- Four independent security groups with strict least-privilege chaining
- **AWS Secrets Manager for encrypted Aurora MySQL credential management**

This project highlights production cloud architecture, defence-in-depth security, serverless data services, HTTPS delivery, and advanced DevOps deployment practices.

---

## 🏗️ Architecture

```
User Browser
     ↓ HTTPS (trusted *.cloudfront.net — AWS-managed certificate)
AWS CloudFront Distribution
     ↓ HTTP :80 (origin request)
AWS WAFv2 Web ACL
(Common Rules + IP Reputation + Rate Limit 1000 req/IP)
     ↓
┌─────────────────────────────────────────────────────────────────┐
│                      VPC (10.0.0.0/16)                          │
│                                                                 │
│  ── PUBLIC TIER ──────────────────────────────────────────────  │
│  Public Subnet 1 (AZ-a)        Public Subnet 2 (AZ-b)          │
│  10.0.1.0/24                   10.0.2.0/24                      │
│  [ALB]  [NAT GW + EIP]         [ALB]  [NAT GW + EIP]           │
│                    ↓                                            │
│  ── APPLICATION TIER ─────────────────────────────────────────  │
│  Private App Subnet 1 (AZ-a)   Private App Subnet 2 (AZ-b)     │
│  10.0.11.0/24                  10.0.12.0/24                     │
│  [ECS Fargate Task]            [ECS Fargate Task]               │
│  (no public IP, NAT outbound)  (no public IP, NAT outbound)    │
│                    ↓                                            │
│  ── DATA TIER ────────────────────────────────────────────────  │
│  Private DB Subnet 1 (AZ-a)    Private DB Subnet 2 (AZ-b)      │
│  10.0.21.0/24                  10.0.22.0/24                     │
│  [Aurora MySQL Writer]         [Aurora MySQL Reader]            │
│  [Redis Primary]               [Redis Replica]                  │
└─────────────────────────────────────────────────────────────────┘
         ↕ Auto Scaling (2–20 tasks)
         CPU > 65% → Scale Out
         Memory > 75% → Scale Out
         ALB Requests > 1000/target → Scale Out
```

> 📸 **Architecture Screenshot:**
<img width="1024" height="1536" alt="image" src="https://github.com/user-attachments/assets/36c1b234-fb7c-42e7-a166-356c1fe8d131" />

---

## ☁️ AWS Deployment

### Provisioned Resources

| Resource | Description |
|---|---|
| VPC | `10.0.0.0/16` with DNS hostnames and DNS support enabled |
| Public Subnets (×2) | `10.0.1.0/24` and `10.0.2.0/24` — ALB and NAT Gateways |
| Private App Subnets (×2) | `10.0.11.0/24` and `10.0.12.0/24` — ECS Fargate tasks |
| Private DB Subnets (×2) | `10.0.21.0/24` and `10.0.22.0/24` — Aurora and Redis |
| Internet Gateway | Provides internet access for public subnets |
| NAT Gateway (×2) | One per AZ — allows private app subnets outbound internet access |
| Elastic IPs (×2) | Static IPs assigned to each NAT Gateway |
| Public Route Table | Routes `0.0.0.0/0` to Internet Gateway for public subnets |
| Private App Route Tables (×2) | Per-AZ routes to respective NAT Gateways |
| Private DB Route Table | No internet route — fully isolated data tier |
| WAFv2 Web ACL | AWS Common Rule Set (count mode), IP Reputation List, Rate Limiting (1000 req/IP) |
| WAFv2 ALB Association | Web ACL attached directly to the ALB |
| CloudFront Distribution | HTTPS termination on `*.cloudfront.net` — free trusted certificate |
| ALB Security Group | Accepts HTTP (80) and HTTPS (443) from internet |
| ECS Security Group | Accepts HTTP only from ALB security group |
| Redis Security Group | Accepts port 6379 only from ECS security group |
| Aurora Security Group | Accepts port 3306 only from ECS security group |
| Application Load Balancer | Internet-facing ALB across both public subnets |
| Target Group | IP-based target group with `/` health check |
| HTTP Listener | Forwards port 80 traffic to the target group |
| ECS Cluster | Fargate cluster with Container Insights enabled |
| Capacity Providers | 70% FARGATE / 30% FARGATE_SPOT for cost optimisation |
| ECS Task Definition | Fargate task: 512 CPU / 1024 MB, Nginx, production env vars |
| ECS Service | 2 desired tasks in private app subnets, no public IPs |
| IAM Execution Role | Least-privilege role for image pull, CloudWatch logging, and Secrets Manager read |
| CloudWatch Log Group | `/ecs/<project>` with 30-day retention |
| Auto Scaling Target | 2–20 tasks |
| CPU Scaling Policy | Scales out at 65% CPU utilisation |
| Memory Scaling Policy | Scales out at 75% memory utilisation |
| Request Count Scaling Policy | Scales out at 1000 ALB requests per target |
| CloudWatch CPU High Alarm | Alerts when CPU exceeds 85% for 2 evaluation periods |
| CloudWatch CPU Low Alarm | Alerts when CPU drops below 10% for 2 evaluation periods |
| Aurora MySQL Cluster | Serverless v2, engine `aurora-mysql 8.0`, encrypted at rest |
| Aurora Parameter Group | UTF-8 charset, slow query logging enabled (>2s) |
| Aurora Writer Instance | `db.serverless` class, scales 0.5–16 ACUs automatically |
| Aurora Reader Instance | `db.serverless` class, read scaling and failover target |
| Aurora DB Subnet Group | Restricted to private DB subnets |
| Redis Replication Group | Multi-AZ, automatic failover, encrypted in-transit and at-rest |
| Redis Parameter Group | `allkeys-lru` eviction policy |
| Redis Subnet Group | Restricted to private DB subnets |
| Secrets Manager Secret | Encrypted Aurora credentials (`<project>/aurora/credentials`) |

> 📸 **AWS Console Screenshot:**
<img width="1633" height="728" alt="image" src="https://github.com/user-attachments/assets/54df9194-b55a-4b1c-8061-a00ca4d0ded1" />
<img width="1630" height="717" alt="image" src="https://github.com/user-attachments/assets/4e5e980c-ec44-439d-86e1-c4dcf6f3d677" />
<img width="1631" height="118" alt="image" src="https://github.com/user-attachments/assets/64a60edf-554f-413b-aa23-93462f9717e5" />

---

## 📂 Repository Structure

```
terraform-production-three-tier/
├── providers.tf           # Terraform version, AWS + null provider, default tags
├── variables.tf           # Input variables: region, project name, environment, DB credentials
├── vpc.tf                 # VPC with DNS support
├── subnet.tf              # 6 subnets across 3 tiers and 2 AZs
├── internet-gw.tf         # Internet Gateway for public tier
├── nat-gw.tf              # Dual NAT Gateways + Elastic IPs (one per AZ)
├── route-tables.tf        # Public, private app (×2), and private DB route tables
├── security-groups.tf     # 4 security groups: ALB, ECS, Redis, Aurora
├── waf.tf                 # WAFv2 Web ACL + ALB association
├── alb.tf                 # ALB, target group, HTTP listener
├── cloudfront.tf          # CloudFront distribution — HTTPS on *.cloudfront.net
├── ecs.tf                 # ECS cluster, task definition, service, IAM, CloudWatch logs
├── autoscaling.tf         # 3-policy auto scaling + CloudWatch alarms
├── aurora.tf              # Aurora MySQL Serverless v2 cluster + parameter group
├── redis.tf               # ElastiCache Redis replication group + parameter group
├── secrets.tf             # Secrets Manager secret, versioning, data source, IAM read policy
└── outputs.tf             # CloudFront URL, ALB DNS, Redis/Aurora endpoints, secret ARN
```

### File Explanations

| File | Purpose |
|---|---|
| `providers.tf` | Pins Terraform `>=1.14.0`, AWS provider `~> 5.0`, null `~> 3.0`, applies default tags |
| `variables.tf` | Defines `aws_region`, `project_name`, `environment`, `db_username`, `db_password` variables |
| `vpc.tf` | Creates the VPC (`10.0.0.0/16`) with DNS hostnames enabled |
| `subnet.tf` | 2 public, 2 private app, 2 private DB subnets across 2 AZs |
| `internet-gw.tf` | Internet Gateway for public subnet internet access |
| `nat-gw.tf` | 2 NAT Gateways with Elastic IPs for private app subnet outbound access |
| `route-tables.tf` | 4 route tables with correct associations per subnet tier |
| `security-groups.tf` | ALB, ECS, Redis, Aurora security groups with strict least-privilege rules |
| `waf.tf` | WAFv2 Web ACL with 3 rules: Common Rule Set (count), IP Reputation, Rate Limiting |
| `alb.tf` | Public ALB, IP-based target group with health checks, HTTP listener |
| `cloudfront.tf` | CloudFront distribution — free trusted HTTPS on `*.cloudfront.net` |
| `ecs.tf` | Cluster, capacity providers, task definition, service, IAM role, CloudWatch logs |
| `autoscaling.tf` | 3 scaling policies (CPU, memory, requests) + 2 CloudWatch alarms |
| `aurora.tf` | Aurora MySQL Serverless v2 cluster with writer + reader instances |
| `redis.tf` | Multi-AZ Redis replication group with encryption and LRU eviction |
| `secrets.tf` | Creates Secrets Manager secret, seeds Aurora credentials, exposes data source, IAM read policy |
| `outputs.tf` | Outputs CloudFront HTTPS URL, ALB DNS, cluster name, Redis/Aurora endpoints, secret ARN |

---

## ⚙️ Terraform Design Approach

### 1️⃣ Infrastructure as Code

Terraform declaratively defines every AWS resource, enabling:
- Version-controlled infrastructure across all environments
- Repeatable deployments with a single command
- No manual console steps — everything is code
- Default tags on every resource for cost tracking and filtering

### 2️⃣ Three-Tier Network Isolation

The VPC is divided into three completely isolated tiers:
- **Public tier** — ALB and NAT Gateways only. Internet-reachable, but no application logic here
- **Private application tier** — ECS Fargate tasks. No public IPs. Outbound via NAT Gateway only
- **Private data tier** — Aurora and Redis. No internet route at all. Reachable only from the application tier

This is the correct production network model. Each tier can only receive traffic from the tier directly above it.

### 3️⃣ Defence-in-Depth Security

Security is enforced at multiple layers simultaneously:
- **CloudFront** provides HTTPS termination at the edge before traffic reaches the ALB
- **WAFv2** inspects all CloudFront origin requests for known exploits and rate-abusive IPs
- **Security groups** chain traffic strictly: CloudFront → ALB → ECS → Redis/Aurora
- **No public IPs on ECS tasks** — containers are not directly reachable from the internet
- **No internet route on DB subnets** — data tier is completely isolated from outbound internet
- **Secrets Manager** — Aurora credentials are never stored in source code, state files, or terminal history

### 4️⃣ Dual NAT Gateways for High Availability

One NAT Gateway per Availability Zone ensures that if one AZ goes down, private app subnets in the other AZ still have outbound internet access. Using a single NAT Gateway would make outbound connectivity a single point of failure.

### 5️⃣ Aurora Serverless v2

Aurora Serverless v2 scales compute capacity automatically between 0.5 and 16 Aurora Capacity Units (ACUs) based on load. This means:
- Near-zero cost during quiet periods (scales down to 0.5 ACU)
- Instant capacity for traffic spikes (scales to 16 ACU within seconds)
- Separate writer and reader instances for read/write splitting

### 6️⃣ Three-Policy Auto Scaling

The ECS service scales between 2 and 20 tasks using three independent policies:
- **CPU scaling** — triggers at 65% average CPU utilisation
- **Memory scaling** — triggers at 75% average memory utilisation
- **Request count scaling** — triggers at 1000 ALB requests per target

Having three policies means the service scales proactively on whichever signal indicates pressure first, rather than waiting for one metric to breach while another is already under stress.

### 7️⃣ AWS Secrets Manager for Aurora Credentials

Aurora MySQL credentials are stored encrypted in **AWS Secrets Manager** via a dedicated `secrets.tf` file. The secret stores a full JSON payload containing username, password, host, port, engine, and database name. The ECS task receives the secret ARN as a `DB_SECRET_ARN` environment variable at runtime, and the IAM execution role has an inline policy scoped to that exact secret ARN — it cannot read any other secret in the account.

> 📸 **Secrets Manager Console Screenshot:**
<img width="1918" height="816" alt="Image" src="https://github.com/user-attachments/assets/7fb051be-88fb-4bc9-a103-b5fa076c4922" />

### 8️⃣ HTTPS via AWS CloudFront

HTTPS is provided by an **AWS CloudFront distribution** placed in front of the ALB. CloudFront uses its own free, AWS-managed certificate on a `*.cloudfront.net` domain — no custom domain, no ACM certificate request, no DNS validation, and no browser security warnings required. CloudFront terminates HTTPS from the browser and forwards plain HTTP to the ALB on port 80 internally.

The WAFv2 Web ACL remains attached to the ALB — all CloudFront origin requests still pass through the WAF before reaching the ECS tasks, preserving the full defence-in-depth security model.

> ⚠️ **Important:** CloudFront must connect to the ALB using `origin_protocol_policy = "http-only"`. Using `"https-only"` causes a 504 Gateway Timeout because the ALB has no HTTPS listener.

### 9️⃣ WAFv2 Common Rule Set — Count Mode

The `AWSManagedRulesCommonRuleSet` is set to `override_action { count {} }` rather than `none {}`. This is because the Common Rule Set can flag CloudFront forwarded headers (such as `X-Forwarded-For` and `X-Forwarded-Proto`) as suspicious traffic, causing false positive blocks. Count mode logs all rule matches without blocking, allowing you to review WAF sampled requests and confirm no legitimate traffic is being flagged. Once verified, switch to `none {}` to re-enable full enforcement.

---

## 🚀 Deployment Instructions

### Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.14.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with valid credentials
- AWS account with ECS, RDS, ElastiCache, WAF, EC2, IAM, CloudWatch, **Secrets Manager**, and **CloudFront** permissions

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/your-username/terraform-production-three-tier.git
cd terraform-production-three-tier
```

**2. Initialize Terraform**
```bash
terraform init
```

**3. Validate Configuration**
```bash
terraform validate
```

**4. Review Execution Plan**
```bash
terraform plan \
  -var="aws_region=eu-west-2" \
  -var="project_name=myapp" \
  -var="environment=prod" \
  -var="db_username=adminuser" \
  -var="db_password=YourSecurePassword123!"
```

> 🔒 Both `db_username` and `db_password` will show as `(sensitive value)` in the plan output — this confirms redaction is working correctly.

**5. Apply Infrastructure**
```bash
terraform apply \
  -var="aws_region=eu-west-2" \
  -var="project_name=myapp" \
  -var="environment=prod" \
  -var="db_username=adminuser" \
  -var="db_password=YourSecurePassword123!"
```

> ⚠️ Aurora and Redis provisioning takes approximately **10–15 minutes**. ECS tasks will reach healthy state within 2–3 minutes after that.

> ⚠️ CloudFront takes **5–10 minutes** to deploy globally. Wait for full propagation before testing the HTTPS URL.

> 🔒 After first apply, credentials are stored encrypted in Secrets Manager. They never need to be passed again unless rotated.

---

## 🔍 Terraform Deployment Output

After a successful `terraform apply`, you will see:

```
app_url                    = "https://xxxxxxxxxxxx.cloudfront.net"
cloudfront_domain          = "xxxxxxxxxxxx.cloudfront.net"
cloudfront_distribution_id = "XXXXXXXXXXXXXX"
alb_dns_name               = "myapp-alb-xxxxxxxxxxxx.eu-west-2.elb.amazonaws.com"
ecs_cluster_name           = "myapp-cluster"
cloudwatch_log_group       = "/ecs/myapp"
redis_primary_endpoint     = "myapp-redis.xxxxxx.0001.euw2.cache.amazonaws.com"
redis_reader_endpoint      = "myapp-redis-ro.xxxxxx.0001.euw2.cache.amazonaws.com"
redis_port                 = 6379
aurora_writer_endpoint     = <sensitive>
aurora_reader_endpoint     = <sensitive>
aurora_database_name       = "appdb"
aurora_port                = 3306
aurora_secret_arn          = "arn:aws:secretsmanager:eu-west-2:xxxxxxxxxxxx:secret:myapp/aurora/credentials"
vpc_id                     = "vpc-xxxxxxxxxxxxxxxxx"
public_subnet_ids          = ["subnet-xxxxxxxxx", "subnet-xxxxxxxxx"]
private_app_subnet_ids     = ["subnet-xxxxxxxxx", "subnet-xxxxxxxxx"]
private_db_subnet_ids      = ["subnet-xxxxxxxxx", "subnet-xxxxxxxxx"]
```

> 📸 **Deployment Screenshot:**
<img width="1057" height="607" alt="image" src="https://github.com/user-attachments/assets/1f13383e-9858-4e8e-9fec-015fafbafe1a" />


---

## 🌐 Application Validation

Once Terraform completes deployment and CloudFront has propagated, copy the `app_url` and open it in your browser:

```
https://xxxxxxxxxxxx.cloudfront.net
```

The Nginx container responds confirming that:
- ECS Fargate tasks are running and healthy in the private application tier
- CloudFront is serving the application over trusted HTTPS
- The ALB is routing traffic correctly through the WAF
- Target group health checks are passing
- No browser security warning is shown

> 📸 **App Screenshot:**
<img width="1918" height="842" alt="image" src="https://github.com/user-attachments/assets/f38b8d22-8d6a-4979-843e-d8d40c6d3f80" />


---

## 🔒 Security Validation

### HTTPS via CloudFront

Navigate to **AWS Console → CloudFront → Distributions**

Your distribution will show:
- **Status:** `Enabled`
- **Domain name:** `xxxxxxxxxxxx.cloudfront.net`
- **Certificate:** `Default CloudFront Certificate`
- **Origin:** your ALB DNS name

> 📸 **CloudFront Distribution Screenshot:**
<!-- TO ADD: Go to AWS Console → CloudFront → Distributions → take a screenshot showing Status Enabled and your domain → upload to GitHub and replace this line with the img tag -->
<img width="1918" height="356" alt="image" src="https://github.com/user-attachments/assets/3ed9e9eb-2bac-464a-9f36-e88127ee0e51" />

### WAFv2 Protection

Navigate to **AWS Console → WAF & Shield → Web ACLs → `myapp-waf`**

The WAF rules active on the ALB:

| Rule | Priority | Action |
|---|---|---|
| AWSManagedRulesCommonRuleSet | 1 | Count (review sampled requests — switch to Block once confirmed) |
| AWSManagedRulesAmazonIpReputationList | 2 | Block known malicious IPs |
| RateLimitRule | 3 | Block IPs exceeding 1000 requests |

> ⚠️ The Common Rule Set is in **count mode** to prevent false positive blocks on CloudFront forwarded headers. Review WAF sampled requests in the console and switch `override_action` from `count {}` to `none {}` in `waf.tf` to re-enable full blocking once confirmed.

> 📸 **WAF Screenshot:**
<img width="1860" height="652" alt="image" src="https://github.com/user-attachments/assets/d5060605-6632-4baa-a236-1814efdfb945" />

### Private Tier Isolation

Navigate to **ECS → Cluster → Tasks → click any task**

The task detail shows:
- **Launch type:** `FARGATE`
- **Subnet:** a private app subnet (`10.0.11.x` or `10.0.12.x`)
- **Public IP:** none — containers are not publicly reachable

> 📸 **Fargate Task Screenshot:**
<img width="1915" height="681" alt="image" src="https://github.com/user-attachments/assets/5ab989c5-aeaf-4178-b9ad-7b2d62128df7" />
<img width="1917" height="655" alt="image" src="https://github.com/user-attachments/assets/70e56ced-5bba-4b7c-b8e8-db41ebdbf976" />
<img width="1918" height="830" alt="image" src="https://github.com/user-attachments/assets/7cc22af3-b09c-4c81-a3e2-5ed9f873aae8" />

### Secrets Manager Credential Validation

Navigate to **AWS Console → Secrets Manager → `myapp/aurora/credentials`**

The secret confirms:
- Credentials are stored as encrypted JSON containing username, password, host, port, engine, and dbname
- The IAM execution role has read-only access scoped to this secret ARN only
- The `DB_SECRET_ARN` environment variable in the ECS task definition points to this secret

> 📸 **Secrets Manager Screenshot:**
<img width="1918" height="816" alt="Image" src="https://github.com/user-attachments/assets/7fb051be-88fb-4bc9-a103-b5fa076c4922" />

---

## 📊 Auto Scaling Validation

The ECS service scales between **2 and 20 tasks** using three independent policies.

Navigate to **ECS → Cluster → Service → Configuration and networking tab → Service auto scaling**

| Policy | Metric | Threshold | Scale Out | Scale In |
|---|---|---|---|---|
| CPU Scaling | ECS CPU Utilisation | 65% | 60 seconds | 300 seconds |
| Memory Scaling | ECS Memory Utilisation | 75% | 60 seconds | 300 seconds |
| Request Count Scaling | ALB Requests Per Target | 1000 | 60 seconds | 300 seconds |

> 📸 **Auto Scaling Screenshot:**
<img width="1916" height="836" alt="image" src="https://github.com/user-attachments/assets/de41b4f4-22f0-44fb-894b-99dac8bbacd2" />

---

## 📊 Infrastructure Summary

| Component | Service Used |
|---|---|
| Networking | Amazon VPC, 6 Subnets (3 tiers × 2 AZs), IGW, Dual NAT Gateways |
| HTTPS / CDN | AWS CloudFront — free trusted certificate on `*.cloudfront.net` |
| Security | AWS WAFv2, 4 Security Groups (least-privilege chaining) |
| Credential Management | AWS Secrets Manager |
| Load Balancing | AWS Application Load Balancer (ALB) |
| Container Orchestration | AWS ECS Fargate (FARGATE + FARGATE_SPOT) |
| Auto Scaling | AWS Application Auto Scaling (3 policies) |
| Observability | CloudWatch Logs, Container Insights, CloudWatch Alarms |
| Database | Amazon Aurora MySQL Serverless v2 (writer + reader) |
| Cache | Amazon ElastiCache Redis 7 (Multi-AZ, encrypted) |
| IAM | ECS Task Execution Role (least-privilege + Secrets Manager read) |
| Infrastructure Provisioning | Terraform >= 1.14.0 / AWS Provider ~> 5.0 |
| Region | eu-west-2 (London) |

---

## 🧠 Key Concepts Demonstrated

- Three-tier VPC design with full network isolation per tier
- Dual NAT Gateways for per-AZ high availability of outbound connectivity
- AWS WAFv2 with managed rule groups and IP-based rate limiting
- HTTPS via CloudFront — free trusted certificate, no custom domain required
- `origin_protocol_policy = "http-only"` — correct CloudFront-to-ALB origin configuration
- WAFv2 count mode to prevent false positive blocks on CloudFront forwarded headers
- ECS Fargate tasks running in private subnets with no public IPs
- Aurora MySQL Serverless v2 with auto-scaling ACUs and separate read/write endpoints
- ElastiCache Redis Multi-AZ replication with at-rest and in-transit encryption
- Three-policy auto scaling (CPU, memory, request count) with CloudWatch alarms
- Least-privilege security group chaining across all four tiers
- Default tag strategy for cost tracking across all resources
- Terraform resource dependency management across 17 logical files
- AWS Secrets Manager for encrypted Aurora credential storage and runtime injection
- `sensitive = true` variable flag for Terraform output redaction
- Least-privilege inline IAM policy scoped to a single secret ARN
- `DB_SECRET_ARN` environment variable pattern for secure runtime credential retrieval

---

## 🏁 Project Outcomes

This project demonstrates the ability to:

- Design and deploy a production-grade three-tier architecture on AWS
- Implement defence-in-depth security at the CloudFront, WAF, network, and security group layers
- Add trusted HTTPS to a production stack without a custom domain using CloudFront
- Diagnose and resolve real-world 504 errors caused by incorrect CloudFront origin protocol configuration
- Deploy serverless container workloads in fully private network tiers
- Provision Aurora Serverless v2 and Redis with encryption and multi-AZ resilience
- Configure multi-metric auto scaling with CloudWatch observability
- Structure complex Terraform configurations across logical, single-responsibility files
- Apply enterprise cloud architecture patterns using Infrastructure as Code
- Manage database credentials securely using AWS Secrets Manager via Terraform
- Inject secret ARNs into ECS tasks for secure runtime credential retrieval

---

## 🔮 Future Improvements

Potential enhancements:

- [x] ~~HTTPS with AWS Certificate Manager + ALB HTTPS listener~~ ✅ Completed via CloudFront
- [x] ~~AWS Secrets Manager for Aurora credentials instead of hardcoded values~~ ✅ Completed
- [ ] Re-enable WAFv2 Common Rule Set full blocking after verifying no CloudFront false positives
- [ ] Custom domain with Route 53 + ACM certificate on CloudFront
- [ ] Amazon ECR for private container image hosting with image scanning
- [ ] CI/CD pipeline with GitHub Actions — build, push to ECR, deploy to ECS
- [ ] Terraform remote state with S3 + DynamoDB locking
- [ ] AWS Shield Advanced for enhanced DDoS protection
- [ ] Aurora Global Database for cross-region disaster recovery
- [ ] Redis AUTH token for additional Redis authentication layer
- [ ] VPC Flow Logs for network traffic auditing

---

## 📄 Author

**Sanjog Shrestha**

---

## 📜 License

This project is intended for educational and portfolio purposes.
