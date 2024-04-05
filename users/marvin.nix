{ pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marvin = {
    isNormalUser = true;
    description = "Marvin";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
}
