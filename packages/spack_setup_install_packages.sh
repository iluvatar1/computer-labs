echo "Clonning and setting up spack..."
cd /packages
git clone -c feature.manyFiles=true https://github.com/spack/spack.git
cd spack
echo "Change root to /packages/spack/… in etc/spack/defaults/config.yaml"
sleep 5
. share/spack/setup-env.sh
spack clean -m
mv /root/.spack{,-OLD}
spack find compilers

echo "Installing packages ..."
echo "YOU MUST INSTALL: turbovnc VTK liggghts. Use the scripts in the package directory"
spack install grace target=x86_64
for pkg in grace benchmark  googletest gperf hotspot-perf nanobench; do
    spack install $pkg target=x86_64
done

spack install cdo +curl target=x86_64
spack install grads target=x86_64
#spack install rstudio +notebook target=x86_64

spack install mfem +examples +miniapps +lapack +petsc +slepc +sundials +superlu-dist +openmp target=x86_64

