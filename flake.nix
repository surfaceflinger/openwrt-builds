{
  description = "nat's openwrt builds";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    openwrt-imagebuilder.inputs.nixpkgs.follows = "nixpkgs";
    openwrt-imagebuilder.url = "github:astro/nix-openwrt-imagebuilder";
  };

  outputs =
    {
      self,
      nixpkgs,
      openwrt-imagebuilder,
    }:
    {
      packages.x86_64-linux.xiaomi_ax3600 =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          profiles = openwrt-imagebuilder.lib.profiles { inherit pkgs; release = "snapshot"; };

          config = profiles.identifyProfile "xiaomi_ax3600" // {
            target = "qualcommax";

            packages = [
              # Monitoring - manual
              "bottom"
              "htop"

              # Monitoring
              "collectd"
              "collectd-mod-df"
              "collectd-mod-dhcpleases"
              "collectd-mod-dns"
              "collectd-mod-ipstatistics"
              "luci-app-statistics"

              # luci + ssh
              "luci"
              "luci-ssl"
              "px5g-mbedtls"

              # misc
              "bash"
              "coreutils-base64"
              "kmod-zram"
              "lscpu"
              "nano"
              "openssh-sftp-server"
              "screen"
              "speedtest-netperf"
              "stubby"
              "zram-swap"
              "zstd"
            ];

            # include files in the images.
            # to set UCI configuration, create a uci-defauts scripts as per
            # official OpenWRT ImageBuilder recommendation.
            #files = pkgs.runCommand "image-files" { } ''
            #  mkdir -p $out/etc/uci-defaults
            #  cat > $out/etc/uci-defaults/99-custom <<EOF
            #  uci -q batch << EOI
            #  set system.@system[0].hostname='testap'
            #  commit
            #  EOI
            #  EOF
            #'';
          };
        in
        openwrt-imagebuilder.lib.build config;
    };
}
