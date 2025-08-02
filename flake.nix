{
  description = "A small daemon to update system76-scheduler foreground process for Niri";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      fsys =
        f:
        lib.attrsets.genAttrs [
          "x86_64-linux"
          "armv7l-linux"
          "aarch64-linux"
        ] (s: f s);
    in
    {
      formatter = fsys (arch: nixpkgs.legacyPackages.${arch}.alejandra);
      packages = fsys (
        arch:
        let
          pkgs = nixpkgs.legacyPackages.${arch};
          cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
          pname = cargoToml.package.name;
          version = cargoToml.package.version;
          pkg = pkgs.rustPlatform.buildRustPackage {
            inherit pname version;
            src = builtins.path {
              path = lib.sources.cleanSource self;
              name = "${pname}-${version}";
            };

            strictDeps = true;

            cargoLock.lockFile = ./Cargo.lock;

            CARGO_BUILD_INCREMENTAL = "false";
            RUST_BACKTRACE = "full";

            meta = {
              mainProgram = "system76-scheduler-niri";
            };
          };
        in
        {
          system76-scheduler-niri = pkg;
          default = pkg;
        }
      );
      homeModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.services.system76-scheduler-niri;
        in
        {
          options.services.system76-scheduler-niri = {
            enable = lib.mkEnableOption "Enable system76-scheduler Niri integration";
            package = lib.mkPackageOption self.packages.${pkgs.system} "system76-scheduler-niri" { };
          };

          config = lib.mkIf cfg.enable {
            systemd.user.services.system76-scheduler-niri = {
              Unit = {
                Description = "Niri integration for system76-scheduler";
                After = [ "niri.service" ];
              };
              Service = {
                Type = "simple";
                ExecStart = lib.getExe cfg.package;
                Restart = "on-failure";
              };
              Install = {
                WantedBy = [ "niri.service" ];
              };
            };
          };
        };
      homeModules.system76-scheduler-niri = self.homeModules.default;
    };
}
