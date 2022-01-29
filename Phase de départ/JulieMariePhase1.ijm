//phase 1 du worflow JulieMarie
//il y a 7 phases
//in : image avec le signal des contours ouverte (488 nm)
//attention le contraste doit etre suffisament elevé fond autour de NG=10
//utiliser image adjust contrast si necessaire
//out: meme stack filtré
//temps d'exécution ~30 min pour 1003x1433x334 images 16 bits
//ver1.0

name=getTitle();
run("Duplicate...", "title=488 duplicate");
run("Gaussian Blur...", "sigma=1 stack");
run("Subtract Background...", "rolling=50 stack");
run("Anisotropic Anomalous Diffusion 2D Filter", "apply anomalous=1.0000 condutance=15.0000 time=0.1250 number=5 edge=Exponential");
rename("ADD.tif");
selectWindow(name);
close();