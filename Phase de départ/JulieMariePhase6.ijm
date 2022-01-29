//phase6 du workflow Julie and Marie
//Attention cette phase est longue 15 min pour 1003x1433x334 
//utilise la methode 3D object counter de Fabrice Cordelière 
//this macro will find all centroid in 3D, and display a Results tab with they coordonnates
//in: image named "Stack" of dilated maximas get from phase 5
//out: Results tab with maximas coordonates
//ver 1.0

//close results tab
if(isOpen("Results")){
	selectWindow("Results");
	run("Close");
	}
rename("origine");
//Remove the scale if exist
run("Set Scale...", "distance=0 known=0 unit=pixel");
run("3D Objects Counter", "threshold=128 slice=48 min.=3 max.=64995840 centroids");
selectWindow("Centroids map of origine");
setThreshold(1, 65534);
setOption("BlackBackground", true);
run("Convert to Mask", "method=Default background=Dark black");
run("Set Measurements...", "centroid stack redirect=None decimal=3");
run("Analyze Particles...", "display clear stack");

//clean
selectWindow("origine");
close();
selectWindow("Centroids map of origine");
close();