//phase 2 du worflow JulieMarie
//il y a 7 phases
//in : image avec le signal des contours fitres par la macro phase1 (normalement son nom est : ADD
//out:  MorpholibJ-Morphological Segmentation plugin ouvert en attente de l'extraction des bassins (macro phase 3)
//le mieux est de travailler en 8 bit apres avoir modifié le contraste
//temps d'exécution ~45 min pour 1003x1433x334 images 16 bits
//ver1.0

function Morpho_Seg(){
	selectWindow("ADD.tif");
	run("Morphological Segmentation");
	selectWindow("Morphological Segmentation"); // Activates the window with the title "Morphological Segmentation".
	wait(1000);
	showText("Please, wait for a lot of min! \n did you have convert your stack to 8 bit  ?");
	call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=10.0", "calculateDams=true", "connectivity=6"); // Appele une méthode statique 
	// passant un nombre arbitraire d'arguments de chaîne et renvoyant une chaîne.
	log_index = -1;
	i = 0;
	while (log_index == -1) {
		cont_log = getInfo("log"); //Returns the contents of the Log window, or "" if the Log window is not open.
		wait(2000);
		log_index = cont_log.indexOf("Whole");
		print(i++);
	}
	print("##### fini #####");
	//if (fin_phase_1 = 1){
		//print("appeller la phase suivante");
	//}

}

Morpho_Seg();

//if (startsWith(cont_log , "Whole")){