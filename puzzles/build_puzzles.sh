set -eu
rm -r build
mkdir -p build
for dir in strace
do
    for file in $(find $dir -name '*.c')
    do
        dir="build/$(dirname $file)"
        mkdir -p "$dir"
        filename=$(basename $file)
        output=${filename/.c/}
        gcc -o "$dir/$output" "$file"
    done
done
