{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  ctestCheckHook,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "corrade";
  version = "2020.06-unstable-2026-11-13";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "mosra";
    repo = "corrade";
    rev = "dd288e0ad9d8c12f2ec233c41c0368e99fc57628";
    hash = "sha256-0EjDapOETSHGiEePA574v5YQQq5zXkIuUjyXMT3aB3M=";
  };

  nativeBuildInputs = [ cmake ];
  nativeCheckInputs = [
    ctestCheckHook
    writableTmpDirAsHomeHook
  ];

  cmakeFlags = [
    (lib.cmakeBool "CORRADE_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = true;

  postPatch = ''
    # don't hardcode /root as home
    substituteInPlace \
      src/Corrade/PluginManager/Test/ManagerTest.cpp \
      src/Corrade/Utility/Test/DirectoryTest.cpp \
      src/Corrade/Utility/Test/PathTest.cpp \
      --replace-fail \""/root" \""$HOME"

    # except when the check is only about string manipulation
    substituteInPlace \
      src/Corrade/Utility/Test/PathTest.cpp \
      --replace-fail \
      "\"absolute path with no filename\", \"$HOME\"" \
      "\"absolute path with no filename\", \"/root\""

    # convince the test that this is really $XDG_CONFIG_HOME
    mkdir -p $HOME/.config/autostart
  '';

  meta = {
    description = "C++11 multiplatform utility library";
    homepage = "https://github.com/mosra/corrade";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.arntanguy ];
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };
})
