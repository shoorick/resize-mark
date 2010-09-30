#!/usr/bin/perl -w
use strict;

=head1 DESCRIPTION

Make small pictures from big ones

=cut

use Image::ExifTool ':Public';
use Image::Magick;
use Getopt::Long;

# Constants
my %preferred_fonts = (
    'date' => [ qw/ DejaVuSans  DejaVu-Sans Bitstream-Vera-Sans BitstreamVeraSans Verdana / ], # Normal width
    'name' => [ qw/ DejaVuSansC DejaVu-Sans-Condensed Tahoma / ], # Narrow
    'site' => [ qw/ DejaVuSansB BitstreamVeraSansB VerdanaB TahomaB / ], # Bold
);

my $color  = '#fff2';
my $gap    = 10;
my $name   = (getpwuid $>)[6];
   $name   =~ s/,+$//;
my $prefix = 'small.';
my $site   = 'shoorick.ru';
my $size   = '50%';


# Override with options
GetOptions(
    'color:s'   => \$color,
    'gap:i'     => \$gap,
    'name:s'    => \$name,
    'prefix:s'  => \$prefix,
    'site:s'    => \$site,
    'size:s'    => \$size,
);


# Try to find suitable fonts
my $image = new Image::Magick;
my @available_fonts = $image->QueryFont();
my ( %seen, %fonts );
map { $seen{$_} = 1 } @available_fonts;

while ( my ( $scope, $list ) = each %preferred_fonts ) {
    foreach ( @$list ) {
        $fonts{ $scope } = $_
            and last
            if $seen{$_};
    } # foreach
} # while


foreach my $file ( @ARGV ) {
    my $info = ImageInfo($file, 'CreateDate');
    my $date = $$info{'CreateDate'};
    my $new_file_name = $file;
    $new_file_name =~ s{([^/]+)$}{$prefix$1};

    $date =~ s/^(\d{4}):(\d{2}):(\d{2}).*/$3.$2.$1/;

    my $p = new Image::Magick or next;
    $p->Read( $file );
    $p->AutoOrient;
    $p->Resize(
        'geometry'  => $size,
        'filter'    => 'Lanczos',
        'blur'      => 0.5,
    );
    my ( $width, $height ) = $p->Get('width', 'height');
    my ( $x, $y ) = ( $width - $gap, $height - $gap );

    $p->Set(
        'pointsize'     => 12,
        'fill'          => $color,
    );


    $p->Annotate(
        'font'          => $fonts{'name'},
        'text'          => $name,
        'rotate'        => -90,
        'x'             => $x,
        'y'             => $y,
    );

    $y -= (
        $p->QueryFontMetrics(
            'font'          => $fonts{'name'},
            'text'          => $name,
        )
    )[4] + $gap;

    $p->Annotate(
        'font'          => $fonts{'site'},
        'text'          => $site,
        'rotate'        => -90,
        'x'             => $x,
        'y'             => $y,
    );

    $y -= (
        $p->QueryFontMetrics(
            'font'          => $fonts{'site'},
            'text'          => $site,
        )
    )[4] + $gap;

    $p->Annotate(
        'font'          => $fonts{'date'},
        'text'          => $date,
        'rotate'        => -90,
        'x'             => $x,
        'y'             => $y,
    );

    $p->Sharpen(
        'radius' => 1,
        'sigma'  => 2,
    );
    $p->Write($new_file_name);

    print "$file - $date\n";

} # foreach


=head1 AUTHOR

Alexander Sapozhnikov
L<< http://shoorick.ru/ >>
shoorick@cpan.org

=cut
