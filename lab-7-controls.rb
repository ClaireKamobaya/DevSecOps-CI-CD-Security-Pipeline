title 'Lab 7 Compliance Controls'

control "check-instance-exists-started" do
    impact 0.3
    title "Check Instance Status"
    desc "Verify that our EC2 instance exists and is running"
  
    describe aws_ec2_instance(name: 'IT351-ProjectInstance') do
        it { should exist }
      end

    describe aws_ec2_instance(name: 'IT351-ProjectInstance') do
        it { should be_running }
      end
  end

control "check-instance-ami" do
    impact 0.3
    title "Check Instance AMI"
    desc "Verify that our EC2 instance AMI is the latest supported release of AmazonLinux 2"
  
    describe aws_ec2_instance(name: 'IT351-ProjectInstance') do
        its('image_id') { should eq 'ami-06124b567f8becfbd' }
      end
  end

  
control "check-lab-7-tags" do
    impact 0.3
    title "Check GitLab Runner Tags"
    desc "Check for the soon-to-be-required Lab 7 tag on our EC2 instance"
  
    describe aws_ec2_instance(name: 'IT351-ProjectInstance') do
        its('tags') { should include(key: 'Lab7', value: 'completed') }
      end
  end