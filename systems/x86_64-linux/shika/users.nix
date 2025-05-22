{config, ...}: {
  # Declarative user management
  users.mutableUsers = false;

  # Define a user account
  users.users.marvin = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."user_passwords/marvin".path;
    description = "Marvin";
    extraGroups = ["networkmanager" "wheel" "docker"];
  };
}
