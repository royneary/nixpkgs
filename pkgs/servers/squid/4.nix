{ stdenv, fetchurl, perl, openldap, pam, db, cyrus_sasl, libcap
, expat, libxml2, openssl, fetchpatch }:

stdenv.mkDerivation rec {
  name = "squid-4.4";

  src = fetchurl {
    url = "http://www.squid-cache.org/Versions/v4/${name}.tar.xz";
    sha256 = "10pfx44mps5ng1806rqdwx8jv8b2n25kjvx37dcd4x2mgzdfc1a9";
  };

  patches = [
    (fetchpatch {
      name = "4.x-CVE-2019-13345.patch";
      url = "https://github.com/squid-cache/squid/commit/be1dc8614e7514103ba84d4067ed6fd15ab8f82e.patch";
      sha256 = "0vqbnkib695xk5cvldrh993k8387rpghxw3x94la8mq3w7lga9m3";
    })
  ];

  buildInputs = [
    perl openldap db cyrus_sasl expat libxml2 openssl
  ] ++ stdenv.lib.optionals stdenv.isLinux [ libcap pam ];

  prePatch = ''
    substituteInPlace configure --replace "/usr/local/include/libxml2" "${libxml2.dev}/include/libxml2"
  '';

  configureFlags = [
    "--enable-ipv6"
    "--disable-strict-error-checking"
    "--disable-arch-native"
    "--with-openssl"
    "--enable-ssl-crtd"
    "--enable-storeio=ufs,aufs,diskd,rock"
    "--enable-removal-policies=lru,heap"
    "--enable-delay-pools"
    "--enable-x-accelerator-vary"
  ] ++ stdenv.lib.optional (stdenv.isLinux && !stdenv.hostPlatform.isMusl) "--enable-linux-netfilter";

  meta = with stdenv.lib; {
    description = "A caching proxy for the Web supporting HTTP, HTTPS, FTP, and more";
    homepage = http://www.squid-cache.org;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ fpletz raskin ];
  };
}