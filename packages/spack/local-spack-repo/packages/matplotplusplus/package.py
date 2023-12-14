# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

# ----------------------------------------------------------------------------
# If you submit this package back to Spack as a pull request,
# please first remove this boilerplate and all FIXME comments.
#
# This is a template package file for Spack.  We've put "FIXME"
# next to all the things you'll want to change. Once you've handled
# them, you can save this file and test your package like this:
#
#     spack install matplotplusplus
#
# You can edit this file again by typing:
#
#     spack edit matplotplusplus
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack.package import *


class Matplotplusplus(CMakePackage):
    """Matplot++: A C++ Graphics Library for Data Visualization"""

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "https://alandefreitas.github.io/matplotplusplus/"
    url = "https://github.com/alandefreitas/matplotplusplus/archive/refs/tags/v1.2.0.tar.gz"

    # FIXME: Add a list of GitHub accounts to
    # notify when the package is updated.
    # maintainers = ["github_user1", "github_user2"]

    version("1.2.0", sha256="42e24edf717741fcc721242aaa1fdb44e510fbdce4032cdb101c2258761b2554")

    # FIXME: Add dependencies if required.
    depends_on("gnuplot")

    def cmake_args(self):
        # FIXME: Add arguments other than
        # FIXME: CMAKE_INSTALL_PREFIX and CMAKE_BUILD_TYPE
        # FIXME: If not needed delete this function
        args = []
        return args
