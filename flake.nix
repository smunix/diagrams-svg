{
  description = "A very basic flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/master";
    smunix-diagrams-core.url = "github:smunix/diagrams-core/fix.diagrams";
    smunix-diagrams-lib.url = "github:smunix/diagrams-lib/fix.diagrams";
    smunix-monoid-extras.url = "github:smunix/monoid-extras/fix.diagrams";
  }; 
  outputs =
    { self, nixpkgs, flake-utils,
      smunix-monoid-extras, smunix-diagrams-core, smunix-diagrams-lib,
      ...
    }:
    with flake-utils.lib;
    with nixpkgs.lib;
    eachSystem [ "x86_64-linux" ] (system:
      let version = "${substring 0 8 self.lastModifiedDate}.${self.shortRev or "dirty"}";
          overlay = self: super:
            with self;
            with haskell.lib;
            with (haskellPackages.extend(self: super: {
              inherit (smunix-monoid-extras.packages.${system}) monoid-extras;              
              inherit (smunix-diagrams-core.packages.${system}) diagrams-core;              
              inherit (smunix-diagrams-lib.packages.${system}) diagrams-lib;              
            }));
            {
              diagrams-svg = rec {
                package = overrideCabal (callCabal2nix "diagrams-svg" ./. {}) (o: { version = "${o.version}-${version}"; });
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
