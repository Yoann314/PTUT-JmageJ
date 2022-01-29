//phase 1 du worflow JulieMarie
//il y a 7 phases
//in : image avec le signal des contours ouverte (488 nm)
//attention le contraste doit etre suffisament elevé fond autour de NG=10
//utiliser image adjust contrast si necessaire
//out: meme stack filtré
//temps d'exécution ~30 min pour 1003x1433x334 images 16 bits
//ver1.0

function Phase1(){
	name=getTitle();
	run("Duplicate...", "title=488 duplicate");
	run("Gaussian Blur...", "sigma=1 stack");
	run("Subtract Background...", "rolling=50 stack");
	run("Anisotropic Anomalous Diffusion 2D Filter", "apply anomalous=1.0000 condutance=15.0000 time=0.1250 number=5 edge=Exponential");
	rename("ADD.tif");
	selectWindow(name);
	close();
	showText("### phase 1 terminée ###");
}

function Phase2(){
	selectWindow("ADD.tif");
	run("Morphological Segmentation");
	selectWindow("Morphological Segmentation"); // Activates the window with the title "Morphological Segmentation".
	wait(1000);
	call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=10.0", "calculateDams=true", "connectivity=6"); // Appele une méthode statique 
	// passant un nombre arbitraire d'arguments de chaîne et renvoyant une chaîne.
	log_index = -1;
	while (log_index == -1) {
		cont_log = getInfo("log"); //Returns the contents of the Log window, or "" if the Log window is not open.
		wait(2000);
		log_index = cont_log.indexOf("Whole");
	}
	print("##### fini #####");
	//if (fin_phase_1 = 1){
		//print("appeller la phase suivante");
	//}
	showText("### phase 2 terminée ###");
	wait(3000);
	close("Untilted");
}

function Phase3(){
	selectWindow("Morphological Segmentation");
	call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat", "Catchment basins");
	wait(2000);
	//selectWindow("ADD-catchment-basins.tif");
	wait(2000);
	call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
	wait(2000);
	selectWindow("Morphological Segmentation");
	close();
	showText("### phase 3 terminée ###");
	wait(3000);
	close("Untilted");
}

function Phase4(){
	selectWindow("ADD-catchment-basins.tif");
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
	showText("### phase 4 terminée ###");
	wait(3000);
	close("Untilted");
}

function Phase5(){
	selectWindow("561.tif");
	run("Duplicate...", "title=561.tif duplicate");
	p=30;
	getDimensions(width, height, channels, slices, frames);
	setSlice((floor(slices/2)));
	run("Enhance Contrast", "saturated=0.35");
	run("8-bit");
	run("Gaussian Blur...", "sigma=2 stack");
	
	n=nSlices;
	name=getTitle();
	for(i=1;i<=n;i++){
		selectWindow(name);
		setSlice(i);
		run("Find Maxima...", "prominence="+p+" output=[Single Points]");
		}
	//Make stack from image named with "Maxima"
	run("Images to Stack", "method=[Copy (center)] name=Stack title=Maxima use");
	run("Options...", "iterations=1 count=1 black do=Dilate stack");
	showText("### phase 5 terminée ###");
	wait(3000);
	close("Untilted");
}

function Phase6(){

	selectWindow("Stack");
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
	showText("### phase 6 terminée ###");
	wait(3000);
	close("Untilted");
}

function Phase7(){
	selectWindow("bassin-filtered");
	for (row = 0; row < nResults; row++) {
		x=floor(getResult("X", row));
		y=floor(getResult("Y", row));
		setSlice(floor(getResult("Slice", row)));
		setResult("CellNumber", row, getPixel(x, y));
	}
	
	//This part count for each cell the number of dots included
	SpotInCellsCount=newArray(nResults);
	n=SpotInCellsCount.length;
	Array.fill(SpotInCellsCount,0);
	
	for (row = 0; row < n; row++) {
		a=getResult("CellNumber", row);
		SpotInCellsCount[a]++;
	}
	indexOfCell=Array.getSequence(n);
	Array.show(indexOfCell,SpotInCellsCount);
	showText("### phase 7 terminée ###");
}

function Poissons_zebre(){
	

	Phase1();
	
	Phase2();
	
	Phase3();
	
	Phase4();
	
	Phase5();
	
	Phase6();
	
	Phase7();
}

Poissons_zebre();






