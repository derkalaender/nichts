{ ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marvin = {
    isNormalUser = true;
    description = "Marvin";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  users.users.docker-user = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
  };

  users.users.podman-user = {
    isNormalUser = true;
  };
}
