{
  nichts.aspects.desktop.nixos = {
    # See https://wiki.nixos.org/wiki/PipeWire#Configuring_PipeWire

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
    };

    services.pipewire.wireplumber.extraConfig = {
      # 11-bluetooth-policy: Disable auto-switch to low-quality HSP/HFP on mic use
      "11-bluetooth-policy" = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };

      # Fixes issue with sound volume ramping up and short sounds getting swollowed
      "99-disable-suspend" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "node.name" = "~alsa_input.*";
              }
              {
                "node.name" = "~alsa_output.*";
              }
            ];
            actions = {
              update-props = {
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
        ];
      };

      "wh-1000xm4-ldac-hq" = {
        "monitor.bluez.rules" = [
          {
            matches = [
              {
                # Match any bluetooth device with ids equal to that of a WH-1000XM4
                "device.name" = "~bluez_card.*";
                "device.product.id" = "0x0d58";
                "device.vendor.id" = "usb:054c";
              }
            ];
            actions = {
              update-props = {
                # Set quality to high quality instead of the default of auto
                "bluez5.a2dp.ldac.quality" = "hq";
              };
            };
          }
        ];
      };
    };
  };
}
