//ce code enleve le bruit sur l'axe des Z ou du moins il essaye...

//augmentation du contraste, pour mieux différencier le bruit du signal :
name=getTitle();
selectWindow(name);

run("Make Binary", "method=Default background=Dark black");
run("Enhance Contrast...", "saturated=0.01 normalize process_all use");

value=newArray();
count=newArray();
proportion_noir=newArray(nSlices+1);


for (i = 1; i <= nSlices; i++) {	 //pour chaque slice :
    setSlice(i);
	run("Histogram","slice");		//histograme contient deux valeur 0 ou 255 pour noir ou blanc
	Plot.getValues(value,count);
	noir=count[0];
	blanc=count[255];
	proportion_noir[i]=noir/(blanc+noir);
	close("Histo*");
	seuil=0.725; 		//seuil fixé arbitrairement pour le moment mais il faut pouvoir le calculer car il risque d'etre faux sur d'autres stacks
	if (proportion_noir[i]>seuil){
		print(i);
		//run("Delete Slice");
	}
}

Array.show("Results",proportion_noir);


/* calcul de l'intensité moyenne de chaque stack:
run("Set Measurements...", "mean standard stack redirect=None decimal=3");

run("Measure Stack...");
intensity=newArray(nResults);
deviation=newArray(nResults);
S=newArray(nResults);
for (i = 0; i < nResults; i++) {	//pour chaque slice :
	
	intensity[i]=getResult("Mean", i);
	
	S[i]=getResult("Slice", i);
}

Array.getStatistics(intensity, min, max, mean, stdDev);

for (i = 0; i < nResults; i++) {
	intensity[i]=(intensity[i]-min)/stdDev;
	if (intensity[i]<= 0.5) {
		print(S[i]);
	}
}


close("Results");

Array.show("Results",intensity);
*/
