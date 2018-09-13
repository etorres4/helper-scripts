# Maintainer: Eric Torres <erictorres4@protonmail.com>
pkgname=helper-scripts
pkgver=1.5.1
pkgrel=1
pkgdesc="A collection of various helper scripts"
arch=('any')
license=('GPL3')
groups=()
depends=('curl' 'python')
makedepends=('git')
optdepends=()
source=("${pkgname}::git+file:///home/etorres/Packages/helper-scripts")
sha256sums=('SKIP')
sha512sums=('SKIP')

package() {
    cd "${srcdir}/${pkgname}"
    install -Dm755 "drivetemp.py" "${pkgdir}/usr/bin/drivetemp"
    install -Dm755 "fqo.sh" "${pkgdir}/usr/bin/fqo"
    install -Dm755 "gek.sh" "${pkgdir}/usr/bin/gek"
    install -Dm755 "getweather.sh" "${pkgdir}/usr/bin/getweather"
}
