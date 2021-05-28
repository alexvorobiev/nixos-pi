{ config, pkgs, lib, ... }:
{

  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>

    # For nixpkgs cache
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  sdImage.compressImage = false;
  

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
 
  # !!! Set to specific linux kernel version
  boot.kernelPackages = pkgs.linuxPackages_5_4;

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
    wget
    binutils
    mc
    nix
    gitAndTools.gitFull
    emacs
    tmux
    curl 
    nano 
    iptables 
  ];

  services.openssh = {
      enable = true;
  #    permitRootLogin = "yes";
  };

  services.unifi = {
    enable = true;
   
    unifiPackage = pkgs.unifi5;
    openPorts = true;

    # https://github.com/illegalprime/nixos-on-arm/blob/master/images/unifi/default.nix
    jrePackage = pkgs.jre8_headless; 
  };


  programs.zsh = {
      enable = true;
      ohMyZsh = {
          enable = true;
          theme = "bira";
      };
  };

  # WiFi
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };

  networking = {
    interfaces.eth0.ipv4.addresses = [ {
      address = "10.0.1.10";
      prefixLength = 24;
    } ];

    defaultGateway = "10.0.1.1";
    nameservers =  [ "1.1.1.1" ];

    hostName = "rpi";
    wireless.enable = false;
    
    # needed for remote access to Unifi controller
    firewall.allowedTCPPorts = [ 8443 ];
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

  system.stateVersion = "unstable";

  nixpkgs.config.oraclejdk.accept_license = true;
  nixpkgs.config.allowUnfree = true;

}
