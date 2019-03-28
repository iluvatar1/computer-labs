# Create sample
cd example
setup_simul.sh
prepro_initializer.x
# run simul
copy_final_to_initial.sh
dem.x
# postpro
postpro_main.x
# visualize
postpro_display_paraview.x

