{...}: {
  # Makes home manager use the system packages -> more stable and less duplication
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";
  };
}
