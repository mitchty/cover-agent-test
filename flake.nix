{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    #ollama.url = "github:abysssol/ollama-flake";
    ollama.url = "github:mastoca/ollama-flake";
    #ollama.inputs.nixpkgs.follows = "nixpkgs"; # this could break the build unless using unstable nixpkgs

    flake-utils.url = "github:numtide/flake-utils";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    { self
    , flake-utils
    , nixpkgs
    , ollama
    , poetry2nix
    , ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
    let
      # nixlib = nixpkgs.legacyPackages.${system}.python3.pkgs;
      # cover-agent = nixlib.buildPythonApplication rec {
      #   pname = "cover-agent";
      #   version = "0.2.1";
      #   src = pkgs.lib.fetchFromGitHub rec {
      #     owner = "Codium-ai";
      #     repo = pname;
      #     rev = "refs/tags/${version}";
      #     hash = "";
      #   };
      # };

      buildpython = nixpkgs.legacyPackages.${system}.python310;

      # pkgs = import nixpkgs
      #   rec {
      #     inherit system;
      #     config.allowUnfree = true;
      #     config.cudaSupport = true;
      #   }.legacyPackages.${system}.extend
      #   poetry2nix.overlays.default;

      pkgs = (import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
      }).extend poetry2nix.overlays.default;

      cover-agent = pkgs.poetry2nix.mkPoetryApplication
        rec {
          python = pkgs.python311;
          pname = "cover-agent";
          version = "0.2.2";
          src = nixpkgs.legacyPackages.${system}.fetchFromGitHub rec {
            owner = "Codium-ai";
            repo = pname;
            rev = "refs/tags/${version}";
            hash = "sha256-KG2l5UyFuf/utuPwnbTCr4zwg7CL1ELFn5EQU2lii0A=";
          };
          pyproject = "${src}/pyproject.toml";
          poetrylock = "${src}/poetry.lock";
          doCheck = false; # TODO later mitch problem
          propogatedBuildInputs = [
            pkgs.rustPlatform.maturinBuildHook
          ];
          nativeBuildInputs = [
            pkgs.python311Packages.six
          ];
          overrides = pkgs.poetry2nix.overrides.withDefaults
            (_: super: {
              # TODO try to figure out a set of poetry2nix overrides that works
              # jiter = super.jiter.override {
              #   propogatedBuildInputs = super.propogatedBuildInputs ++ [ pkgs.rustPlatform.maturinBuildHook pkgs.rustPlatform.cargoSetupHook pkgs.python312Packages.setuptools-rust maturin ];
              # };
              google-cloud-aiplatform = super.google-cloud-aiplatform.overridePythonAttrs
                (
                  old: {
                    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.python311Packages.setuptools ];
                  }
                );
              tokenizers = super.tokenizers.override {
                preferWheel = true;
              };
              jiter = super.jiter.override {
                preferWheel = true;
              };
              tiktoken = super.tiktoken.override {
                preferWheel = true;
              };
              hatchling = super.hatchling.override {
                preferWheel = true;
              };
              wandb = super.wandb.override {
                preferWheel = true;
              };
              # jiter = pkgs.python311Packages.jiter;
              #              tokenizers = pkgs.python311Packages.tokenizers;
              #              tiktoken = pkgs.python311Packages.tiktoken;
              #              litellm = pkgs.python311Packages.litellm;
              # hatchling = pkgs.python311Packages.hatchling;
              #wandb = pkgs.python311Packages.wandb; # derivations too old to use directly
              # wandb = pkgs.python311Packages.wandb.overridePythonAttrs (old: rec {
              #   WANDB_BUILD_SKIP_NVIDIA = "true"; # TODO figure out how to get the cargo setup hook to work with a subdirectory
              #   doCheck = false; # ignoring tests for now
              #   version = "0.17.9";
              #   src = super.pkgs.fetchFromGitHub {
              #     owner = "wandb";
              #     repo = "wandb";
              #     rev = "refs/tags/v${version}";
              #     sha256 = "sha256-GHHM3PAGhSCEddxfLGU/1PWqM4WGMf0mQIKwX5ZVIls=";
              #   };
              #   patches = [ ./git.patch ./go.patch ];
              #   disabledTestPaths = pkgs.lib.lists.remove "tests/pytest_tests/system_tests/test_notebooks/test_notebooks.py" (old.disabledTestPaths or [ ]);
              #   propogatedBuildInputs = (old.propogatedBuildInputs or [ ]) ++ [
              #     pkgs.rustPlatform.maturinBuildHook
              #     pkgs.rustPlatform.cargoSetupHook
              #     pkgs.python311Packages.setuptools-rust
              #   ];
              #   nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
              #     pkgs.go
              #     pkgs.cargo
              #   ];
              #   buildInputs = (old.buildIputs or [ ]) ++ [
              #     pkgs.python311Packages.hatchling
              #     pkgs.python311Packages.typing-extensions
              #     pkgs.python311Packages.platformdirs
              #     pkgs.cargo
              #   ];
              # });
            });
          # overrides = inputs.poetry2nix.lib.defaultPoetryOverrides.extend
          #   (final: prev: {
          #     django-floppyforms = prev.django-floppyforms.overridePythonAttrs
          #       (
          #         old: {
          #           buildInputs = (old.buildInputs or [ ]) ++ [ prev.setuptools ];
          #         }
          #       );
          #   });
        };
      pythonPackages =
        p: with p;
        [
          boto3
          chromadb
          langchain
          langchain-community
          numpy
          pypdf
          pytest
          pytest-cov
          poetry-core
          #              cover-agent
        ];

      # I AM A HACK, was getting sick of getting poetry2nix to build a
      # derivation so like any hero I did what I needed to and just cheated a
      # cheesed hacked version of cover-agent the binary.
      cover-agent-patched = nixpkgs.legacyPackages.${system}.stdenv.mkDerivation {
        pname = "cover-agent-hacked";
        version = "0.2.1";

        src = nixpkgs.legacyPackages.${system}.fetchurl {
          url = "https://github.com/Codium-ai/cover-agent/releases/download/0.2.1/cover-agent-ubuntu";
          hash = "sha256-ADBSY9+LmIA0iiPZy4HDyoGhogRJgMUIclYXvRfp8Xs=";
        };

        unpackPhase = ":";

        nativeBuildInputs = [ pkgs.patchelf ];

        buildInputs = [ pkgs.glibc pkgs.zlib ];

        installPhase = ''
          install -dm755 $out/bin
          install -m755 $src $out/bin/cover-agent

          patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 $out/bin/cover-agent
          patchelf --set-rpath ${pkgs.glibc}/lib:${pkgs.zlib}/lib:${pkgs.readline}/lib $out/bin/cover-agent
        '';
      };
    in
    {
      packages = {
        cover-agent = cover-agent;
        cover-agent-patched = cover-agent-patched;
      };
      devShells.default =
        pkgs.mkShell {
          buildInputs = with pkgs; [
            readline
            cover-agent
            pkgs.python311Packages.pytest
            pkgs.python311Packages.pytest-cov
            #            cover-agent-patched
            binutils
          ];
          # export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.ncurses5}/lib
        };
    });
  # # to access the rocm package of the ollama flake:
  # ollama-rocm = ollama.packages.${system}.rocm;
  # #ollama-rocm = inputs'.ollama.packages.rocm; # with flake-parts

  # # you can override package inputs like with nixpkgs
  # ollama-cuda = ollama.packages.${system}.cuda.override { cudaGcc = pkgs.gcc11; };
}
