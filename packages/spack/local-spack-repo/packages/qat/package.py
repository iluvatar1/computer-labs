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
#     spack install qat
#
# You can edit this file again by typing:
#
#     spack edit qat
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack.package import *


class Qat(QMakePackage):
    """Is  a toolkit, based up  the Qt library, and a collection of useful classes for doing

    ·       Function manipulation,

    ·       Plotting

    ·       Data Analysis

    ·       Derivatives and Integrals

    ·       Ordinary differential equations

    ·       Hamiltonian  Mechanics
   """

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "http://qat.pitt.edu/"
    url = "https://www.qat.pitt.edu/qat-3.0.1.tar.gz"

    # FIXME: Add a list of GitHub accounts to
    # notify when the package is updated.
    # maintainers = ["github_user1", "github_user2"]

    version("3.0.1", sha256="4381ab985dd1f7e9b2fa3a6b8171f64d88126db5e5ac5010d6df3be99172b55b")

    # FIXME: Add dependencies if required.
    depends_on("gsl")
    depends_on("subversion")
    depends_on("hdf5 +mpi")
    depends_on("eigen")
    depends_on("qt@5:")
    depends_on("qt-creator")
    depends_on("coin3d")

    def patch(self):
        """Replace hdf5-openmpi by hdf5"""
        filter_file(
                "hdf5-openmpi",
                "hdf5",
                "Qhfd/src/qt.pro"
                )

    #def qmake(self):
    #    qmake()

    def build(self, spec, prefix):
        make(parallel=True) # HERE, FALSE

    #def install(self, spec, prefix):
    #    make("install INSTALL_ROOT=$INSTALL_ROOT", parallel=False)

    def setup_build_environment(self, env):
        env.set("INSTALL_ROOT", self.prefix)
        #print(self.prefix)
        #input("Press enter...")
        #env.set("INSTALL_ROOT", "/tmp/QAT2")

    ## Fix install prefix
    #@run_after("qmake")
    #def fix_install_path(self):
    #    makefile = FileFilter("Makefile")
    #    makefile.filter(r"\$\(INSTALL_ROOT\)" + self.spec["qt"].prefix, "$(INSTALL_ROOT)")

    def qmake_args(self):
        # FIXME: If not needed delete this function
        #args = [r"PREFIX = $(INSTALL_ROOT)"]
        #print(args)
        #input("Press enter...")
        args = [r"PREFIX = /"]
        return args

