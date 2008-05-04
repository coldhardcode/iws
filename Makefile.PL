use inc::Module::Install;

name 'IWS';
all_from 'lib/IWS.pm';

requires 'Catalyst::Runtime' => '5.7011';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::I18N';

requires 'Catalyst::View::TT';
requires 'Catalyst::View::Email';

requires 'Catalyst::Model::DBIC::Schema';

requires 'Catalyst::Action::REST' => '0.60';
requires 'Catalyst::Action::RenderView';

requires 'Catalyst::Controller::REST::DBIC::Item';

requires 'JSON::DWIW';
requires 'JSON::Syck';
requires 'YAML::Syck' => '1.00';

requires 'DateTime';
requires 'DateTime::Format::RSS';
requires 'DateTime::Format::DateManip';
requires 'DateTime::Format::Pg';
requires 'DateTime::Format::MySQL';

requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
