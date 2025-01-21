$latex = 'latex -interaction=nonstopmode -shell-escape';
$pdflatex = 'pdflatex -interaction=nonstopmode -shell-escape';

# Create the build/tikz directory if it doesn't exist
sub BEGIN {
    system("mkdir -p build/tikz"); 
}