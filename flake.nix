{
  description = "A very basic flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/master";
    smunix-diagrams-lib.url = "github:smunix/diagrams-lib/fix.diagrams";
  }; 
  outputs = { self, nixpkgs, flake-utils, smunix-diagrams-lib, ... }:
    with flake-utils.lib;
    with nixpkgs.lib;
    eachSystem [ "x86_64-darwin" ] (system:
      let version = "${substring 0 8 self.lastModifiedDate}.${self.shortRev or "dirty"}";
          overlay = self: super:
            with self;
            with haskell.lib;
            with haskellPackages;
            {
              diagrams-svg = rec {
                package = overrideCabal (callCabal2nix "diagrams-svg" ./. {
                  inherit (smunix-diagrams-lib.packages.${system}) diagrams-lib;
                }) (o: { version = "${o.version}-${version}"; });
                };
            };
          overlays = [ overlay ];
      in
        with (import nixpkgs { inherit system overlays; });
        rec {
          packages = flattenTree (recurseIntoAttrs { diagrams-svg = diagrams-svg.package; });
          defaultPackage = packages.diagrams-svg;
        });
}
