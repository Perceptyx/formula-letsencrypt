require 'serverspec'
set :backend, :exec

# Configure OS specific parameters
if os[:family] == 'freebsd'
  pip_package = "py27-pip"
  group       = "wheel"

  describe 'letsencrypt' do
    it "pip is installed" do
      expect(package(pip_package)).to be_installed
    end

    it "virtualenv is installed" do
      expect(command("pip-3.7 show virtualenv").exit_status).to eql(0)
    end

    it "setuptools is installed" do
      expect(command("pip-3.7 show setuptools").exit_status).to eql(0)
    end
  end
elsif ['debian', 'ubuntu'].include?(os[:family])
  pip_package = "python3-pip"
  group      = "root"

  describe 'letsencrypt' do
    it "pip is installed" do
      expect(package(pip_package)).to be_installed
    end

    it "virtualenv is installed" do
      expect(command("pip3 show virtualenv").exit_status).to eql(0)
    end

    it "setuptools is installed" do
      expect(command("pip3 show setuptools").exit_status).to eql(0)
    end
  end
end

  describe file('/opt/letsencrypt') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into group }
  end

  describe file('/opt/letsencrypt/bin/letsencrypt') do
    it { should be_file }
    it { should be_executable }
    it { should be_owned_by 'root' }
    it { should be_grouped_into group }
  end

  describe cron do
    it { should have_entry('1 0 1 */2 * /etc/letsencrypt/saltstack/cronjobs/something.test.com.sh > /dev/null 2>&1').with_user('root') }
  end
