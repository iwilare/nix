# A zero-thoughts guide to set up NixOS on WSL

wsl --install -d Debian
sudo apt update
sudo apt install wget git -y
code ~
explorer.exe .
# at this point: unzip in .ssh the files from https://github.com/iwilare/.ssh/archive/refs/heads/main.zip
sudo chown -R andrea .ssh
sudo chmod 600 ~/.ssh/id_ed25519
sudo apt install curl xz-utils -y
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon # https://nixos.org/download/
. /home/andrea/.nix-profile/etc/profile.d/nix.sh
git clone git@github.com:iwilare/nix .config/home-manager
sudo apt remove git
mkdir ~/.config/nix
echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
nix run nixpkgs#home-manager -- switch -b backup
echo '/home/andrea/.nix-profile/bin/fish' | sudo tee -a /etc/shells > /dev/null
chsh -s /home/andrea/.nix-profile/bin/fish
ln -s /mnt/c/Dropbox ~

