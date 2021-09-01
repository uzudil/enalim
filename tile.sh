# brew install imagemagick

if [ -z $1 -o -z $2 ]; then
	echo "usage: ./tile.sh dir outfile"
	echo "\tdir - the directory containing the separate images"
	echo "\toutdir - the path to the resulting tiled file"
	exit 1
fi
montage ./creatures/$1/*.png -geometry +0+0 -tile x1 -background transparent creatures/$2
