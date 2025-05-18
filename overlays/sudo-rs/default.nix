{channels, ...}: final: prev: {
  # Needed to get the latest version of sudo-rs with support for pwfeedback
  inherit (channels.unstable) sudo-rs;
}
