for (row = 0; row < nResults; row++){
	//row = 234 // pour tester sur une ligne et 	
	selectWindow("Results");
	// prend les valeurs  dans les colonne X, Y et Z (Slice) à la ligne row
	x = getResult("X", row);
	y = getResult("Y", row);
	z = getResult("Slice", row);

	selectWindow("561.tif");
	setSlice(z);
	// faire -11 sur les x et y pour le centrer
	makeOval(x-11, y-11, 20, 20); // crée un cercle autour de chaque spot (prend en entrée des pixels)

	getHistogram(0, counts, 65536);
	getThreshold(lower, upper);
	setAutoThreshold();
	// https://imagej.nih.gov/ij/docs/menus/analyze.html#set
	run("Set Measurements...", "mean centroid perimeter stack limit nan redirect=561.tif decimal=3");
}