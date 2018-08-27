# Maintainer: Eric Torres <erictorres4@protonmail.com>
pkgname=helper-scripts
pkgver=1.5
pkgrel=1
pkgdesc="A collection of various helper scripts"
arch=('any')
license=('GPL3')
groups=()
depends=('curl' 'python')
makedepends=('git')
optdepends=('xdg-utils: for xdg-open with the open script')
source=("${pkgname}::git+file:///home/etorres/Packages/helper-scripts")
sha256sums=('63e0deceb6384700ae419ebea0abdb23b859d88417a52f5c83956ed25d1ade1b'
            'a946953eaa319cdb322a747022a86ef6b01dcb1bb1d08af68551183617d37f2c'
            'eb8a1747ac1742bf0e480801cdb948154bcc19c8e6af272ff1a9d24d371e5b6c'
            'a89d8dd332ff0daf15eb7ca614dda3ddab8d6bd1d8dddf436aaa1cafbf695cbc'
            '5350ddb71851be9159439f113325ef4d30bb90c5ee100b302ec4d55645f62413'
            'cc9feaf4279a1d7bc65ad826f540e44c84ff8ae7eb6ae8b4cb71ef9d1f8576ca')
sha512sums=('d6dcd9dfb7f5275562f831da87edfb712f01a9c4de1c3ea0070c0a9a2d7a21707eee4a21feca9de5d735ab9c45c99470f70dd95e63bf4a0e695453fd55576771'
            '534cd37a3222cc617ef2af194822a3b79b9a3836653ae13a734f055904d836eba87478965af2902ae718c90dbb4d7f2da28ac533a276c2a847d4978d2a2ae9b4'
            '8b3fa9f7114bb89da005285676a92ad7000503f28d732aaa7c8f84976f80c627153b3728a8ec59aba5b6f19f7df7affb963a047328449be1d520a810de284d45'
            '0b71a3ab2fe09647b29b4bf4370c9332749605fe45f3defade45ecc2d85638be7312bc786b5f56a2b3df6d5ef83e10e52108b8b40b2460b11f5a8f3785afc61c'
            '74f4559a3ddcde0a3a411f11898d6323639c593525de83064eab82b10353417d518ed5b0bb1d4c2bed9b03b25f007bd8ced413cfb549fb36a7530cb3f0a935f5'
            '00777bc87b7e522cc96616c84451ddbe6470ba65ef97a6bd9be0acfd3295ea15e9d63ca2c95d3a08dd47e67a0c3cf0afccf849bfd0d2321a0444e837fed3311e')

package() {
    install -Dm755 "ddusb.py" "${pkgdir}/usr/bin/ddusb"
    install -Dm755 "drivetemp.py" "${pkgdir}/usr/bin/drivetemp"
    install -Dm755 "fqo.sh" "${pkgdir}/usr/bin/fqo"
    install -Dm755 "gek.sh" "${pkgdir}/usr/bin/gek"
    install -Dm755 "getweather.sh" "${pkgdir}/usr/bin/getweather"
}
