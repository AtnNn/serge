package Serge::Engine::Plugin::segment;
use parent Serge::Plugin::Base::Callback;

use strict;

use Serge::Util qw(set_flag);

# See https://metacpan.org/source/CAPOEIRAB/Lingua-Sentence-1.100/share
# for the list of supproted language codes
my @segmenter_languages = qw(ca cs da de el en es fi fr hu is it lt lv nl pl pt ro ru sk sl sv);
my $default_langauge = 'en';

sub name {
    return 'Break paragraphs into individually translated sentences.';
}

sub init {
    my $self = shift;

    $self->SUPER::init(@_);

    $self->add({
        segment_source => \&segment_source
    });

    eval('use Lingua::Sentence;');
    die "ERROR: To use the segmenter plugin, please install Lingua::Sentence module (run 'cpan Lingua::Sentence')\n" if $@;

    my %supported;
    @supported{@segmenter_languages} = @segmenter_languages;

    my $source_lang = $self->{parent}->{source_language};
    if (!exists $supported{$source_lang}) {
        print "WARNING: Unsupported segmenter language: $source_lang. Resetting to a default: $default_langauge\n";
        $source_lang = $default_langauge;
    }
    $self->{splitter} = Lingua::Sentence->new($source_lang);
}

sub adjust_phases {
    my ($self, $phases) = @_;

    # always tie to 'segment_source' phase
    set_flag($phases, 'segment_source');
}

sub segment_source {
    my ($self, $phase, $source_string) = @_;

    return $self->{splitter}->split_array($source_string);
}

1;