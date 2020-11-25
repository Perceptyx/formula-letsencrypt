# frozen_string_literal: true

if os[:family] == 'freebsd'
  pip_package = "py37-pip"
  group       = "wheel"
elsif ['debian', 'ubuntu'].include?(os[:family])
  pip_package = "python3-pip"
  group      = "root"
end

control 'letsencrypt-base' do
  title 'Letsencrypt base is working'
  desc 'Letsencrypt data'
  impact 1.0

  describe package(pip_package) do
    it { should be_installed }
  end

  describe file('/opt/letsencrypt') do
    its('type') { should cmp 'directory' }
    its('mode') { should cmp '0755' }
    its('owner') { should cmp 'root' }
    its('group') { should cmp group }
  end

  describe file('/opt/letsencrypt/bin/letsencrypt') do
    its('type') { should cmp 'file' }
    its('mode') { should cmp '0755' }
    its('owner') { should cmp 'root' }
    its('group') { should cmp group }
  end

  describe crontab('root').commands('/etc/letsencrypt/saltstack/cronjobs/something.test.com.sh > /dev/null 2>&1') do
    its('minutes') { should cmp '1' }
    its('hours') { should cmp '0' }
    its('days') { should cmp '1' }
  end

end

control 'pip-letsencrypt-freebsd' do
  title 'check pip packages'
  only_if('freebsd host') { os.bsd? }

  describe pip('virtualenv', '/usr/local/bin/pip-3.7') do
    it { should be_installed }
  end

  describe pip('setuptools', '/opt/letsencrypt/bin/pip3') do
    it { should be_installed }
  end

end

control 'pip-letsencrypt-debian' do
  title 'check pip packages'
  only_if('ubuntu host') { os.debian? }

  describe pip('virtualenv', '/usr/bin/pip3') do
    it { should be_installed }
  end

  describe pip('setuptools', '/opt/letsencrypt/bin/pip3') do
    it { should be_installed }
  end
end

