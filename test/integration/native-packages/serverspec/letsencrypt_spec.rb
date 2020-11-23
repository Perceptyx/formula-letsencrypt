require 'serverspec'
set :backend, :exec

# Configure OS specific parameters
if os[:family] == 'freebsd'
  package = "py37-ceertbot"
  group       = "wheel"
  certbot = "/usr/local/bin/certbot"
elsif ['debian', 'ubuntu'].include?(os[:family])
  package = "certbot"
  group      = "root"
  certbot = "/usr/bin/certbot"
end

describe 'certbot' do
  it "certbot is installed" do
    expect(package(package)).to be_installed
  end
end

describe file(certbot) do
  it { should be_file }
  it { should be_executable }
  it { should be_owned_by 'root' }
  it { should be_grouped_into group }
end

describe cron do
  it { should have_entry('1 0 1 */2 * /etc/letsencrypt/saltstack/cronjobs/something.test.com.sh > /dev/null 2>&1').with_user('root') }
end
