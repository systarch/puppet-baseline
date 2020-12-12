require 'spec_helper'


describe 'baseline' do
  let(:facts) do
    {
        fqdn: 'mailserver.example.com',
        myfqdn: 'mailserver.example.com',
        mydomain: 'example.com',
        inventory: {
            'mailserver.example.com' => {
                'zone' => 'prod',
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

  context 'on a configured production server' do
    it { is_expected.to compile }
    it { should contain_class('baseline') }
    it { should contain_class('baseline::mailserver')}
    it { should contain_class('postfix') }
    it { should contain_class('mailhog').with_ensure('absent') }
    it { should contain_class('ssh') }
  end

end
