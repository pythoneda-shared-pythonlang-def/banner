# nix/shared.nix
#
# This file provides functions used by PythonEDA's flake.nix files.
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
rec {
  shellHook-for = { archRole, banner, extra-namespaces, layer, nixpkgs-release
    , org, package, python, pythoneda-shared-pythoneda-domain
    , pythoneda-shared-pythoneda-banner, repo, space }:
    let
      pythonVersionParts = builtins.splitVersion python.version;
      pythonMajorVersion = builtins.head pythonVersionParts;
      pythonMajorMinorVersion =
        "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
    in ''
      export _PYTHONEDA_PACKAGE_NAME="${package.pname}";
      export _PYTHONEDA_PACKAGE_VERSION="${package.version}";
      export _PYTHONEDA_PYTHON_NAME="${python.name}";
      export _PYTHONEDA_PYTHON_VERSION="${pythonMajorMinorVersion}";
      export _PYTHONEDA_NIXPKGS_RELEASE="${nixpkgs-release}";
      export _PYTHONEDA="${pythoneda-shared-pythoneda-domain}";
      export _PYTHONEDA_BANNER="${pythoneda-shared-pythoneda-banner}";
      export _PYTHONEDA_ORG="${org}";
      export _PYTHONEDA_ARCH_ROLE="${archRole}";
      export _PYTHONEDA_LAYER="${layer}";
      export _PYTHONEDA_REPO="${repo}";
      export _PYTHONEDA_SPACE="${space}";
      export _PYTHONEDA_PACKAGE_TAG="${package.version}";
      export _PYTHONEDA_DEPS="$(echo $PYTHONPATH | sed 's : \n g' | wc -l)"
      export _PYTHONEDA_PYTHONEDA_DEPS="$(echo $PYTHONPATH | sed 's : \n g' | grep 'pythoneda' | wc -l)"
      _PYTHONEDA_EXTRA_NAMESPACES="$PYTHONEDA_EXTRA_NAMESPACES";
      if [[ $_PYTHONEDA_EXTRA_NAMESPACES == "" ]]; then
        _PYTHONEDA_EXTRA_NAMESPACES="${extra-namespaces}";
      fi
      export _PYTHONEDA_EXTRA_NAMESPACES;
      export PS1="$($_PYTHONEDA_BANNER/bin/ps1.sh -o $_PYTHONEDA_ORG -r $_PYTHONEDA_REPO -t $_PYTHONEDA_PACKAGE_TAG -s $_PYTHONEDA_SPACE -a $_PYTHONEDA_ARCH_ROLE -l $_PYTHONEDA_LAYER -p $_PYTHONEDA_PYTHON_VERSION -n $_PYTHONEDA_NIXPKGS_RELEASE -D $_PYTHONEDA_DEPS -d $_PYTHONEDA_PYTHONEDA_DEPS)";
      ${banner} -o $_PYTHONEDA_ORG -r $_PYTHONEDA_REPO -t $_PYTHONEDA_PACKAGE_TAG -s $_PYTHONEDA_SPACE -a $_PYTHONEDA_ARCH_ROLE -l $_PYTHONEDA_LAYER -p $_PYTHONEDA_PYTHON_VERSION -n $_PYTHONEDA_NIXPKGS_RELEASE -D $_PYTHONEDA_DEPS -d $_PYTHONEDA_PYTHONEDA_DEPS
      export _PYTHONEDA_PYTHONPATH_OLD="$PYTHONPATH";
      if [[ "$PYTHONEDA_ROOT_FOLDER" == "" ]]; then
        printf "\033[33m[WARNING]\033[0m \033[35mPYTHONEDA_ROOT_FOLDER\033[36m is \033[31mnot set\033[0m. \033[36mChanges in PythonEDA packages won't be noticed! \033[0m\n"
        if [[ $PYTHONEDA_PROCESS_PYTHONPATH != "" ]]; then
          printf "\033[34m[INFO]\033[0m \033[36mSorting PYTHONPATH.\033[0m\n"
          export PYTHONPATH="$(python $_PYTHONEDA/dist/scripts/process_pythonpath.py sort)";
        fi
        echo ""
      else
        if [[ "$_PYTHONEDA_EXTRA_NAMESPACES" != "" ]]; then
          _oldIFS="$IFS";
          IFS=$'\n';
          for namespace in $(echo $_PYTHONEDA_EXTRA_NAMESPACES | sed 's : \n g'); do
            IFS=$'\n';
            namespaceUpper="$(echo $namespace | tr '[:lower:]' '[:upper:]')";
            variable="$(echo -n "$"; echo -n "PYTHONEDA_$namespaceUpper"; echo '_ROOT_FOLDER')"
            namespaceRootFolder="$(eval echo "$variable")";
            namespaceRootFolder="";
            if [[ "$namespaceRootFolder" == "" ]]; then
              printf "\033[33m[WARNING]\033[0m \033[35m$variable\033[36m is \033[31mnot set\033[0m. \033[36mChanges in $namespace packages won't be noticed! \033[0m\n";
            fi
          done;
          IFS="$_oldIFS";
        fi
        export PYTHONPATH="$(${python}/bin/python $_PYTHONEDA/dist/scripts/process_pythonpath.py -r "$PYTHONEDA_ROOT_FOLDER" development)";
      fi
    '';
  devShell-for = { archRole, banner, extra-namespaces, layer, nixpkgs-release
    , org, package, pkgs, python, pythoneda-shared-pythoneda-banner
    , pythoneda-shared-pythoneda-domain, repo, space }:
    pkgs.mkShell {
      buildInputs = [ package pythoneda-shared-pythoneda-banner ];
      shellHook = shellHook-for {
        inherit archRole banner extra-namespaces layer nixpkgs-release org
          package python pythoneda-shared-pythoneda-domain
          pythoneda-shared-pythoneda-banner repo space;
      };
    };
  app-for = { package, entrypoint }: {
    type = "app";
    program = "${package}/bin/${entrypoint}.sh";
  };
}
