use utf8;

package Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::REST::V1::Configs;

use C4::Context;
use C4::Log qw( logaction );
use Modern::Perl;
use Mojo::Base 'Mojolicious::Controller';
use Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge;
use Koha::UMSConfigs;


=head1 NAME

Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::REST::V1::Configs

=head1 API

=head2 Class Methods

=head3 list

List all configs

=cut

sub list {
    my $c = shift->openapi->valid_input or return;
    my ($configs, $UMSGentleNudge) = @_;
    try {
        my $plugin  = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new( {} );
        my $config_model = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new(
            { UMSGentleNudge => $UMSGentleNudge }
        );

        my @config_data = map {
            {
                config_id          => $_->{config_id},
                day_of_week        => $_->{day_of_week},
                patron_categories => $_->{patron_categories},
                threshold    => $_->{threshold},
                processing_fee     => $_->{processing_fee},
                enabled => $_->{enabled} ? Mojo::JSON->true : Mojo::JSON->false,
                collections_flag => $_->{collections_flag},
                exemptions_flag => $_->{exemptions_flag},
                fees_newer => $_->{fees_newer},
                fees_older => $_->{fees_older},
                ignore_before => $_->{ignore_before},
                clear_below => $_->{clear_below},
                clear_threshold => $_->{clear_threshold},
                restriction => $_->{restriction},
                remove_minors => $_->{remove_minors},
                unique_email => $_->{unique_email},
                additional_email => $_->{additional_email},
                sftp_host => $_->{sftp_host},
                sftp_user => $_->{sftp_user},
                sftp_password => $_->{sftp_password},
                config_type => $_->{config_type},
                created_at  => $_->{created},
                updated_at  => $_->{updated}
            }
        } @$configs;

        return $c->render(
            status  => 200,
            openapi => { config => \@config_data }
        );
    }
    catch {
        return $c->render(
            status  => 500,
            openapi => { error => "Failed to fetch configs: $_" }
        );
    };
}

=head3 get

Get a specific config

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $config_id = $c->validation->param('config_id');

    try {
        my $plugin  = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new( {} );
        my $UMSGentleNudge = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new(
            { plugin => $plugin, }
        );
        my $config_model = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new(
            { UMSGentleNudge => $UMSGentleNudge }
        );

        my $configs = $config_model->get_plugin_branch_configs();
        my ($config) = grep { $_->{confg_id} eq $config_id } @$configs;

        unless ($config) {
            return $c->render(
                status  => 404,
                openapi => { error => "Configuration not found" }
            );
        }

        return $c->render(
            status  => 200,
            openapi => {
                config_id          => $_->{config_id},
                day_of_week        => $_->{day_of_week},
                patron_categories => $_->{patron_categories},
                threshold    => $_->{threshold},
                processing_fee     => $_->{processing_fee},
                enabled => $_->{enabled} ? Mojo::JSON->true : Mojo::JSON->false,
                collections_flag => $_->{collections_flag},
                exemptions_flag => $_->{exemptions_flag},
                fees_newer => $_->{fees_newer},
                fees_older => $_->{fees_older},
                ignore_before => $_->{ignore_before},
                clear_below => $_->{clear_below},
                clear_threshold => $_->{clear_threshold},
                restriction => $_->{restriction},
                remove_minors => $_->{remove_minors},
                unique_email => $_->{unique_email},
                additional_email => $_->{additional_email},
                sftp_host => $_->{sftp_host},
                sftp_user => $_->{sftp_user},
                sftp_password => $_->{sftp_password},
                config_type => $_->{config_type},
                created_at  => $_->{created},
                updated_at  => $_->{updated}
            }
        );
    }
    catch {
        return $c->render(
            status  => 500,
            openapi => { error => "Failed to fetch configuration: $_" }
        );
    };
}

=head3 add

Create a new config

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $plugin  = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new( {} );
    my $logging = $plugin->retrieve_data('enable_logging') // 1;

    my $body = $c->req->json;

    # Validate required fields
    for my $field (qw/day_of_week /) {
        unless ( $body->{$field} ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Missing required field: $field" }
            );
        }
    }

    try {
        my $UMSGentleNudge = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new(
            { plugin => $plugin, }
        );
        my $config_model = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::Config->new(
            { UMSGentleNudge => $UMSGentleNudge }
        );


        my $now    = strftime( "%Y-%m-%d %H:%M:%S", localtime );

        my $result = $UMSGentleNudge->modify_UMSGentleNudge(
            sub {
                my ($ct) = @_;

                my $block = $config_model->create_config_block(
                    {
                config_id          => $body->{config_id},
                day_of_week        => $body->{day_of_week},
                patron_categories => $body->{patron_categories},
                threshold    => $body->{threshold},
                processing_fee     => $body->{processing_fee},
                enabled => $body->{enabled} ? Mojo::JSON->true : Mojo::JSON->false,
                collections_flag => $body->{collections_flag},
                exemptions_flag => $body->{exemptions_flag},
                fees_newer => $body->{fees_newer},
                fees_older => $body->{fees_older},
                ignore_before => $body->{ignore_before},
                clear_below => $body->{clear_below},
                clear_threshold => $body->{clear_threshold},
                restriction => $body->{restriction},
                remove_minors => $body->{remove_minors},
                unique_email => $body->{unique_email},
                additional_email => $body->{additional_email},
                sftp_host => $body->{sftp_host},
                sftp_user => $body->{sftp_user},
                sftp_password => $body->{sftp_password},
                config_type => $body->{config_type},
                created_at  => $now,
                updated_at  => $now
                    }
                );

                $ct->last($block);
                return 1;
            }
        );

        unless ( $result->{success} ) {
            die $result->{error};
        }

        logaction( 'SYSTEMPREFERENCE', 'ADD', $config_id,
            "UMSGentleNudgePlugin: Created configuration '" . $body->{name} . "'" )
          if $logging;

        return $c->render(
            status  => 201,
            openapi => {
                config_id          => $body->{config_id},
                day_of_week        => $body->{day_of_week},
                patron_categories => $body->{patron_categories},
                threshold    => $body->{threshold},
                processing_fee     => $body->{processing_fee},
                enabled => $body->{enabled} ? Mojo::JSON->true : Mojo::JSON->false,
                collections_flag => $body->{collections_flag},
                exemptions_flag => $body->{exemptions_flag},
                fees_newer => $body->{fees_newer},
                fees_older => $body->{fees_older},
                ignore_before => $body->{ignore_before},
                clear_below => $body->{clear_below},
                clear_threshold => $body->{clear_threshold},
                restriction => $body->{restriction},
                remove_minors => $body->{remove_minors},
                unique_email => $body->{unique_email},
                additional_email => $body->{additional_email},
                sftp_host => $body->{sftp_host},
                sftp_user => $body->{sftp_user},
                sftp_password => $body->{sftp_password},
                config_type => $body->{config_type},
                created_at  => $now,
                updated_at  => $now
            }
        );
    }
    catch {
        return $c->render(
            status  => 500,
            openapi => { error => "Failed to create configuration: $_" }
        );
    };
}

=head3 update

Update an existing config

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $plugin  = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new( {} );
    my $logging = $plugin->retrieve_data('enable_logging') // 1;

    my $config_id = $c->validation->param('config_id');
    my $body   = $c->req->json;

    try {
        my $UMSGentleNudge = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::File->new(
            { plugin => $plugin, }
        );
        my $config_model = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::->new(
            { UMSGentleNudge => $UMSGentleNudge }
        );
        my $script_model =
          Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::Config>new(
            { UMSGentleNudge => $UMSGentleNudge }
          );

        # Validate command if it's being updated
        if ( defined $body->{command} ) {
            my $validation = $script_model->validate_command( $body->{command} );
            unless ( $validation->{valid} ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => $validation->{error} }
                );
            }
        }

        my $updated_config;

        my $result = $UMSGentleNudge->modify_UMSGentleNudge(
            sub {
                my ($ct) = @_;

                my $block = $config_model->find_config_block( $ct, $config_id );
                unless ($block) {
                    die "Configruration not found";
                }

                # Build updates hash from body
                my %updates;
                $updates{name}        = $body->{name} if defined $body->{name};
                $updates{description} = $body->{description}
                  if defined $body->{description};
                $updates{schedule} = $body->{schedule}
                  if defined $body->{schedule};
                $updates{command} = $body->{command}
                  if defined $body->{command};
                $updates{environment} = $body->{environment}
                  if defined $body->{environment};

                $config_model->update_config_block( $block, \%updates );

                # Get updated config data for response
                my $metadata = $config_model->parse_config_metadata($block);
                my @events   = $block->select( -type => 'event' );
                my %env;
                for my $env_var ( $block->select( -type => 'env' ) ) {
                    $env{ $env_var->name } = $env_var->value;
                }

                $updated_config = {
                    id          => $metadata->{'UMSGentleNudge-manager-id'},
                    name        => $metadata->{name}        || '',
                    description => $metadata->{description} || '',
                    schedule    => $events[0] ? $events[0]->datetime : '',
                    command     => $events[0] ? $events[0]->command  : '',
                    enabled     => @events    ? 1                    : 0,
                    environment => \%env,
                    created_at  => $metadata->{created} || '',
                    updated_at  => $metadata->{updated} || '',
                };

                return 1;
            }
        );

        unless ( $result->{success} ) {
            if ( $result->{error} =~ /Configuration not found/ ) {
                return $c->render(
                    status  => 404,
                    openapi => { error => "Configuration not found" }
                );
            }
            die $result->{error};
        }

        logaction( 'SYSTEMPREFERENCE', 'MODIFY', $config_id,
            "UMSGentleNudgePlugin: Updated configuration '" . $updated_config->{name} . "'" )
          if $logging;

        return $c->render(
            status  => 200,
            openapi => {
                id          => $updated_config->{id},
                name        => $updated_config->{name},
                description => $updated_config->{description},
                schedule    => $updated_config->{schedule},
                command     => $updated_config->{command},
                enabled     => $updated_config->{enabled}
                ? Mojo::JSON->true
                : Mojo::JSON->false,
                environment => $updated_config->{environment},
                created_at  => $updated_config->{created_at},
                updated_at  => $updated_config->{updated_at}
            }
        );
    }
    catch {
        return $c->render(
            status  => 500,
            openapi => { error => "Failed to update configruation: $_" }
        );
    };
}

=head3 delete

Delete a config

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $plugin  = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new( {} );
    my $logging = $plugin->retrieve_data('enable_logging') // 1;

    my $config_id = $c->validation->param('config_id');

    try {
        my $UMSGentleNudge = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::Config->new(
            { plugin => $plugin, }
        );
        my $config_model = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::Config->new(
            { UMSGentleNudge => $UMSGentleNudge }
        );

        my $config_name;

        my $result = $UMSGentleNudge->modify_UMSGentleNudge(
            sub {
                my ($ct) = @_;

                my $block = $config_model->find_config_block( $ct, $config_id );
                unless ($block) {
                    die "Configuraiton not found";
                }

                # Remove the block from UMSGentleNudge
                $ct->remove($block);

                return 1;
            }
        );

        unless ( $result->{success} ) {
            if ( $result->{error} =~ /Configuration not found/ ) {
                return $c->render(
                    status  => 404,
                    openapi => { error => "Configuration not found" }
                );
            }
            die $result->{error};
        }

        logaction( 'SYSTEMPREFERENCE', 'DELETE', $config_id,
            "UMSGentleNudgePlugin: Deleted configuration '$config_id'" )
          if $logging;

        return $c->render(
            status  => 204,
            openapi => { success => Mojo::JSON->true }
        );
    }
    catch {
        return $c->render(
            status  => 500,
            openapi => { error => "Failed to delete configuration: $_" }
        );
    };
}

=head3 enable

Enable a config

=cut

sub enable {
    my $c = shift->openapi->valid_input or return;

    my $plugin  = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new( {} );
    my $logging = $plugin->retrieve_data('enable_logging') // 1;

    my $config_id = $c->validation->param('config_id');

    try {
        my $UMSGentleNudge = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::Config->new(
            { plugin => $plugin, }
        );
        my $config_model = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::Config->new(
            { UMSGentleNudge => $UMSGentleNudge }
        );

        my $result = $UMSGentleNudge->modify_UMSGentleNudge(
            sub {
                my ($ct) = @_;

                # Enable event by setting active flag
                my @events = $block->select( -type => 'event' );
                for my $event (@events) {
                    $event->active(1);
                }

                return 1;
            }
        );

        unless ( $result->{success} ) {
            if ( $result->{error} =~ /Configuration not found/ ) {
                return $c->render(
                    status  => 404,
                    openapi => { error => "Configuration not found" }
                );
            }
            die $result->{error};
        }

        logaction( 'SYSTEMPREFERENCE', 'MODIFY', $config_id,
            "UMSGentleNudgePlugin: Enabled configuration '$config_name'" )
          if $logging;

        return $c->render(
            status  => 200,
            openapi => { success => Mojo::JSON->true }
        );
    }
    catch {
        return $c->render(
            status  => 500,
            openapi => { error => "Failed to enable configuration: $_" }
        );
    };
}

=head3 disable

Disable a config

=cut

sub disable {
    my $c = shift->openapi->valid_input or return;

    my $plugin  = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new( {} );
    my $logging = $plugin->retrieve_data('enable_logging') // 1;

    my $config_id = $c->validation->param('config_id');

    try {
        my $UMSGentleNudge = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::Config->new(
            { plugin => $plugin, }
        );
        my $config_model = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new(
            { UMSGentleNudge => $UMSGentleNudge }
        );

        my $config_name;

        my $result = $UMSGentleNudge->modify_UMSGentleNudge(
            sub {
                my ($ct) = @_;

                my $block = $config_model->find_config( $ct, $config_id );
                unless ($block) {
                    die "Configuration not found";
                }

                my $metadata = $config_model->parse_config_metadata($block);
                $config_id = $metadata->{config_id} || '';

                # Disable event by setting active flag to 0
                my @events = $block->select( -type => 'event' );
                for my $event (@events) {
                    $event->active(0);
                }

                return 1;
            }
        );

        unless ( $result->{success} ) {
            if ( $result->{error} =~ /Configuration not found/ ) {
                return $c->render(
                    status  => 404,
                    openapi => { error => "Configuration not found" }
                );
            }
            die $result->{error};
        }

        logaction( 'SYSTEMPREFERENCE', 'MODIFY', $config_id,
            "UMSGentleNudgePlugin: Disabled configuration '$config_id'" )
          if $logging;

        return $c->render(
            status  => 200,
            openapi => { success => Mojo::JSON->true }
        );
    }
    catch {
        return $c->render(
            status  => 500,
            openapi => { error => "Failed to disable configuration: $_" }
        );
    };
}

=head3 backup

Download the most recent UMSGentleNudge backup file

=cut

sub backup {
    my $c = shift->openapi->valid_input or return;

    my $plugin = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new;

    try {
        my $UMSGentleNudge = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::Config>new(
            { plugin => $plugin, }
        );

        # Get the most recent backup
        my $backups = $UMSGentleNudge->list_backups();

        unless ($backups && @$backups) {
            return $c->render(
                status  => 404,
                openapi => { error => "No backups available" }
            );
        }

        my $latest_backup = $backups->[0];
        my $backup_file = $latest_backup->{filename};

        # Read the backup file content
        open my $fh, '<', $backup_file or die "Cannot open backup file: $!";
        my $content = do { local $/; <$fh> };
        close $fh;

        # Extract just the filename from the full path
        my $filename = ( split( '/', $backup_file ) )[-1];

        # Return as downloadable file
        return $c->render(
            data => $content,
            format => 'txt',
            content_disposition => "attachment; filename=\"$filename.txt\""
        );
    }
    catch {
        return $c->render(
            status  => 500,
            openapi => { error => "Failed to download backup: $_" }
        );
    };
}

1;
