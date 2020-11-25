# frozen_string_literal: true

if ['bsd'].include?(os[:family])
  package = 'py37-certbot'
  group   = 'wheel'
  certbot = '/usr/local/bin/certbot'
elsif ['debian', 'ubuntu'].include?(os[:family])
  package = 'certbot'
  group   = 'root'
  certbot = '/usr/bin/certbot'
end

control 'letsencrypt-base' do
  title 'Letsencrypt base is working'
  desc 'Letsencrypt data'
  impact 1.0

  describe package(package) do
    it { should be_installed }
  end

  describe file(certbot) do
    it { should be_file }
    it { should be_executable }
    it { should be_owned_by 'root' }
    it { should be_grouped_into group }
  end

  #('1 0 1 */2 *
  describe crontab('root').commands('/etc/letsencrypt/saltstack/cronjobs/something.test.com.sh > /dev/null 2>&1') do
    its('minutes') { should cmp '1' }
    its('hours') { should cmp '0' }
    its('days') { should cmp '1' }
  end
end

