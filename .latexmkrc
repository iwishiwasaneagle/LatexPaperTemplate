$latex = 'latex -interaction=nonstopmode -shell-escape';
$pdflatex = 'pdflatex -interaction=nonstopmode -shell-escape';

$out_dir = 'build';

$biber = 'biber --input-directory build --output-directory build %O %S';

$ENV{'TEXINPUTS'} = './fonts//:' . ($ENV{'TEXINPUTS'} // '');
$ENV{'TFMFONTS'} = './fonts//:' . ($ENV{'TFMFONTS'} // '');
$ENV{'T1FONTS'} = './fonts//:' . ($ENV{'T1FONTS'} // '');
$ENV{'ENCFONTS'} = './fonts//:' . ($ENV{'ENCFONTS'} // '');
$ENV{'TEXFONTMAPS'} = './fonts//:' . ($ENV{'TEXFONTMAPS'} // '');

# Create the build/tikz directory if it doesn't exist
sub BEGIN {
    system("mkdir -p build/tikz");
}