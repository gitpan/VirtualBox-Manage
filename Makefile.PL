use inc::Module::Install;

# Define metadata
name            'VirtualBox-Manage';
all_from        'lib/VirtualBox/Manage.pm';

# Specific dependencies
requires        'Moose'                         => '0.59';
requires        'Moose::Autobox'                => '0.09';
requires        'Method::Signatures'            => '20081028';
requires        'MooseX::Method::Signatures'    => '0.06';
requires        'MooseX::Declare'               => '0.03';
requires        'XML::LibXML'                   => '1.66';
test_requires   'Test::More'  => '0.42';

WriteAll;
