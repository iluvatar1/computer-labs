echo "In 1Creation"
sleep 4
cd ./1Creacion
build_SandBox
cp pari ../2Mezcla/input/
cp posi ../2Mezcla/input/
echo "In 2Mezcla"
sleep 4
cd ../2Mezcla
SandBox $PWD
#draw_SandBox
cp ./output/parf ../3Densificacion/input/
cp ./output/posf ../3Densificacion/input/
echo "In 3Densificacion"
sleep 4
cd ../3Densificacion/input
mv parf pari
mv posf posi
cd ..
SandBox $PWD
#draw_SandBox
cp ./output/parf ../4Corte/input/
cp ./output/posf ../4Corte/input/
cd ../4Corte/input
mv parf pari
mv posf posi
cd ..
SandBox
#draw_SandBox
#postpro_SandBox

