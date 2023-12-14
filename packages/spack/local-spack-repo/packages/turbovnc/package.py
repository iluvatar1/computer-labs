# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Turbovnc(CMakePackage):
    """TurboVNC is a high-performance, enterprise-quality version of VNC based on TightVNC, TigerVNC, and X.org. It contains a variant of Tight encoding that is tuned for maximum performance and compression with 3D applications (VirtualGL), video, and other image-intensive workloads. TurboVNC, in combination with VirtualGL, provides a complete solution for remotely displaying 3D applications with interactive performance. TurboVNC's high-speed encoding methods have been adopted by TigerVNC and libvncserver, and TurboVNC is also compatible with any other TightVNC derivative."""

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "https://turbovnc.org/"
    url      = "https://ufpr.dl.sourceforge.net/project/turbovnc/3.0.1/turbovnc-3.0.1.tar.gz"
    #url      = "https://ufpr.dl.sourceforge.net/project/turbovnc/2.2.90%20%283.0%20beta1%29/turbovnc-2.2.90.tar.gz"

    # FIXME: Add a list of GitHub accounts to
    # notify when the package is updated.
    # maintainers = ['github_user1', 'github_user2']

    version('3.0.1',  sha256='839d6ac42cfd2af258113970915c3d38c1b9ee3f89af2c2c1379e370c8ad4aa0')
    version('2.2.90', sha256='4918b816f111bff503cb17459e05453829598195d6fce5398b63765e75dc94ea')

    # FIXME: Add dependencies if required.
    depends_on('openjdk')
    depends_on('libjpeg-turbo')

    #def cmake_args(self):
    #    # FIXME: Add arguments other than
    #    # FIXME: CMAKE_INSTALL_PREFIX and CMAKE_BUILD_TYPE
    #    # FIXME: If not needed delete this function
    #    args = ['-G"Unix Makefiles"']
    #    return args

