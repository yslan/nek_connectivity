# gmsh2con

A gmsh to co2 converter that extract the connectivity stores inside the `.msh` file.

Gmsh doesn't guarantee the water-tight mesh. 
Therefore, this python script relies on the whether Gmsh can stably generated an uniue id list for its node. 
If it does, we can extract the info directly. Otherwise, gmsh2nek will drop this infomation.

We also call `gmsh.model.mesh.removeDuplicateNodes` so it could patch the connectivity afterwards. 
There is also an gencon function via the uniquetol, but this would be less robust as the algorithm inside gencon.
