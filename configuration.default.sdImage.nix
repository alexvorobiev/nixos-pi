{ config, pkgs, lib, ... }:
{

  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>

    # For nixpkgs cache
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  sdImage.compressImage = true;
  

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
 
  # !!! Set to specific linux kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
  # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
  # On a Raspberry Pi 4 with 4 GB, you should either disable this parameter or increase to at least 64M if you want the USB ports to work.
  boot.kernelParams = ["cma=256M"];

  # Settings above are the bare minimum
  # All settings below are customized depending on your needs
  
  # !!! Adding a swap file is optional, but strongly recommended!
  swapDevices = [ { device = "/swapfile"; size = 1024; } ];
  
  # systemPackages
  environment.systemPackages = with pkgs; [ 
    vim curl wget nano bind iptables python3 mc tmux
  ];

  services.openssh = {
      enable = true;
  #    permitRootLogin = "yes";
  };

  programs.zsh = {
      enable = true;
      ohMyZsh = {
          enable = true;
          theme = "bira";
      };
  };


  #virtualisation.docker.enable = true;

  #networking.firewall.enable = false;

  # WiFi
  # https://github.com/NixOS/nixpkgs/issues/115652
  nixpkgs.overlays = [(self: super: {
    firmwareLinuxNonfree = super.firmwareLinuxNonfree.overrideAttrs (old: {
      version = "2020-12-18";
      src = pkgs.fetchgit {
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
        rev = "b79d2396bc630bfd9b4058459d3e82d7c3428599";
        sha256 = "1rb5b3fzxk5bi6kfqp76q1qszivi0v1kdz1cwj2llp5sd9ns03b5";
      };
      outputHash = "1p7vn2hfwca6w69jhw5zq70w44ji8mdnibm1z959aalax6ndy146";
    });
  })];

  systemd.services.iwd.serviceConfig.Restart = "always";
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };
  networking = {
    useDHCP = false;
    interfaces.wlan0.useDHCP = true;
    networkmanager.wifi.backend = "iwd";
    wireless = {
      enable = false;
      iwd.enable = true;
    };
  };
  boot = {
    extraModprobeConfig = ''
      options cf680211 ieee80211_regdom="US"
    '';
  };
  
  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };
  
  time.timeZone = "America/Chicago";
  
  # put your own configuration here, for example ssh keys:
  users.defaultUserShell = pkgs.zsh;
  users.mutableUsers = true;
  users.groups = {
    nixos = {
      gid = 1000;
      name = "nixos";
    };
  };
  
  users.extraUsers.alex = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
  };  

  #users.extraUsers.root.openssh.authorizedKeys.keys = [
  #    # Your ssh key
  #    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqlXJv/noNPmZMIfjJguRX3O+Z39xeoKhjoIBEyfeqgKGh9JOv7IDBWlNnd3rHVnVPzB9emiiEoAJpkJUnWNBidL6vPYn13r6Zrt/2WLT6TiUFU026ANdqMjIMEZrmlTsfzFT+OzpBqtByYOGGe19qD3x/29nbszPODVF2giwbZNIMo2x7Ww96U4agb2aSAwo/oQa4jQsnOpYRMyJQqCUhvX8LzvE9vFquLlrSyd8khUsEVV/CytmdKwUUSqmlo/Mn7ge/S12rqMwmLvWFMd08Rg9NHvRCeOjgKB4EI6bVwF8D6tNFnbsGVzTHl7Cosnn75U11CXfQ6+8MPq3cekYr lucernae@lombardia-N43SM"
  #];
}
