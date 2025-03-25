
cd /tmp
git clone https://git.immc.ucl.ac.be/fluidparticles/migflow
cd migflow/

#INSTALL (Una vez)
mkdir build
cd build
cmake  ../
make -j $(nproc)

pip install —local gmsh numpy

#Ejecucion de un ejemplo
cd migflow/examples


#—————————

#https://fluidparticles.git-page.immc.ucl.ac.be/migflow/installation.html#migflow

#python3 -m venv migflow-env
#source migflow-env/bin/activate
#python3 -m pip install migflow gmsh mkl scipy 
