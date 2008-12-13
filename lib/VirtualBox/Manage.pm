use MooseX::Declare;

class VirtualBox::Manage {
    our $VERSION = '0.0.0';
    use Carp;
    use XML::LibXML;
    use Moose::Autobox;

    use VirtualBox::Machine;

    has 'config' => (
        isa => 'Str',
        is => 'ro',
    );

    has '_parser' => (
        isa => 'XML::LibXML',
        is => 'rw',
    );

    has '_document' => (
        isa => 'XML::LibXML::Document',
        is => 'rw',
    );

    has '_xpath' => (
        isa => 'XML::LibXML::XPathContext',
        is => 'rw',
    );

    has 'machines' => (
        isa => 'HashRef',
        is => 'rw',
        default => sub { { } },
    );

    has 'prefix' => (
        isa => 'Str',
        is => 'ro',
    );

    has '_full_path' => (
        isa => 'Str',
        is => 'rw',
    );

    method read_config() {
        if(!$self->_full_path) {
            my $full_path = $self->prefix . "VBoxManage";
            croak "$full_path does not exist" unless -e $full_path;
            croak "$full_path is not a normal file" unless -f _;
            croak "$full_path is not executable" unless -x _;
            $self->_full_path($full_path);
        }
        $self->_parser(XML::LibXML->new);
        $self->_document($self->_parser->parse_file($self->config));
        $self->_xpath(
            XML::LibXML::XPathContext->new($self->_document->documentElement)
        );
        $self->_xpath->registerNs('vbox',
            'http://www.innotek.de/VirtualBox-settings'
        );
        my $path = '//vbox:MachineEntry';
        for my $node ($self->_xpath->findnodes($path)) {
            my $attrs = $node->attributes;
            my $uuid = $attrs->getNamedItem('uuid')->value;
            $uuid =~ s/{([^}]+)}/$1/;
            my $file = $attrs->getNamedItem('src')->value;
            (my $name = $file) =~ s{[\w/]+/([^.]+)\.xml$}{$1};
            $self->machines->put($name, 
                VirtualBox::Machine->new(
                    uuid => $uuid,
                    config_file => $file,
                    name => $name,
                    _vbox_path => $self->_full_path
                )
            );
        }
    }
}

__END__

=head1 NAME

VirtualBox::Manage -- an API for managing VirtualBox VMs

=head1 VERSION

This documentation refers to VirtualBox::Manage version 0.0.0.

=head1 SYNOPSIS

    use VirtualBox::Manage;
    use Moose::Autobox;
    my $vb = VirtualBox::Manage->new(config => 'VirtualBox.xml', prefix => '/usr/local/bin');
    for my $vm ( $vb->machines->keys ) {
        print $vm->name, "\n";
    }

=head1 DESCRIPTION

VirtualBox::Manage provides a Perl interface to the VirtualBox virtualization
software. Currently very little is supported, but this will be changing in the
future. The aim is to provide a full programmatic interface to the VirtualBox
commandline tools for the purpose of automating virtual machine management.

=head1 ATTRIBUTES

=head2 config

Read-only attribute denoting the XML configuration file for VirtualBox.

=head2 machines

Hashref representing a collection of machines. Keys are machine names, values
are L<VirtualBox::Machine> objects.

=head2 prefix

The prefix under which VirtualBox is installed, with the trailing directory
separator.

=head1 METHODS

=head2 read_config

Reads the configuration file passed into the constructor and instantiates the
machine objects listed therein.

=head1 DEVELOPMENT

If interested in tracking the development of this package, check out its
Gitorious page: http://gitorious.org/projects/virtualbox_manage

=head1 AUTHOR

Christopher Nehren <apeiron@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008 Christopher Nehren (<apeiron@cpan.org>). All rights
reserved.
 
This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic> and L<perlgpl>.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

