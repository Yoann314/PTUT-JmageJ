selectWindow("Results");
Table.rename("Results", "Results_complet");
nombre_ligne = Table.size;
title = "[Progress]";
run("Text Window...", "name="+ title +" width=25 height=3 monospaced");

//run("Add...", "value=1 stack");

for (row = 0; row < 30; row++){ // 30 pour test mais si non --> nombre_ligne

	print(title, "\\Update:"+row+"/"+100+" ("+(row*100)/100+"%)\n"+getBar(row, 30));

	//row = 11; // pour tester sur une ligne et 	
	selectWindow("Results_complet");
	// prend les valeurs  dans les colonne X, Y et Z (Slice) à la ligne row
	x = Table.get("X", row);
	y = Table.get("Y", row);
	z = Table.get("Slice", row);

	selectWindow("561.tif");
	setSlice(z);
	valeur_pixel_cible = getValue(x, y);
	
	if (valeur_pixel_cible != 0){ // si ≠ de 0 --> on a pas encore compté ce spot
		// faire -11 sur les x et y pour le centrer
		makeOval(x-11, y-11, 20, 20); // crée un cercle autour de chaque spot (prend en entrée des pixels)
	
		getHistogram(0, counts, 65536);
		getThreshold(lower, upper);
		setAutoThreshold();
		run("Set Measurements...", "mean integrated limit redirect=None decimal=3");
		run("Measure");
		
		Valeur_intensite = getResult("Mean", row);
		selectWindow("Results_complet");
		Table.set("Intensity", row, Valeur_intensite);
		
		setForegroundColor(0, 0, 0);
		run("Fill", "stack");
	}
	
	if (valeur_pixel_cible == 0){
		makeOval(x-11, y-11, 20, 20); // crée un cercle autour de chaque spot (prend en entrée des pixels)
		getHistogram(0, counts, 65536);
		getThreshold(lower, upper);
		setAutoThreshold();
		run("Set Measurements...", "mean integrated limit redirect=None decimal=3");
		run("Measure");
		
		selectWindow("Results_complet");
		Table.set("Intensity", row, NaN);
	}
}
for (row = 0; row < 30; row++) {
		Valeur_intensite = getResult("Mean", row);
		selectWindow("Results_complet");
		Table.set("Intensity", row, Valeur_intensite);

}

print(title, "\\Close");

function getBar(p1, p2){
	    n = 20;
	    bar1 = "--------------------";
	    bar2 = "********************";
	    index = round(n*(p1/p2));
	    if (index<1) index = 1;
	    if (index>n-1) index = n-1;
	    return substring(bar2, 0, index) + substring(bar1, index+1, n);
	}





/*
ajouter la valeur 1 a tous les pixels de l'image
