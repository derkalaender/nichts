{self, ...}: {
  nichts.lib.fs = rec {
    get-file = p: "${self}/${p}";
    secret = p: get-file "secrets/${p}";
  };
}
