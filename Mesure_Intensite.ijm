selectWindow("Results");
Table.rename("Results", "Results_complet");
nombre_ligne = Table.size;
title = "[Progress]";
run("Text Window...", "name="+ title +" width=30 height=3 monospaced");
run("Add...", "value=1 stack"); // on ajoute +1 à toutes les valleurs de pixel pour éviter d'en avoir un noir. 
selectWindow("561.tif");
snapshot();

for (row = 0; row < nombre_ligne; row++){

	print(title, "\\Update:"+floor(row/nombre_ligne*100)+"/"+100+" ("+(floor(row/nombre_ligne*10000))/100+"%)\n"+getBar(row, nombre_ligne));
	
	selectWindow("Results_complet");
	// prend les valeurs  dans les colonne X, Y et Z (Slice) à la ligne row
	x = Table.get("X", row);
	y = Table.get("Y", row);
	z = Table.get("Slice", row);
	Spot_in_cell = Table.get("CellNumber", row);
	
	if (Spot_in_cell != 0){ // Si les coordonnées du spot sont dans une cellule

		selectWindow("561.tif");
		setSlice(z);
		valeur_pixel_cible = getValue(x, y);
		
		if (valeur_pixel_cible != 0){ // si ≠ de 0 --> on à pas encore compté ce spot
			// faire -11 sur les x et y pour le centrer
			makeOval(x-11, y-11, 20, 20); // crée un cercle autour de chaque spot (prend en entrée des pixels)
			getHistogram(0, counts, 65536);
			getThreshold(lower, upper);
			setAutoThreshold();
			run("Set Measurements...", "mean integrated limit redirect=None decimal=3");
			run("Measure");
			Valeur_intensite = getResult("Mean", Table.getSelectionEnd); //Table.getSelectionEnd - Returns the index of the last selected row in the current table, or -1 if there is no selection. 
			selectWindow("Results_complet");
			Table.set("Intensity", row, Valeur_intensite); // rajoute la valeur intensité au tableau
			setForegroundColor(0, 0, 0); 
			run("Fill", "slice"); // marque le spot mesurer en noir (0,0,0)
		}
		
		if (valeur_pixel_cible == 0){ // si = de 0 --> on à déjà compté ce spot
			selectWindow("Results_complet");
			Table.set("Intensity", row, NaN);
		}	
	}
	if (Spot_in_cell == 0){
		selectWindow("Results_complet");
		Table.set("Intensity", row, NaN);
	}
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