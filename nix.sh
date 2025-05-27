# A simple guide to set up NixOS on WSL

wsl --install -d Debian
wsl
sudo apt update
sudo apt install wget -y
code .
# at this point: clone iwilare/ssh from vscode with auth
chmod 600 ~/.ssh/id_ed25519
sudo apt install curl xz-utils -y
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon # https://nixos.org/download/
. /home/andrea/.nix-profile/etc/profile.d/nix.sh
git clone git@github.com:iwilare/nix .config/home-manager
mkdir ~/.config/nix
echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
nix run nixpkgs#home-manager -- switch -b backup
echo '/home/andrea/.nix-profile/bin/fish' | sudo tee -a /etc/shells > /dev/null
chsh -s /home/andrea/.nix-profile/bin/fish
