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
#     spack install spacetime
#
# You can edit this file again by typing:
#
#     spack edit spacetime
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack.package import *


class Spacetime(CMakePackage):
    """The Spacetime library manipulates vectors, four-vectors, spinors, Dirac and Weyl spinors, Lorentz transformations, four-currents, gamma matrices and other such objects that appear in Feynman diagrams."""

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "https://gitlab.cern.ch/boudreau/spacetime"
    url = "https://www.qat.pitt.edu/spacetime-3.0.0.tar.gz"

    # FIXME: Add a list of GitHub accounts to
    # notify when the package is updated.
    # maintainers = ["github_user1", "github_user2"]

    version("3.0.0", sha256="0d2ac17ac2877a3c983310721f7c43b1e6fd7d06a51b5776af0b8a5127fdf0bc")

    # FIXME: Add dependencies if required.
    depends_on("eigen@3.3.9")

    def cmake_args(self):
        # FIXME: Add arguments other than
        # FIXME: CMAKE_INSTALL_PREFIX and CMAKE_BUILD_TYPE
        # FIXME: If not needed delete this function
        args = []
        return args
