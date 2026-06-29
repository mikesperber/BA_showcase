{
  description = "BA showcase project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    testAuditor = {
      url = "github:mikesperber/testAuditor?ref=moreSystems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      testAuditor,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
      ];

      perSystem =
        { system, self', ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          packages = {
            hello = pkgs.hello;
            default = pkgs.hello;
          };

          devShells.default = pkgs.mkShell {
            buildInputs = [
              (pkgs.python3.withPackages (ps: [
                ps.pytest
                ps.pytest-tap
                ps.pytest-json-report
              ]))

              testAuditor.packages.${system}.default
            ];
          };
        };
    };
}
