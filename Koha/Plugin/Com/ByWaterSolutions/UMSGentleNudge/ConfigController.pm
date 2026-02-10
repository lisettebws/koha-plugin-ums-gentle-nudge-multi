package Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::ConfigController;
use C4::Context;
use C4::Log qw( logaction );
use Modern::Perl;
use Mojo::Base 'Mojolicious::Controller';
use Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge;
use Koha::UMSConfigs;
use Data::Dumper qw( Dumper );


=head1 NAME

 Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::ConfigController

=head1 API

=head2 Class Methods

=head3 list

List all configs

=cut

sub list {
my $c = shift->openapi->valid_input or return;

return try {
    return $c->render(
	    status  => 200,
        openapi => $c->objects->search( Koha::UMSConfigs->new ),
    );
}
catch {
    $c->unhandled_exception;
};
}

=head3 get

Get a specific config

=cut

sub get {
    my $c = shift->openapi->valid_input or return;
    my $config_id = $c->param('config_id');

    return try {
        my $config = Koha::UMSConfigs->find({ config_id => $config_id });
        return $c->render(
            status =>200,
            openapi => $config,
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Create a new config

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

warn (Dumper($c->req->json->{'additional_email'}));
    my $additional_email = $c->req->json->{'additional_email'};
    my $branch = $c->req->json->{'branch'};
    my $clear_below = $c->req->json->{'clear_below'};
    my $clear_threshold = $c->req->json->{'clear_threshold'};
    my $collections_flag = $c->req->json->{'collections_flag'};
    my $config_group = $c->req->json->{'config_group'};
    my $created_at = $c->req->json->{'created_at'};
    my $config_id = $c->req->json->{'config_id'};
    my $config_name = $c->req->json->{'config_name'};
    my $config_type = $c->req->json->{'config_type'};
    my $day_of_week = $c->req->json->{'day_of_week'};
    my $debit_type = $c->req->json->{'debit_type'};
    my $enabled = $c->req->json->{'enabled'};
    my $exemptions_flag = $c->req->json->{'exemptions_flag'};
    my $fees_newer = $c->req->json->{'fees_newer'};
    my $fees_older = $c->req->json->{'fees_older'};
    my $ignore_before = $c->req->json->{'ignore_before'};
    my $patron_categories = $c->req->json->{'day_of_week'};
    my $processing_fee = $c->req->json->{'processing_fee'};
    my $remove_minors = $c->req->json->{'remove_minors'};
    my $restriction = $c->req->json->{'restriction'};
    my $sftp_host = $c->req->json->{'sftp_host'};
    my $sftp_password = $c->req->json->{'sftp_password'};
    my $sftp_user = $c->req->json->{'sftp_user'};
    my $threshold = $c->req->json->{'threshold'};
    my $unique_email = $c->req->json->{'unique_email'};
    return try {
        my $config = Koha::UMSConfig->new({
            additional_email => $additional_email,
            branch    => $branch,
            clear_below => $clear_below,
            clear_threshold => $clear_threshold,
            collections_flag => $collections_flag,
            config_group => $config_group,
            config_id => $config_id,
            config_name => $config_name,
            config_type => $config_type,
            created_at  => $created_at,
            day_of_week => $day_of_week,
            debit_type => $debit_type,
            enabled => $enabled,
            exemptions_flag => $exemptions_flag,
            fees_newer => $fees_newer,
            fees_older => $fees_older,
            ignore_before => $ignore_before,
            patron_categories => $patron_categories,
            processing_fee => $processing_fee,
            remove_minors => $remove_minors,
            restriction => $restriction,
            sftp_host => $sftp_host,
            sftp_password => $sftp_password,
            sftp_user => $sftp_user,
            threshold => $threshold,
            unique_email => $unique_email
        });

        $config->store;

        return $c->render(
            status => 200,
            openapi => $config
        );
    }
    catch {
        $c->unhandled_exception($_);
    }
};
# =head3 update

# Update an existing config

# =cut

# sub _update_config {
#     my $c = shift->openapi->valid_input or return;

#     my $plugin  = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new( {} );
#     my $logging = $plugin->retrieve_data('enable_logging') // 1;

#     my $config_id = $c->param('config_id');
#     my $body   = $c->req->json;

#     try {
#         my $UMSGentleNudge = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::File->new(
#             { plugin => $plugin, }
#         );
#         my $config_model = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::->new(
#             { UMSGentleNudge => $UMSGentleNudge }
#         );

#         # Validate command if it's being updated
#         if ( defined $body->{command} ) {
#             my $validation = $config_model->validate_command( $body->{command} );
#             unless ( $validation->{valid} ) {
#                 return $c->render(
#                     status  => 400,
#                     openapi => { error => $validation->{error} }
#                 );
#             }
#         }

#         my $updated_config;

#         my $result = $UMSGentleNudge->modify_UMSGentleNudge(
#             sub {
#                 my ($ct) = @_;

#                 my $config = $config_model->find_config( $ct, $config_id );
#                 unless ($config) {
#                     die "Configruration not found";
#                 }

#                 # Build updates hash from body
#                 my %updates;
#                 $updates{name}        = $body->{name} if defined $body->{name};
#                 $updates{description} = $body->{description}
#                   if defined $body->{description};
#                 $updates{schedule} = $body->{schedule}
#                   if defined $body->{schedule};
#                 $updates{command} = $body->{command}
#                   if defined $body->{command};
#                 $updates{environment} = $body->{environment}
#                   if defined $body->{environment};




#                 return 1;
#             }
#         );

#         unless ( $result->{success} ) {
#             if ( $result->{error} =~ /Configuration not found/ ) {
#                 return $c->render(
#                     status  => 404,
#                     openapi => { error => "Configuration not found" }
#                 );
#             }
#             die $result->{error};
#         }

#         logaction( 'SYSTEMPREFERENCE', 'MODIFY', $config_id,
#             "UMSGentleNudgePlugin: Updated configuration '" . $updated_config->{name} . "'" )
#           if $logging;

#         return $c->render(
#             status  => 200,
#             openapi => {
#                 id          => $updated_config->{id},
#                 name        => $updated_config->{name},
#                 description => $updated_config->{description},
#                 schedule    => $updated_config->{schedule},
#                 command     => $updated_config->{command},
#                 enabled     => $updated_config->{enabled}
#                 ? Mojo::JSON->true
#                 : Mojo::JSON->false,
#                 environment => $updated_config->{environment},
#                 created_at  => $updated_config->{created_at},
#                 updated_at  => $updated_config->{updated_at}
#             }
#         );
#     }
#     catch {
#         return $c->render(
#             status  => 500,
#             openapi => { error => "Failed to update configruation: $_" }
#         );
#     };
# }

# =head3 delete

# Delete a config

# =cut

# sub delete {
#     my $c = shift->openapi->valid_input or return;



#     my $config_id = $c->param('config_id');

#     return try {
#         my $config = Koha::UMSConfigs->find({  config_id => $config_id });

#         $config->delete;

#         logaction( 'SYSTEMPREFERENCE', 'DELETE', $config_id,
#             "UMSGentleNudgePlugin: Deleted configuration '$config_id'" );

#         return $c->render(
#             status  => 204,
#             openapi => { success => Mojo::JSON->true }
#         );
#     }
#     catch {
#         return $c->render(
#             status  => 500,
#             openapi => { error => "Failed to delete configuration: $_" }
#         );
#     };
# }

# =head3 enable

# Enable a config

# =cut

# sub enable {
#     my $c = shift->openapi->valid_input or return;

#     my $plugin  = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new( {} );
#     my $logging = $plugin->retrieve_data('enable_logging') // 1;
#     my $config_name='';
#     my $config_id = $c->param('config_id');

#     try {
#         my $UMSGentleNudge = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::Config->new(
#             { plugin => $plugin, }
#         );
#         my $config_model = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::Config->new(
#             { UMSGentleNudge => $UMSGentleNudge }
#         );

#         my $result = $UMSGentleNudge->modify_UMSGentleNudge(
#             sub {
#                 my ($ct) = @_;

#                 return 1;
#             }
#         );

#         unless ( $result->{success} ) {
#             if ( $result->{error} =~ /Configuration not found/ ) {
#                 return $c->render(
#                     status  => 404,
#                     openapi => { error => "Configuration not found" }
#                 );
#             }
#             die $result->{error};
#         }

#         logaction( 'SYSTEMPREFERENCE', 'MODIFY', $config_id,
#             "UMSGentleNudgePlugin: Enabled configuration '$config_name'" )
#           if $logging;

#         return $c->render(
#             status  => 200,
#             openapi => { success => Mojo::JSON->true }
#         );
#     }
#     catch {
#         return $c->render(
#             status  => 500,
#             openapi => { error => "Failed to enable configuration: $_" }
#         );
#     };
# }

# =head3 disable

# Disable a config

# =cut

# sub disable {
#     my $c = shift->openapi->valid_input or return;

#     my $plugin  = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new( {} );
#     my $logging = $plugin->retrieve_data('enable_logging') // 1;

#     my $config_id = $c->param('config_id');

#     try {
#         my $UMSGentleNudge = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge::Config->new(
#             { plugin => $plugin, }
#         );
#         my $config_model = Koha::Plugin::Com::ByWaterSolutions::UMSGentleNudge->new(
#             { UMSGentleNudge => $UMSGentleNudge }
#         );

#         my $config_name;

#         my $result = $UMSGentleNudge->modify_UMSGentleNudge(
#             sub {
#                 my ($ct) = @_;

#                 my $config = $config_model->find_config( $ct, $config_id );
#                 unless ($config) {
#                     die "Configuration not found";
#                 }

#                 return 1;
#             }
#         );

#         unless ( $result->{success} ) {
#             if ( $result->{error} =~ /Configuration not found/ ) {
#                 return $c->render(
#                     status  => 404,
#                     openapi => { error => "Configuration not found" }
#                 );
#             }
#             die $result->{error};
#         }

#         logaction( 'SYSTEMPREFERENCE', 'MODIFY', $config_id,
#             "UMSGentleNudgePlugin: Disabled configuration '$config_id'" )
#           if $logging;

#         return $c->render(
#             status  => 200,
#             openapi => { success => Mojo::JSON->true }
#         );
#     }
#     catch {
#         return $c->render(
#             status  => 500,
#             openapi => { error => "Failed to disable configuration: $_" }
#         );
#     };
# }

1;
