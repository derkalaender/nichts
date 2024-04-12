{ ... }:
{
  # Makes home manager use the system packages -> more stable and less duplication
  home-manager = {
    # useUserPackages = true; # TODO this somehow makes the home manager service not start correctly because nix does not have packages? Can't google this...
    useGlobalPkgs = true;
  };
}
