# `godl`
`godl` is a tool for easily downloading the newest version of Go on Linux.

## Usage
Run `godl help` for usage instructions.

## Installation
### Manual
1. Clone this repository into a convinent location on your machine.
```
git clone git@github.com:JordanOcokoljic/godl.git ~/.local/godl
```

2. Create a symlink to the script in a location on your path
```
ln -s ~/.local/godl/godl.sh ~/.local/bin/godl
```

### Script
Run the installation script via `curl`.

```
curl -L https://raw.githubusercontent.com/JordanOcokoljic/godl/master/install.sh | bash
```