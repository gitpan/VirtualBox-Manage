use MooseX::Declare;

class VirtualBox::Machine {
    use XML::LibXML;
    use Moose::Autobox;
    use Carp;
    our $VERSION = '0.0.0';

    has 'config_file' => (
        isa => 'Str',
        is => 'ro',
    );

    has 'uuid' => (
        isa => 'Str',
        is => 'ro',
    );

    has 'name' => (
        isa => 'Str',
        is => 'ro',
    );

    has '_vbox_path' => (
        isa => 'Str',
        is => 'ro',
    );

    method running() {
        my @full_cmd = ($self->_vbox_path, '-nologo', 'list', 'runningvms');
        open my $vboxfh, '-|', @full_cmd or croak "Running @full_cmd: $!";
        while(my $running_vm_uuid = <$vboxfh>) {
            chomp $running_vm_uuid;
            return 1 if $running_vm_uuid eq $self->uuid;
        }
        close $vboxfh or croak "Running @full_cmd: $!";
        return 0;
    }

    method start() {
        system $self->_vbox_path, '-nologo', 'startvm', $self->uuid
            and croak "Starting " . $self->name . ": $!";
    }

    method stop() {
        system $self->_vbox_path, '-nologo', 'controlvm', $self->uuid, 'poweroff'
            and croak "Stopping " . $self->name . ": $!";
    }
}

__END__

=head1 NAME

VirtualBox::Machine -- a VirtualBox virtual machine.

=head1 VERSION

This documentation refers to VirtualBox::Machine version 0.0.0.

=head1 SYNOPSIS

    use VirtualBox::Manage;
    use Moose::Autobox;
    my $vb = VirtualBox::Manage->new($args);
    my $freebsd = $vb->machines->at('FreebSD');
    $freebsd->start;
    print $freebsd->running ? "It's running!" : "An error slipped past!";
    $freebsd->stop;
    print $freebsd->running ? "An error slipped past!" : "It's not running.";

=head1 DESCRIPTION

This class represents a VirtualBox virtual machine. It provides an API for
programmatically managing VMs. This includes starting and stopping as well as
a collection of accessors for various attributes of the VM.

=head1 ATTRIBUTES

=head2 config_file

Read-only attribute denoting the XML configuration file for this machine.

=head2 uuid

Read-only attribute specifying the UUID for this machine.

=head2 name

Read-only attribute specifying user-friendly name for this machine.

=head1 METHODS

=head2 running

Returns a Boolean describing whether the machine is presently running.

=head2 start

Attempts to start the machine. Dies on failure.

=head2 stop

Attempts to stop the machine. Dies on failure.

=head1 AUTHOR

Christopher Nehren <<< <apeiron@cpan.org> >>>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008 Christopher Nehren (<<< <apeiron@cpan.org> >>>). All rights
reserved.
 
This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic> and L<perlgpl>.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

