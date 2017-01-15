echo "EXECUTING : config.sh"

touch ~/.bashrc

for dname in bin lib include; do
    if [ ! -d ~/$dname ]; then
	echo "Creating #dname dir at home"
	mkdir -p ~/$dname
    fi
done


if [ "" == "$(grep LD_LIBRARY_PATH ~/.bashrc | grep -v grep)" ]; then
    echo "Setting LD_LIBRARY_PATH for ~/lib"
    echo export LD_LIBRARY_PATH="~/lib" >> ~/.bashrc
fi

if [ "" == "$(grep ~/bin ~/.bashrc | grep -v grep)" ]; then
    echo "Setting PATH for ~/bin"
    echo export PATH="$PATH:~/bin" >> ~/.bashrc
fi

echo "Done."	     
