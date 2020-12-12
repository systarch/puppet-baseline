require 'spec_helper'


describe 'baseline' do
  let(:facts) do
    {
        fqdn: 'sut.dev.example.com',
        myfqdn: 'sut.dev.example.com',
        mydomain: 'example.com',
        inventory: {
            'sut.dev.example.com' => {
                'zone' => 'dev',
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
  context 'with defaults for all parameters' do
    it { is_expected.to compile }
    it { should contain_class('baseline') }
    it { should contain_class('baseline::mailserver')}
    it { should contain_class('postfix') }
    it { should_not contain_class('baseline::mailserver::opendkim') }
    it { should_not contain_class('baseline::mailserver::sasl_authentication') }
    it { should_not contain_class('baseline::mailserver::spam_hardening') }
    it { should_not contain_class('baseline::mailserver::tls') }
    it { should contain_class('baseline::mailserver::mailhog')}
    it { should contain_class('mailhog') }
    it { should contain_class('ssh') }
  end
end
