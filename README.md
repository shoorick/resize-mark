resize-mark
===========

Make small pictures from big ones

Description
-----------

Make small pictures from big ones.

Usage
-----

    resize-mark.pl
        [ --color=text_color ]
        [ --gap=gap_between_text_chunks ]
        [ --name=author_name ]
        [ --prefix=small_pictures_filenames_prefix ]
        [ --quality=JPEG_quality ]
        [ --site=site_of_author ]
        [ --size=size_of_small_pictures ]
        files

### Arguments

`color` – valid [ImageMagick](https://imagemagick.org/) color: english word (`white`, `black` etc)
or digital value (`#RGB`, `#RGBA`, `#RRGGBB`, `#RRGGBBAA`).
Default value is `#fff2` (⅞ transparent white).

`gap` – gap between text chunks in pixels. Default value is `10`.

`name` – name of author, default value is name of current user.

`prefix` – small pictures filenames prefix, default value is `small.`

`quality` – JPEG quality — integer. Recommended value is `80`.

Author
------

Alexander Sapozhnikov
http://shoorick.ru/
<shoorick@cpan.org>

License
-------

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.
