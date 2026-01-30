# Ansible SSH Connection Timeout Resolution

## Error Encountered
```
TASK [Gathering Facts] *********************************************************
fatal: [ec2-xx-xxx-xxx-xxx.compute-1.amazonaws.com]: UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: ssh: connect to host ec2-xx-xxx-xxx-xxx.compute-1.amazonaws.com port 22: Connection timed out",
    "unreachable": true
}
```

## Root Cause Analysis
Ansible playbook failed to connect to newly provisioned EC2 instance due to security group misconfiguration. SSH port 22 was not accessible from the GitLab Runner's IP address.

## Diagnosis Steps
1. Verified EC2 instance was running and had public IP
2. Tested manual SSH connection from local machine - failed
3. Checked AWS Security Group inbound rules
4. Confirmed GitLab Runner security group ID
5. Identified missing ingress rule for SSH from Runner

## Resolution
Modified `main.tf` to add proper security group rules:
```hcl
resource "aws_security_group" "my_project_sg" {
    ingress {
        description = "SSH from GitLab Runner"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [data.aws_security_group.runner_sg.id]
    }
    
    ingress {
        description = "SSH from anywhere for Ansible"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
```

## Additional Fix
Added proper key permissions in `.gitlab-ci.yml`:
```yaml
before_script:
  - chmod 600 ClaireTestKeyPair.pem
```

## Verification
✓ Ansible successfully connected to EC2 instance
✓ Playbook execution completed without errors
✓ Configuration applied successfully
✓ Security group rules properly configured

## Lessons Learned
- Always verify security group rules before Ansible execution
- Implement proper wait conditions for EC2 instance initialization
- Test SSH connectivity before running configuration management
