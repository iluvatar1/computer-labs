. ~/.bashrc
cd Desktop/PERSISTENT
mkdir -p notebooks 2> /dev/null
cd notebooks
jupyter-notebook --no-browser --ip=0.0.0.0 &

