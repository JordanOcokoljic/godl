rm -r ~/.local/godl
rm ~/.local/bin/godl
git clone git@github.com:JordanOcokoljic/godl.git ~/.local/godl
mkdir -p ~/.local/bin
ln -s ~/.local/godl/godl.sh ~/.local/bin/godl