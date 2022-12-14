
spack install miniconda3
spack load miniconda3
conda create -n sage
conda init bash
source ~/.bashrc
conda activate sage
conda config --add channels conda-forge
conda install --yes sage
conda deactivate
spack unload
