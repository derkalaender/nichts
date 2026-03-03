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

      services.pipewire.extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 2048; # Was likely 1024
          "default.clock.min-quantum" = 1024;
          "default.clock.max-quantum" = 8192;
        };
      };

      services.pipewire.extraConfig.pipewire-pulse."92-pulse-low-latency" = {
        "pulse.properties" = {
          "pulse.min.req" = "1024/48000";
          "pulse.min.frag" = "1024/48000";
          "pulse.min.quantum" = "1024/48000";
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
