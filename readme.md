# Installing Docker on EC2
```bash
sudo apt update
```

```bash
sudo apt install -y docker.io
```

```bash
sudo systemctl start docker
```

```bash
sudo systemctl enable docker
```

```bash
sudo usermod -aG docker ubuntu
```

* sudo – Run the command with superuser (admin) privileges.
* usermod – A Linux command to modify a user account.
* -aG docker – Add the user to the docker group (-aG stands for append to groups).
* ubuntu – The username you are modifying (in EC2, it's often ubuntu by default).

Why it matters:
By default, only the root user (or with sudo) can run Docker commands.
This command adds your user (ubuntu) to the docker group, allowing you to run Docker commands without needing sudo every time.

# Docker Compose setup on EC2

🔹 Command 1: Download Docker Compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose
```

* curl -L — Downloads from a URL, following redirects.
* $(uname -s) — Inserts your system's OS name (e.g., Linux).
* $(uname -m) — Inserts your system's architecture (e.g., x86_64).

This command downloads Docker Compose binary and saves it as /usr/local/bin/docker-compose.

Output: /usr/local/bin/docker-compose file created.


🔹 Command 2: Make It Executable
```bash
sudo chmod +x /usr/local/bin/docker-compose
```
Adds execute permissions so you can run it like a regular command.

# Maven setup

```bash
sudo apt update
```

```bash
sudo apt install -y maven
```
Install Maven on EC2

```bash
mvn clean package
```
Build .jar file 

# Cloud Watch Logging Configuration

* Create IAM role with following Policies attached to IAM Role
* Finally Attach this IAM role to EC2

```bash
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents"
  ],
  "Resource": "*"
}

```

# What is Cloud Watch 
AWS CloudWatch is a monitoring and observability service provided by Amazon Web Services. It helps you collect, track, and analyze metrics, collect and monitor log files, and set alarms to respond automatically to changes in your AWS resources or applications.

Key Features of AWS CloudWatch:
* Metrics Monitoring:

  * Collects data points (CPU usage, disk I/O, network traffic, etc.) from AWS services like EC2, RDS, Lambda, ECS, etc.
  * You can create custom metrics for your applications.

* Log Monitoring (CloudWatch Logs):

    * Collect, view, and analyze logs from EC2 instances, Lambda functions, API Gateway, and more.
    * Enables centralized logging for debugging and auditing.

* Alarms:

    * Set up alarms to trigger actions when metrics go beyond defined thresholds.
    * Alarms can send notifications (via SNS), trigger Auto Scaling, or invoke Lambda functions.

* Dashboards:

    * Customizable visual dashboards to display metrics and logs for quick monitoring.

🔹 1. Log Group
A Log Group is like a folder or category that holds related logs together.

* For example:

    * /springboot/prod
    * /application/staging
    * /myapp/database-logs

🔹 2. Log Stream
A Log Stream is like a file inside a log group. It holds the actual sequence of log events from a specific source (e.g., a Docker container or EC2 instance).

Each log stream belongs to one log group

* Examples:
  * springboot-app-container


# Volumes

* docker volume ls - Displays all the available volume
* docker volume inspect volume_name - Displays mount point