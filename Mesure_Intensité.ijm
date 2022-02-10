selectWindow("Results");
Table.rename("Results", "Results_complet");
nombre_ligne = Table.size
title = "[Progress]";
run("Text Window...", "name="+ title +" width=25 height=3 monospaced");

for (row = 0; row < 30; row++){ // 30 pour test mais si non --> nombre_ligne
	
	// Progress bar //
	print(title, "\\Update:"+row+"/"+100+" ("+(row*100)/100+"%)\n"+getBar(row, 30));
	wait(200);
	function getBar(p1, p2){
	    n = 20;
	    bar1 = "--------------------";
	    bar2 = "********************";
	    index = round(n*(p1/p2));
	    if (index<1) index = 1;
	    if (index>n-1) index = n-1;
	    return substring(bar2, 0, index) + substring(bar1, index+1, n);
	}
	// fin Progress bar //

	//row = 11; // pour tester sur une ligne et 	
	selectWindow("Results_complet");
	// prend les valeurs  dans les colonne X, Y et Z (Slice) à la ligne row
	x = Table.get("X", row-1);
	y = Table.get("Y", row-1);
	z = Table.get("Slice", row-1);

	selectWindow("561.tif");
	setSlice(z);
	valeur_pixel_cible = getValue(x, y);
	print(valeur_pixel_cible);
	
	if (valeur_pixel_cible != 0){ // si ≠ de 0 --> on a pas encore compté ce spot
		print("!= 0");
		print(row);
		// faire -11 sur les x et y pour le centrer
		makeOval(x-11, y-11, 20, 20); // crée un cercle autour de chaque spot (prend en entrée des pixels)
	
		getHistogram(0, counts, 65536);
		getThreshold(lower, upper);
		setAutoThreshold();
		// https://imagej.nih.gov/ij/docs/menus/analyze.html#set
		// getProfile();
		run("Set Measurements...", "mean redirect=561.tif decimal=3");
		run("Measure");
		selectWindow("Results");
		wait(2000);
		Valeur_intensite = getResult("Mean", row-1); ////////////////////////////
		selectWindow("Results_complet");
		Table.set("Intensity", row, Valeur_intensite);
		setForegroundColor(0, 0, 0);
		run("Fill", "stack");
	}
	if (valeur_pixel_cible == 0){
		print("= 0");
		print(row);
		selectWindow("Results_complet");
		Table.set("Intensity", row, NaN);
	}
}
print(title, "\\Close");



