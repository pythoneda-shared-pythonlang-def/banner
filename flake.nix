# flake.nix
#
# This file packages pythoneda-shared-pythoneda/banner as a Nix flake.
#
# Copyright (C) 2023-today rydnr's pythoneda-shared-pythoneda-def/banner
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "Banner for PythonEDA projects";
  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };
  outputs = inputs:
    with inputs;
    let
      defaultSystems = flake-utils.lib.defaultSystems;
      supportedSystems = if builtins.elem "armv6l-linux" defaultSystems then
        defaultSystems
      else
        defaultSystems ++ [ "armv6l-linux" ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        org = "pythoneda-shared-pythoneda";
        repo = "banner";
        pname = "${org}-${repo}";
        version = "0.0.25";
        pkgs = import nixos { inherit system; };
        pythonpackage = "pythoneda.banner";
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        banner-entrypoint = "banner";
        banner-entrypoint-path = "${package}/${banner-entrypoint}.py";
        ps1-entrypoint = "ps1";
        ps1-entrypoint-path = "${package}/${ps1-entrypoint}.py";
        description = "Banner for PythonEDA projects";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        archRole = "S";
        space = "_";
        layer = "D";
        nixosVersion = builtins.readFile "${nixos}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixos-${nixosVersion}";
        shared = import ./nix/shared.nix;
        pythoneda-shared-pythoneda-banner-for = { python }:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            src = ./.;
            bannerTemplateFile = ./templates/banner.py.template;
            entrypointTemplateFile = ./templates/entrypoint.sh.template;
            pyprojectTemplateFile = ./templates/pyproject.toml.template;
            pyprojectTemplate = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage pname pythonMajorMinorVersion pythonpackage
                version;
              package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
              src = pyprojectTemplateFile;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs; [ ];

            pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod +w $sourceRoot
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
              cp ${bannerTemplateFile} $sourceRoot/banner.py.template
              cp ${entrypointTemplateFile} $sourceRoot/entrypoint.sh.template
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist $out/bin $out/templates
              cp banner.py.template entrypoint.sh.template $out/templates
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
              chmod +x $out/lib/python${pythonMajorMinorVersion}/site-packages/${banner-entrypoint-path}
              echo '#!/usr/bin/env sh' > $out/bin/${banner-entrypoint}.sh
              echo "export PYTHONPATH=$PYTHONPATH" >> $out/bin/${banner-entrypoint}.sh
              echo "${python}/bin/python $out/lib/python${pythonMajorMinorVersion}/site-packages/${banner-entrypoint-path} \$@" >> $out/bin/${banner-entrypoint}.sh
              chmod +x $out/bin/${banner-entrypoint}.sh
              chmod +x $out/lib/python${pythonMajorMinorVersion}/site-packages/${ps1-entrypoint-path}
              echo '#!/usr/bin/env sh' > $out/bin/${ps1-entrypoint}.sh
              echo "export PYTHONPATH=$PYTHONPATH" >> $out/bin/${ps1-entrypoint}.sh
              echo "${python}/bin/python $out/lib/python${pythonMajorMinorVersion}/site-packages/${ps1-entrypoint-path} \$@" >> $out/bin/${ps1-entrypoint}.sh
              chmod +x $out/bin/${ps1-entrypoint}.sh
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        apps = rec {
          default = pythoneda-shared-pythoneda-banner-default;
          pythoneda-shared-pythoneda-banner-default =
            pythoneda-shared-pythoneda-banner-python311;
          pythoneda-shared-pythoneda-banner-python38 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-shared-pythoneda-banner-python38;
            entrypoint = banner-entrypoint;
          };
          pythoneda-shared-pythoneda-banner-python39 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-shared-pythoneda-banner-python39;
            entrypoint = banner-entrypoint;
          };
          pythoneda-shared-pythoneda-banner-python310 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-shared-pythoneda-banner-python310;
            entrypoint = banner-entrypoint;
          };
          pythoneda-shared-pythoneda-banner-python311 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-shared-pythoneda-banner-python311;
            entrypoint = banner-entrypoint;
          };
        };
        defaultApp = apps.default;
        defaultPackage = packages.default;
        packages = rec {
          default = pythoneda-shared-pythoneda-banner-default;
          pythoneda-shared-pythoneda-banner-default =
            pythoneda-shared-pythoneda-banner-python311;
          pythoneda-shared-pythoneda-banner-python38 =
            pythoneda-shared-pythoneda-banner-for { python = pkgs.python38; };
          pythoneda-shared-pythoneda-banner-python39 =
            pythoneda-shared-pythoneda-banner-for { python = pkgs.python39; };
          pythoneda-shared-pythoneda-banner-python310 =
            pythoneda-shared-pythoneda-banner-for { python = pkgs.python310; };
          pythoneda-shared-pythoneda-banner-python311 =
            pythoneda-shared-pythoneda-banner-for { python = pkgs.python311; };
        };
      });
}
