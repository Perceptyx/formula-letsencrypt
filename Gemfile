source 'https://rubygems.org'

ruby '~>2.6.5'

gem "test-kitchen", '>=2.2.4'
gem "kitchen-salt"
gem 'kitchen-inspec'
gem "kitchen-vagrant"
gem "kitchen-docker"

# Install additiona gems with running in Github Actions context
group :actions, :optional => true do
  gem "ruby-libvirt"
  gem "vagrant-libvirt"
end
