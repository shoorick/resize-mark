#!/usr/bin/perl -w
use strict;

=head1 DESCRIPTION

Make small pictures from big ones

=head1 AUTHOR

Alexander Sapozhnikov
L<http://shoorick.ru/>

=cut

use Image::ExifTool ':Public';

foreach my $file ( @ARGV ) {
    my $info = ImageInfo($file, 'CreateDate');
    my $date = $$info{'CreateDate'};
    my $new_file_name = $file;
    $new_file_name =~ s{([^/]+)$}{small.$1};

    $date =~ s/^(\d{4}):(\d{2}):(\d{2}).*/$3.$2.$1/;

    my $font_name_normal = 'DejaVu-Sans-Condensed';
    my $font_name_bold   = 'DejaVu-Sans-Bold';
    my $uname = `uname -a`;
    if ( $uname =~ /Ubuntu/ ) {
        $font_name_normal = 'DejaVuSansC';
        $font_name_bold   = 'DejaVuSansB';
    }

    my $command = "convert $file "
        . '-auto-orient -gravity SouthWest -rotate 90 -resize 1500x1500 '
        . "-font $font_name_normal  -pointsize 12 "
        . '-fill "#fff2" -annotate +5+5 "Alexander Sapozhnikov" '
        . qq{-annotate +222+5 "$date" }
        . "-font $font_name_bold -annotate +140+5 shoorick.ru "
        . "-adaptive-sharpen 25 -rotate -90 $new_file_name";
    print "$file - $date\n", `$command`;
} # foreach
