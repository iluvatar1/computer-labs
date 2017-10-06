#-------------------------------------------------------------------------------
# This script is designed to build a sample of polygonal grains inside a
# rectangular box.
#-------------------------------------------------------------------------------
# 1. Import modules and packages.
import os,sys
import numpy
import math
from pylmgc90.pre_lmgc import *
#-------------------------------------------------------------------------------
# 2. Find out if the working directory exists, and, if it doesn't, create it.
if not os.path.isdir('./DATBOX'):
  os.mkdir('./DATBOX')
#-------------------------------------------------------------------------------
# 3. Set the physical parameters of the system
dim = 2 # Space dimension (2 or 3)
nb_particles = 300 # Number of particles
Rmin = 0.5 # Minimum radius
Rmax = 2. # Maximum radius
nb_vertex_a = 5 # Number of vertices for group a
nb_vertex_b = 3 # Number of vertices for group b
k_a         = 0.5 # proportion of particles in group a
mu_pp = 0.4 # Friction coefficient in particle-particle contacts
mu_wp = 0.4 # Friction coefficient in wall-particle contacts
lx = 75. # Box size in the x axis
ly = 50. # Box size in the y axis
gravity = [0.,-9.81,0.] # Gravity acceleration vector
#-------------------------------------------------------------------------------
# 4. Define the data structures to be used in order to build the sample.
bodies = avatars() # Bodies
mat = materials() # Materials
svs = see_tables() # Contacts
tacts = tact_behavs() # Library of interaction laws
#-------------------------------------------------------------------------------
# 5. Create a library of constitutive models.
mod = model(name='rigid', type='MECAx', element='Rxx2D', dimension=dim)
#-------------------------------------------------------------------------------
# 6. Create a library of materials.
# 6.1. Walls material
tdur = material(name='TDURx',type='RIGID',density=1000.)
# 6.2. Grains material
plex = material(name='PLEXx',type='RIGID',density=100.)
mat.addMaterial(tdur,plex)
#-------------------------------------------------------------------------------
# 7. Create a set of radii with a certain grain size distribution.
radii=granulo_Random(nb_particles, Rmin, Rmax)
radius_min=min(radii)
radius_max=max(radii)
#-------------------------------------------------------------------------------
# 8. Create a set of positions inside the box.
[nb_remaining_particles, coor]=depositInBox2D(radii, lx, ly)
if (nb_remaining_particles < nb_particles):
  print "Warning: granulometry changed, since some particles were removed!"
#-------------------------------------------------------------------------------
# 9. Create a set of particles and assign them radii, positions, and other
# properties.
nb_particles_a = round(nb_remaining_particles * k_a)      # Number of a_particle
for i in xrange(0,nb_remaining_particles,1):
  if (i<nb_particles_a):
    body=rigidPolygon(radius=radii[i], center=coor[2*i : 2*(i + 1)], nb_vertices=nb_vertex_a,
                        model=mod, material=plex, color='BLEUx')
  else:
    body=rigidPolygon(radius=radii[i], center=coor[2*i : 2*(i + 1)], nb_vertices=nb_vertex_b,
                        model=mod, material=plex, color='BLEUx')
  bodies += body
#-------------------------------------------------------------------------------
# 10. Create a set of walls and assign them various properties.
down = rigidJonc(axe1=0.5*lx+radius_max, axe2=radius_max, center=[0.5*lx, -radius_max],
                 model=mod, material=tdur, color='WALLx')
up   = rigidJonc(axe1=0.5*lx+radius_max, axe2=radius_max, center=[0.5*lx, ly+radius_max],
                 model=mod, material=tdur, color='WALLx')
left = rigidJonc(axe1=0.5*ly+radius_max, axe2=radius_max, center=[-radius_max, 0.5*ly],
                 model=mod, material=tdur, color='WALLx')
right= rigidJonc(axe1=0.5*ly+radius_max, axe2=radius_max, center=[lx+radius_max, 0.5*ly],
                 model=mod, material=tdur, color='WALLx')
bodies += down; bodies += up; bodies += left; bodies += right
left.rotate(psi=-math.pi/2., center=left.nodes[1].coor)
right.rotate(psi=math.pi/2., center=right.nodes[1].coor)
#-------------------------------------------------------------------------------
# 11. Set the driven degrees of freedom.
down.imposeDrivenDof(component=[1, 2, 3], dofty='vlocy')
up.imposeDrivenDof(component=[1, 2, 3], dofty='vlocy')
left.imposeDrivenDof(component=[1, 2, 3], dofty='vlocy')
right.imposeDrivenDof(component=[1, 2, 3], dofty='vlocy')
#-------------------------------------------------------------------------------
# 12. Create a library of interaction laws.
# 12.1. Interaction law to be used between grains
lplpl=tact_behav(name='iqsc0',type='IQS_CLB',fric=mu_pp)
tacts+=lplpl
# 12.2. Interaction law to be used between walls and grains
lpljc=tact_behav(name='iqsc1',type='IQS_CLB',fric=mu_wp)
tacts+=lpljc
#-------------------------------------------------------------------------------
# 13. Set visibility rules between bodies
# 13.1. Visibility rule to be used between grains
svdkdk = see_table(CorpsCandidat='RBDY2',candidat='POLYG',
   colorCandidat='BLEUx',behav=lplpl, CorpsAntagoniste='RBDY2', 
   antagoniste='POLYG',colorAntagoniste='BLEUx',alert=0.1*radius_min)
svs+=svdkdk
# 13.2. Visibility rule to be used between walls and grains
svdkjc = see_table(CorpsCandidat='RBDY2',candidat='POLYG',
   colorCandidat='BLEUx',behav=lpljc, CorpsAntagoniste='RBDY2', 
   antagoniste='JONCx',colorAntagoniste='WALLx',alert=0.1*radius_min)
svs+=svdkjc
#-------------------------------------------------------------------------------
# 14. Write output files into the working folder
writeBodies(bodies,chemin='DATBOX/')
writeBulkBehav(mat,dim=dim,gravy=gravity,chemin='DATBOX/')
writeTactBehav(tacts,svs,chemin='DATBOX/')
writeDrvDof(bodies,chemin='DATBOX/')
writeDofIni(bodies,chemin='DATBOX/')
writeVlocRlocIni(chemin='DATBOX/')
#-------------------------------------------------------------------------------
# 15. Draw a snapshot of the sample
try:
  visuAvatars(bodies)
except:
  pass
#-------------------------------------------------------------------------------
