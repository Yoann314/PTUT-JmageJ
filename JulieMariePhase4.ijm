//phase 4
//Filtrage des cellules en fonction de leur surface
//ici les cellules de moins de 200 pixels sont retirées
//modifier la ligne 16 si l'on veux filtrer différemment
//in: image "ADD-catchment-basins" 32 bits issue de macro phase 3
//out : image "bassin-filtered" 16 bits
//ver 1.0


run("Options...", "iterations=1 count=1 black do=Nothing");
run("Set Measurements...", "area centroid perimeter shape stack limit redirect=None decimal=3");
run("Duplicate...", "title=mask duplicate");
run("Subtract...", "value=1 stack");
run("16-bit");
resetMinAndMax();
setThreshold(1, 65535);
run("Analyze Particles...", "size=200-Infinity show=Masks exclude stack");
run("Invert LUT");
run("16-bit");
run("Multiply...", "value=400.000 stack");
imageCalculator("AND create stack", "Mask of mask","ADD-catchment-basins.tif");
rename("bassin-filtered");
//clean
selectWindow("Mask of mask");
close();
selectWindow("mask");
close();
