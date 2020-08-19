#!/usr/bin/perl -w
use strict;

=encoding utf-8

=head1 DESCRIPTION

Make small pictures from big ones.

=head1 USAGE

    resize-mark.pl
        [ --color=text_color ]
        [ --gap=gap_between_text_chunks ]
        [ --name=author_name ]
        [ --prefix=small_pictures_filenames_prefix ]
        [ --quality=JPEG_quality ]
        [ --site=site_of_author ]
        [ --size=size_of_small_pictures ]
        files

=head2 Arguments

C<color> – valid ImageMagick color: english word (C<white>, C<black> etc)
or digital value (C<#RGB>, C<#RGBA>, C<#RRGGBB>, C<#RRGGBBAA>).
Default value is C<#fff2> (⅞ transparent white).

C<gap> – gap between text chunks in pixels. Default value is C<10>.

C<name> – name of author, default value is name of current user.

C<prefix> – small pictures filenames prefix, default value is C<small.>

C<quality> – JPEG quality — integer. Recommended value is C<80>.

=head1 AUTHOR

Alexander Sapozhnikov
L<< http://shoorick.ru/ >>
L<< E<lt>shoorick@cpan.orgE<gt> >>

=head1 LICENSE

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<< https://github.com/shoorick/resize-mark >>

=cut

use Image::ExifTool ':Public';
use Image::Magick;
use File::Path qw( make_path );
use Getopt::Long;
use Pod::Usage qw( pod2usage );

# Constants
my %preferred_fonts = (
     # Normal width
    'date' => [ qw(
        Open-Sans
        DejaVuSans  DejaVu-Sans DejaVu-Sans-Book
        Bitstream-Vera-Sans BitstreamVeraSans
        Verdana
     ) ],
    # Narrow
    'name' => [ qw(
        Open-Sans-Condenced-Light
        DejaVuSansC DejaVu-Sans-Condensed
        Tahoma
    ) ],
    # Narrow
    'site' => [ qw(
        Open-Sans-Bold
        DejaVuSansB DejaVu-Sans-Bold
        BitstreamVeraSansB
        VerdanaB
        TahomaB
    ) ], 
);

map { $_ = '' } my (
    $need_help, $need_manual, $verbose,
);

# Default values
my $color  = '#fff2';
my $gap    = 10;
my $name   = (getpwuid $>)[6];
   $name   =~ s/,+$//;
my $prefix = 'small.';
my $site   = 'shoorick.ru';
my $size   = '50%';
my $pointsize = 12;
my $quality;

# Override with options
GetOptions(
    'help|?'    => \$need_help,
    'manual'    => \$need_manual,
    'verbose'   => \$verbose,

    'color:s'   => \$color,
    'gap:i'     => \$gap,
    'name:s'    => \$name,
    'prefix:s'  => \$prefix,
    'site:s'    => \$site,
    'size:s'    => \$size,
    'pointsize:s'    => \$pointsize,
    'quality:i' => \$quality,
);

pod2usage('verbose' => 2)
    if $need_manual;
# print help message when required arguments are omitted
pod2usage(1)
    if $need_help
    || !@ARGV;

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

# Prefix contains slash and path doesn't exist
if ($prefix =~ m<^(.+)/[^/]*$> && ! -d $1) {
    print "Create directory $1...\n";
    make_path($1);
}

my @TAGS = qw( CreateDate DateTimeOriginal );

foreach my $file ( @ARGV ) {
    my $info = ImageInfo($file, @TAGS);
    my $date = $info->{ $TAGS[0] };
    my $new_file_name = $file;
    $new_file_name =~ s{([^/]+)$}{$prefix$1};

    $date =~ s/^(\d{4}):(\d{2}):(\d{2}).*/$3.$2.$1/;

    my $p = new Image::Magick or next;
    my $rv;
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
        'pointsize'     => $pointsize,
        'fill'          => $color,
    );


    $rv = $p->Annotate(
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

    $rv = $p->Annotate(
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

    $rv = $p->Annotate(
        'font'          => $fonts{'date'},
        'text'          => $date,
        'rotate'        => -90,
        'x'             => $x,
        'y'             => $y,
    );

    $rv = $p->AdaptiveSharpen(
        'radius' => 0.5,
        'sigma'  => 0.5,
    );

    $p->Set( 'quality' => int $quality )
        if $quality;
    $p->Write($new_file_name);

    print "$file - $date\n";

} # foreach

