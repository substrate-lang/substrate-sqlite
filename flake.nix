{
  description = "substrate-sqlite: SQLite as a wasm module, for substrate";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      chromium = pkgs:
        if pkgs.stdenv.isLinux then pkgs.chromium
        else pkgs.runCommand "chromium" {
          browsers = pkgs.playwright-driver.browsers-chromium.override { withFfmpeg = false; };
        } ''
          app="$(find -L "$browsers" -maxdepth 3 -name '*.app' | head -1)"
          [ -n "$app" ] || { echo "no application bundle in $browsers" >&2; exit 1; }
          mkdir -p "$out/bin"
          { echo '#!${pkgs.runtimeShell}'
            echo "exec \"$app/Contents/MacOS/$(basename "$app" .app)\" \"\$@\""
          } > "$out/bin/chromium"
          chmod +x "$out/bin/chromium"
        '';
    in {
      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.nodejs        # V8: substrate's host, and the browser test's driver
            (chromium pkgs)    # the headless browser of the browser test (above)
          ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            pkgs.clang     # bench's native SQLite
            pkgs.pkgsCross.wasi32.stdenv.cc   # clang for wasm with a C library: build.sh
          ];
          # build.sh and bench: SQLite's amalgamation, and its speedtest1.c
          SQLITE_AMALGAMATION = pkgs.fetchzip {
            url = "https://sqlite.org/2026/sqlite-amalgamation-3510200.zip";
            hash = "sha256-WUH/22OMthEsDTGrpZ8dLCts6890wSLGMmPWt725Gss=";
          };
          SQLITE_SPEEDTEST1 = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/sqlite/sqlite/version-3.51.2/test/speedtest1.c";
            hash = "sha256-ter0u8uzIP2Os/PmxM1fUaZN0M1w7+lpY00XheNBlnU=";
          };
        };
      });
    };
}
