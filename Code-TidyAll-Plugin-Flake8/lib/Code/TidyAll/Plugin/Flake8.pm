package Code::TidyAll::Plugin::Flake8;

use Moo;
use String::ShellQuote qw/ shell_quote /;

use vars qw/ $_check /;

BEGIN
{
    my $code = <<'EOF';
from flake8.main import application

def _py_check(fn):
    app = application.Application()
    app.run([fn])
    return ((app.result_count > 0) or app.catastrophic_failure)
EOF
    ## no critic
    if ( ( eval "use Inline Python => \$code" ) and !$@ )
    {
        ## use critic
        $_check = sub { return _py_check(shift); };
    }
    else
    {
        $_check = sub {
            my $cmd = shell_quote( 'flake8', shift );
            return scalar `$cmd`;
        };
    }
}
extends 'Code::TidyAll::Plugin';

sub validate_file
{
    my ( $self, $fn ) = @_;
    if ( $_check->($fn) )
    {
        die 'not valid';
    }
    return;
}

1;

__END__

=head1 NAME

Code::TidyAll::Plugin::Flake8 - run flake8 using Code::TidyAll

=head1 SYNOPSIS

In your C<.tidyallrc>:

    [Flake8]
    select = **/*.py

=head1 DESCRIPTION

This speeds up the flake8 python tool ( L<http://flake8.pycqa.org/en/latest/>
) checking by caching results using L<Code::TidyAll> .

It was originally written for use by PySolFC
( L<http://pysolfc.sourceforge.net/> ), an open suite of card solitaire
games.

=cut
