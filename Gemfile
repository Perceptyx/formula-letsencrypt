source 'https://rubygems.org'

ruby '~>2.4.1'

gem "test-kitchen"
gem "kitchen-salt", :git => 'https://github.com/Perceptyx/kitchen-salt.git'
gem 'kitchen-inspec'
gem "kitchen-vagrant"
gem "kitchen-docker"

# Install additiona gems with running in Github Actions context
group :actions, :optional => true do
  gem "ruby-libvirt"
  gem "vagrant-libvirt"
end
