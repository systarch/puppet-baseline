require 'spec_helper'


describe 'baseline' do
  let(:facts) do
    {
        fqdn: 'unconfigured.example.com',
        myfqdn: 'unconfigured.example.com',
        mydomain: 'example.com',
        inventory: {
            'unconfigured.example.com' => {
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
  context 'on an unconfigured production server' do
    it { is_expected.not_to compile }
    it { is_expected.to raise_error(Puppet::Error, /Refusing to install mailhog in production/) }
  end

end
