require 'spec_helper'


describe 'baseline' do
  let(:facts) do
    {
        fqdn: 'service.test.example.com',
        myfqdn: 'service.test.example.com',
        mydomain: 'example.com',
        inventory: {
            'service.test.example.com' => {
                'zone' => 'test',
                'domain' => 'example.com',
            },
        },
        path: '/usr/bin:/opt/puppetlabs/bin',
        lsbdistcodename: 'stretch',
        osfamily: "Debian",
        operatingsystem: "Debian",
        architecture: "amd64",
        os: {
            'architecture' => "amd64",
            'distro' => {
                'codename' => "stretch",
                'description' => "Debian GNU/Linux 9.11 (stretch)",
                'id' => "Debian",
                'release' => {
                    'full' => "9.11",
                    'major' => "9",
                    'minor' => "11"
                }
            },
            'family' => "Debian",
            'hardware' => "x86_64",
            'name' => "Debian",
            'release' => {
                'full' => "9.11",
                'major' => "9",
                'minor' => "11"
            },
            'selinux' => {
                'enabled' => false
            }
        }
    }
  end

  context 'on a test server' do
    it { is_expected.to compile }
    it { should contain_class('baseline') }
    it { should contain_class('baseline::mailserver')}
    it { should contain_class('postfix') }
    it { should_not contain_class('baseline::mailhog')}
    it { should contain_class('ssh') }
  end

end
