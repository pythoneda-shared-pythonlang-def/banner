# PythonEDA Banner

ASCII banner and PS1 for PythonEDA projects.

## How to declare it in your flake

Check the latest tag of this repository, and use it instead of the `[version]` placeholder below.

```nix
{
  description = "[..]";
  inputs = rec {
    [..]
    pythoneda-shared-pythoneda-banner = {
      [optional follows]
      url = "github:pythoneda-shared-pythoneda-def/banner/[version]";
    };
  };
  outputs = [..]
};
```

Should you use [https://github.com/nixos/nixpkgs](nixpkgs "nixpkgs") and/or [https://github.com/numtide/flake-utils](flake-utils "flake-utils"), you might want to pin them in the `[optional follows]` section..

## Usage

### Print the banner

``` sh
nix run https://github.com/pythoneda-shared-pythoneda-def/banner#default -- \
  -o [ORGANIZATION] \
  -r [REPOSITORY] \
  -t [TAG] \
  -s [SPACE] \
  -a [ARCHITECTURE_ROLE] \
  -l [LAYER] \
  -p [PYTHON_VERSION] \
  -n [NIXPKGS_RELEASE] 
```

Where:
 * -o ORGANIZATION: The github organization.
 * -r REPOSITORY: The repository.
 * -t TAG: The tag.
 * -s SPACE: The space. '_' for None; A for Artifact; R for Runtime; T for Tenant.
 * -a ARCHITECTURE_ROLE: The architecture role of the project. 'B' for Bounded Context; 'E' for Event; 'S' for Shared Kernels; 'R' for Realms.
 * -l LAYER: The type of hexagonal layer. 'D' for Domain; 'I' for Infrastructure; 'A' for Application.
 * -p PYTHON_VERSION: The Python version.
 * -n NIXPKGS_RELEASE: The nixpkgs release.

### Build the PS1 value

``` sh
export PS1="$(nix run https://github.com/pythoneda-shared-pythoneda-def/banner#default-ps1 -- \
  -o [ORGANIZATION] \
  -r [REPOSITORY] \
  -t [TAG] \
  -s [SPACE] \
  -a [ARCHITECTURE_ROLE] \
  -l [LAYER] \
  -p [PYTHON_VERSION] \
  -n [NIXPKGS_RELEASE])"; 
```

The values are the same as for the banner.
