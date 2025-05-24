module "vpc" {
  source = "./modules/vpc"  

  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr= ["10.0.101.0/24", "10.0.102.0/24"]
}

module "security" {
  source = "./modules/security"
  
  vpc_id = module.vpc.vpc_id
  environment = "dev"
  alb_port = 80
  app_port = 8080
  db_port = 3306
}

# Frontend ALB
module "frontend_alb" {
  source = "./modules/frontend_alb"
  
  environment = "dev"
  vpc_id = module.vpc.vpc_id
  alb_security_group = module.security.frontend_alb_security_group_id
  public_subnet_ids = module.vpc.public_subnet_ids
  # Disabled HTTPS since we don't have SSL certificates
  create_https_listener = false
  redirect_http_to_https = false

  depends_on = [module.security]
}

# Backend ALB
module "backend_alb" {
  source = "./modules/backend_alb"
  
  environment = "dev"
  vpc_id = module.vpc.vpc_id
  alb_security_group = module.security.backend_alb_security_group_id
  private_subnet_ids = module.vpc.private_subnet_ids
  api_port = 8080
  health_check_path = "/api/health"

  depends_on = [module.security]
}

# Frontend EC2/ASG
module "frontend_ec2" {
  source = "./modules/ec2"
  
  # Instance Configuration
  ami_id = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  key_name = "ALB_key"  # Using existing key pair
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              
              # Create a simple frontend page
              cat <<'HTML' > /var/www/html/index.html
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Frontend Server</title>
                  <style>
                      body { font-family: Arial, sans-serif; margin: 40px; }
                      .container { max-width: 800px; margin: 0 auto; }
                      .header { background: #007bff; color: white; padding: 20px; border-radius: 5px; }
                      .content { padding: 20px; background: #f8f9fa; border-radius: 5px; margin-top: 20px; }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <div class="header">
                          <h1>Frontend Application</h1>
                          <p>Decoupled Architecture with ALB</p>
                      </div>
                      <div class="content">
                          <h2>Welcome to the Frontend!</h2>
                          <p>This is the frontend tier of our decoupled architecture.</p>
                          <p>Server: $(hostname)</p>
                          <p>Date: $(date)</p>
                          <button onclick="testAPI()">Test Backend API</button>
                          <div id="api-result"></div>
                      </div>
                  </div>
                  
                  <script>
                  function testAPI() {
                      fetch('/api/health')
                          .then(response => response.text())
                          .then(data => {
                              document.getElementById('api-result').innerHTML = '<h3>API Response:</h3><pre>' + data + '</pre>';
                          })
                          .catch(error => {
                              document.getElementById('api-result').innerHTML = '<h3>API Error:</h3><pre>' + error + '</pre>';
                          });
                  }
                  </script>
              </body>
              </html>
HTML
              EOF
  )

  # ASG Configuration
  min_size = 1
  max_size = 3
  desired_capacity = 2
  health_check_type = "ELB"
  health_check_grace_period = 300
  
  # Networking
  subnet_id = module.vpc.public_subnet_ids
  target_group_arn = module.frontend_alb.target_group_arn

  # Security Group Assignment
  security_group_ids = [module.security.frontend_ec2_security_group_id]

  # IAM Instance Profile
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Scaling Policy
  target_cpu_value = 70

  depends_on = [module.security, module.frontend_alb]
}

# Backend EC2/ASG
module "backend_ec2" {
  source = "./modules/ec2"
  
  # Instance Configuration
  ami_id = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  key_name = "ALB_key"  # Using existing key pair
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nodejs npm
              
              # Create a simple Node.js API server
              mkdir -p /opt/api
              cat <<'JS' > /opt/api/server.js
const http = require('http');
const url = require('url');

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const path = parsedUrl.pathname;
    
    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    if (path === '/api/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            status: 'healthy',
            server: require('os').hostname(),
            timestamp: new Date().toISOString(),
            message: 'Backend API is running!'
        }));
    } else if (path.startsWith('/api/')) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            message: 'API endpoint',
            path: path,
            server: require('os').hostname(),
            timestamp: new Date().toISOString()
        }));
    } else {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Not found' }));
    }
});

const PORT = 8080;
server.listen(PORT, () => {
    console.log(`Backend API server running on port $${PORT}`);
});
JS

              # Start the Node.js server
              cd /opt/api
              nohup node server.js > /var/log/api.log 2>&1 &
              
              # Create systemd service for auto-start
              cat <<'SERVICE' > /etc/systemd/system/api.service
[Unit]
Description=Backend API Server
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/api
ExecStart=/usr/bin/node server.js
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

              systemctl enable api
              systemctl start api
              EOF
  )

  # ASG Configuration
  min_size = 1
  max_size = 3
  desired_capacity = 2
  health_check_type = "ELB"
  health_check_grace_period = 300
  
  # Networking
  subnet_id = module.vpc.private_subnet_ids
  target_group_arn = module.backend_alb.target_group_arn

  # Security Group Assignment
  security_group_ids = [module.security.backend_ec2_security_group_id]

  # IAM Instance Profile
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Scaling Policy
  target_cpu_value = 70

  depends_on = [module.security, module.backend_alb]
}

module "rds" {
  source = "./modules/rds"
  
  # Basic Settings
  db_name = "myappdb"
  db_username = "admin"
  db_password = "YourSecurePassword123!"  # Use SSM Parameter Store in production
  db_instance_class = "db.t3.micro"
  
  # Engine
  db_engine = "mysql"
  db_engine_version = "8.0"
  
  # Storage
  db_allocated_storage = 20
  db_max_allocated_storage = 100
  db_storage_type = "gp2"
  
  # Network
  vpc_private_subnet_ids = module.vpc.private_subnet_ids
  
  # Security Group Assignment
  security_group_ids = [module.security.rds_security_group_id]
  
  # Backup
  db_backup_retention_period = 7
  multi_az = true  # Enabled Multi-AZ as shown in the diagram (Primary + Secondary)
  
  # Tags
  tags = {
    Environment = "dev"
    Project = "my-app"
  }

  depends_on = [module.security, module.backend_ec2]
}

# IAM Role for EC2 instances (as shown in diagram)
resource "aws_iam_role" "ec2_role" {
  name = "dev-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "dev-ec2-role"
    Environment = "dev"
  }
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "dev-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# IAM Policy for EC2 instances (CloudWatch, Systems Manager)
resource "aws_iam_role_policy" "ec2_policy" {
  name = "dev-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      }
    ]
  })
}

module "monitoring" {
  source = "./modules/monitoring"

  environment     = "dev"
  asg_name        = module.backend_ec2.asg_name
  alb_arn         = module.backend_alb.alb_arn
  rds_identifier  = module.rds.db_instance_id
  alarm_email     = "your-email@example.com"
  
  # Optional: Override default thresholds
  cpu_threshold           = 70
  memory_threshold       = 80
  response_time_threshold = 5
  error_rate_threshold   = 5

  depends_on = [module.backend_ec2, module.backend_alb, module.rds]
}

# Outputs
output "frontend_alb_dns_name" {
  value = module.frontend_alb.alb_dns_name
}

output "backend_alb_dns_name" {
  value = module.backend_alb.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "frontend_asg_name" {
  value = module.frontend_ec2.asg_name
}

output "backend_asg_name" {
  value = module.backend_ec2.asg_name
}   