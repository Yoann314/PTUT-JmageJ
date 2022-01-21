//phase 2 du worflow JulieMarie
//il y a 7 phases
//in : image avec le signal des contours fitres par la macro phase1 (normalement son nom est : ADD
//out:  MorpholibJ-Morphological Segmentation plugin ouvert en attente de l'extraction des bassins (macro phase 3)
//le mieux est de travailler en 8 bit apres avoir modifié le contraste
//temps d'exécution ~45 min pour 1003x1433x334 images 16 bits
//ver1.0


selectWindow("ADD.tif");
run("Morphological Segmentation");
selectWindow("Morphological Segmentation");
wait(1000);
showText("Please, wait for a lot of min! \n did you have convert your stack to 8 bit  ?");
call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=10.0", "calculateDams=true", "connectivity=6");
