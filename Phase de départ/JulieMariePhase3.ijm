//apres calcul et extraction des bassins, cette phase extrait l'image stack des bassins
//extration depuis le plugin : MorpholibJ-Morphological Segmentation.
//in : MorpholibJ-Morphological Segmentation doit etre en attente
//out : stack des bassins nommée : "ADD-catchment-basins.tif"
//temps d'exécution ~3 min pour un stack 1003x1433x334 images 16 bits
//ver1.0

selectWindow("Morphological Segmentation");
call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat", "Catchment basins");
wait(2000);
//selectWindow("ADD-catchment-basins.tif");
wait(2000);
call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
wait(2000);
