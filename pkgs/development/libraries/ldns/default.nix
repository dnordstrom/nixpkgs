{ lib, stdenv, fetchurl, openssl, perl, which, dns-root-data }:

stdenv.mkDerivation rec {
  pname = "ldns";
  version = "1.8.0";

  src = fetchurl {
    url = "https://www.nlnetlabs.nl/downloads/ldns/${pname}-${version}.tar.gz";
    sha256 = "sha256-glElB2mAMcN5AulByE3so+2tjPeR58MnWi2Z1OU/jPw=";
  };

  postPatch = ''
    patchShebangs doc/doxyparse.pl
  '';

  outputs = [ "out" "dev" "man" "examples" ];

  nativeBuildInputs = [ perl ];
  buildInputs = [ openssl ];

  configureFlags = [
    "--with-ssl=${openssl.dev}"
    "--with-trust-anchor=${dns-root-data}/root.key"
    "--with-drill"
    "--disable-gost"
    "--with-examples"
  ] ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "ac_cv_func_malloc_0_nonnull=yes"
    "ac_cv_func_realloc_0_nonnull=yes"
  ];

  checkInputs = [ which ];
  doCheck = false; # fails. missing some files

  postInstall = ''
    # Only 'drill' stays in $out
    # the rest are examples:
    moveToOutput "bin/ldns*" "$examples"
    # with exception of ldns-config, which goes to $dev:
    moveToOutput "bin/ldns-config" "$dev"
  '';

  meta = with lib; {
    description = "Library with the aim of simplifying DNS programming in C";
    license = licenses.bsd3;
    homepage = "http://www.nlnetlabs.nl/projects/ldns/";
    platforms = platforms.unix;
    maintainers = with maintainers; [ dtzWill ];
  };
}
