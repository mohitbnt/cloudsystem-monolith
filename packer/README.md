# CloudSystem WordPress Golden AMI

Packer build for the CloudSystem WordPress 7.1 application.

Target: Ubuntu 24.04 x86_64 in `ap-south-1`.

## Layout

```text
packer/
├── wordpress.pkr.hcl
├── scripts/
│   └── prepare-wordpress.sh
└── artifacts/
    └── wordpress-7.1-cloudsystem.tar.gz
```

## 1. Get the application artifact

From the repository root:

```bash
mkdir -p packer/artifacts

gh release download wordpress-1.0.0 \
  --pattern 'wordpress-7.1-cloudsystem.tar.gz' \
  --dir packer/artifacts
```

Verify:

```bash
ls -lh packer/artifacts/
```

## 2. Initialize Packer

```bash
cd packer
packer init wordpress.pkr.hcl
```

## 3. Validate

```bash
packer validate wordpress.pkr.hcl
```

## 4. Build

Use the AWS credentials/profile already configured for the CLI:

```bash
packer build wordpress.pkr.hcl
```

If using a named AWS CLI profile:

```bash
AWS_PROFILE=cloudsystem packer build wordpress.pkr.hcl
```

Or override the region:

```bash
packer build \
  -var 'aws_region=ap-south-1' \
  wordpress.pkr.hcl
```

## Build sequence

```text
Ubuntu 24.04 x86_64
        |
        v
Temporary t3.micro builder
        |
        +-- WordPress artifact
        +-- prepare-wordpress.sh
        |
        v
Nginx + PHP-FPM + WordPress
        |
        v
Validation
        |
        v
Golden AMI
        |
        v
Temporary builder terminated
```

## AMI contains

- Ubuntu 24.04 x86_64
- Nginx
- PHP 8.3 + PHP-FPM
- Dedicated `cloudsystem` PHP-FPM pool
- WordPress 7.1
- Redis Object Cache plugin
- WP Offload Media plugin
- AWS CLI v2
- WP-CLI
- SSM Agent

## AMI does not contain

- `wp-config.php`
- database credentials
- RDS endpoint
- Redis endpoint
- S3 credentials
- WordPress uploads
- database data

