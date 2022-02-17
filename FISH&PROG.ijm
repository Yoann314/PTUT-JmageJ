
Dialog.create("Conditions d'utilisation :");
Dialog.addMessage("    -Veuillez créer un dossier pour chaque embryon dans lequel se trouvera 3 dossiers pour chaque stade.(T1,T2 et T3) \n \n    -Dans chaque dossier stade, doit se trouver l'image 488 et l'image 561. Ainsi, il ne doit contenir que 2 éléments (488 et 561) \n \nPar exemple : \nEmbryon1/T1/488             ...pour l'embryon 1 au stade 1.");
Dialog.show();

repertoire_image=getDir("Veuillez séléctionner le repertoire contenant les images"); 	// Récupération du chemin menant au repertoire des image, ex: C:\Users\nd202\Desktop\TEST\EMBRYON 1\T1\
chemin_stade=File.getParent(repertoire_image);  // Récupération des repertoire contenant les différent stades et embryons
chemin_embryon=File.getParent(chemin_stade);

embryon=getFileList(chemin_embryon);	// Récupération de la liste des dossier embryon et stade
stade=getFileList(chemin_stade);		// Par exemple dans embryon si on a que 2 embryons, array.show(embryon) retourne EMBRYON 1/
																											//			EMBRYON 2/

Array.sort(stade);			// Trie la liste des embryons au cas où il seraientt dans le désordre
Array.sort(embryon);

l = lengthOf(embryon);		// Nombre d'embryons
for (i=0; i<l; i++) {	
	
	chemin_stade=chemin_embryon+"\\"+embryon[i];	// Chemin_stade = chemin pour accéder au stade pour chaque embryons
	
	for (j=0; j<3; j++) {
													
		chemin_image = replace(chemin_stade + stade[j], "/", "\\");		 // Chemin_image = C:\Users\nd202\Desktop\TEST\EMBRYON [i]\T[j]\
		
		image = replace(chemin_image, "\\", "\\\\");			// Image = C:\\Users\\nd202\\Desktop\\TEST\\EMBRYON [i]\\T[j]\\
															// Utilisation de double anti slash car sinon pour de specialiser le caractère '\' (sinon open() ne fonctionne pas)
		
		nb = getFileList(image);		// Nb contient le nom des fichiers images

		Array.sort(nb);		// On met l'image 488 en premier 
		if (lengthOf(nb) == 2) {  // Par précaution, il faut qu'il y ait seulement les images 488 et 561 dans le dossier 
			
			open(image + nb[1]); // Ouverture de l'image avec le canal 561

			open(image + nb[0]); // Ouverture de l'image avec le canal 488 (en dernier)

			Poissons_zebre();

			Table.save(image);

			close("*");		// Fermeture des images une fois le programme exécuté
			
			// appeler la fonction poisson zebre puis fermer les images

		}
		else {
			showMessage("Le repertoire contenant les images doit contenir seulement 488 et 561 !");
		}
	}
}



function Phase1() {

	// Pré-traite le l'image du canal 488 
	// Attention le contraste doit etre suffisament élevé, fond autour de NG=10
	// in : Image avec le signal des contours ouverte (488 nm)
	// out: Même stack filtré

	selectWindow("488.tif"); // à tej pour le prog final //////////////////////
	// open(image + nb[0]); // pour le programme final
	run("Gaussian Blur...", "sigma=1 stack");
	run("Subtract Background...", "rolling=50 stack");
	run("Anisotropic Anomalous Diffusion 2D Filter", "apply anomalous=1.0000 condutance=15.0000 time=0.1250 number=5 edge=Exponential");
	rename("ADD.tif");
	selectWindow(tif_488);
	close();
}

function Phase2() {

	// in : image avec le signal des contours fitres par la macro phase1 (normalement son nom est : ADD
	// out:  MorpholibJ-Morphological Segmentation plugin ouvert en attente de l'extraction des bassins (macro phase 3)
	// le mieux est de travailler en 8 bit apres avoir modifié le contraste
	
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
	
}

function Phase3() {

	// Apres calcul et extraction des bassins, cette phase extrait l'image stack des bassins.
	// Extration depuis le plugin : MorpholibJ-Morphological Segmentation.
	// in : MorpholibJ-Morphological Segmentation doit etre en attente
	// out : stack des bassins nommée : "ADD-catchment-basins.tif"
	
	selectWindow("Morphological Segmentation");
	call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat", "Catchment basins");
	call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
	selectWindow("Morphological Segmentation");
	close();
}

function Phase4() {

	// Filtrage des cellules en fonction de leur surface (les cellules de moins de 200 pixels sont retirées), de leur volume et de leur diamètre.
	// in: image "ADD-catchment-basins" 32 bits issue de macro phase 3
	// out : image "bassin-filtered" 16 bits et tableau des coordonnées des centroïdes des cellules et leur volume (result_1.csv)
	//       (Label,Volume,X_Centroid,Y_Centroid,Z_Centroid

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
	rename("bassin-filtered.tif");
	close("\\Others"); // Ferme tout sauf "bassin-filtered.tif".

	run("Analyze Regions 3D", "volume centroid surface_area_method=[Crofton (13 dirs.)] euler_connectivity=6");
	Table.rename("bassin-filtered-morpho", "Results_1.csv");
	Table.showRowNumbers(true);
	Table.renameColumn("Centroid.X", "X_Centroid");
	Table.renameColumn("Centroid.Y", "Y_Centroid");
	Table.renameColumn("Centroid.Z", "Z_Centroid"); 
}

function Phase5() {

	// Prominence p can be change in  function of image quality
	// Macro qui execute un find Maxima pour toutes les images d'un stack
	// Il s'agit de l'ancienne macro :"Finddaxima-dilateOnStack.ijm "
	// in: ouvrir l'image acquise sur canal 561 nm qui contient, outre les contours, mais les dots a repérer.
	// out : image stack des dots nommée: "Stack" en binaire

	selectWindow("561.tif"); // à tej pour le prog final //////////////////////
	// open(image + nb[1]); // Pour le programme final.
	p = 30;
	getDimensions(width, height, channels, slices, frames); // Returns the dimensions of the current image.
	setSlice((floor(slices/2))); // Affiche la nième slices de la pile active (celle du milieu ici).
	run("Enhance Contrast", "saturated=0.35"); // Améliore le contraste local d'une image.
	run("8-bit");
	run("Gaussian Blur...", "sigma=2 stack"); // Réduit le bruit.
	
	n = nSlices; // Returns the number of images in the current stack.
	name = getTitle();
	for(i = 1; i <= n; i++) {
		selectWindow(name);
		setSlice(i); // Affiche la iième tranche de la pile active.
		run("Find Maxima...", "prominence="+p+" output=[Single Points]");
		}
	// Make stack from image named with "Maxima".
	run("Images to Stack", "method=[Copy (center)] name=Stack.tif title=Maxima use"); // Images to Stack.
	run("Options...", "iterations=1 count=1 black do=Dilate stack");
	selectWindow("561.tif");
	close();
}

function Phase6() {

	// Utilise la methode 3D object counter de Fabrice Cordelière.
	// This macro will find all centroid in 3D, and display a Results tab with they coordonnates.
	// in: image named "Stack.tif" of dilated maximas get from phase 5
	// out: Results tab with maximas coordonates (Results)
	//		(X,Y,Slice)
	
	selectWindow("Stack.tif");
	rename("origine");
	run("Set Scale...", "distance=0 known=0 unit=pixel");
	run("3D Objects Counter", "threshold=128 slice=48 min.=3 max.=64995840 centroids");
	selectWindow("Centroids map of origine");
	setThreshold(1, 65534); // Définit les niveaux de seuil inférieur et supérieur.
	setOption("BlackBackground", true); // Active / désactive l'option "Fond noir".
	run("Convert to Mask", "method=Default background=Dark black");
	run("Set Measurements...", "centroid stack redirect=None decimal=3");
	run("Analyze Particles...", "pixel display clear stack"); // Création du tableau Results_2.csv avec les coordonées des clusters en pixel.
	selectWindow("bassin-filtered.tif");
	close("\\Others");
}

function Phase7() {

	// Scan Results tab and add a column with the Cell label for each X,Y position
	// in  : image stack "bassin-filtered" : stack of cell in gray level labeled and size filtered (from phase 4)
	//		"Results" tab with X,Y coordonates and Slice position
	// out : index of Cell number and count of spots in each Cell label (Nb_cluster_par_cell et Results --> Results_2.csv)
	//		 (indexOfCell,SpotInCellsCount)(X,Y,Slice,CellNumber)
	
	selectWindow("bassin-filtered.tif");
	for (row = 0; row < nResults; row++) {
		x = floor(getResult("X", row));
		y = floor(getResult("Y", row));
		setSlice(floor(getResult("Slice", row)));
		setResult("CellNumber", row, getPixel(x, y));
	}
	
	// This part count for each cell the number of dots included
	SpotInCellsCount = newArray(nResults);
	n = SpotInCellsCount.length;
	Array.fill(SpotInCellsCount,0); // Initialisation du tableau à 0 (pour les 665 lignes).
	
	for (row = 0; row < n; row++) { // Compte le nombre de cluster / CellNumber.
		a = getResult("CellNumber", row);
		SpotInCellsCount[a]++;
	}
	indexOfCell = Array.getSequence(n);
	Array.show("Nb_cluster_par_cell",indexOfCell,SpotInCellsCount);
	Table.rename("Results", "Results_2.csv");
	close("*");
}

function Mesure_intensite() {

	// Mesure l'intensitée de chaque cluster contenue dans une cellule.
	// in  : Results_2.csv et l'image acquise sur canal 561 nm
	// out : Results_2.csv avec les inensitées des clusters rajoutés
	//		 (X_Cluster,Y_Cluster,Z_Cluster,CellNumber,Intensity)

	open(image+nb[1]); // Reouvre l'image original sans le filtre appliquer à la phase 5.
	rename("561.tif");
	selectWindow("Results_2.csv"); // à tej pour le prog final //////////////////////
	nombre_ligne = Table.size;
	run("Add...", "value=1 stack"); // On ajoute +1 à toutes les valeurs de pixel pour éviter d'en avoir un noir. 
	
	for (row = 0; row < nombre_ligne; row++) {
		
		selectWindow("Results_2.csv");
		// Prend les valeurs dans les colonnes X, Y et Z (Slice) à la ligne row.
		x = Table.get("X", row);
		y = Table.get("Y", row);
		z = Table.get("Slice", row);
		Spot_in_cell = Table.get("CellNumber", row);
		
		if (Spot_in_cell != 0){ // Si les coordonnées du cluster sont dans une cellule.

			// selectWindow(tif_561); // Pour le programme final.
			selectWindow("561.tif");
			setSlice(z);
			valeur_pixel_cible = getValue(x, y);
			
			if (valeur_pixel_cible != 0){ // On a pas encore compté ce cluster.
				// Faire -11 sur les x et y pour centrer le cercle autour du cluster.
				makeOval(x-11, y-11, 20, 20); // Crée un cercle autour de chaque spot (prend en entrée des pixels).
				getHistogram(0, counts, 65536);
				getThreshold(lower, upper);
				setAutoThreshold();
				run("Set Measurements...", "mean integrated limit redirect=None decimal=3");
				run("Measure");
				Valeur_intensite = getResult("Mean", Table.getSelectionEnd); // Table.getSelectionEnd - Returns the index of the last selected row in the current table, or -1 if there is no selection. 
				selectWindow("Results_2.csv");
				Table.set("Intensity", row, Valeur_intensite); // Ajoute la valeur "Intensity" au tableau.
				setForegroundColor(0, 0, 0);
				run("Fill", "slice"); // Marque le cluster qui vient d'être mesurer en noir (0,0,0).
			}
			
			if (valeur_pixel_cible == 0) { // On a déjà compté ce cluster.
				selectWindow("Results_2.csv");
				Table.set("Intensity", row, NaN);
			}
		}

		if (Spot_in_cell == 0) { // Si les coordonnées du cluster ne sont pas dans une cellule.
			selectWindow("Results_2.csv");
			Table.set("Intensity", row, NaN);
		}
	}
	close();
	close("Results");
	selectWindow("Results_2.csv");
	Table.renameColumn("X", "X_Cluster");
	Table.renameColumn("Y", "Y_Cluster");
	Table.renameColumn("Slice", "Z_Cluster");
}

function Concatenation_Resultat() {

	// Concataine tous les resultas aquis dans les tableaux en un seul tableau.
	// Tous les tableaux sont stocké dans des vecteurs pour diminuer le temps de calcul.
	// in  : Nb_cluster_par_cell (csv), Results_1.csv et Results_2.csv
	// out : Results_Finished_1.csv contenant tous les resultats 
	//       (Cell_Value,Volume,X_Centroid,Y_Centroid,Z_Centroid,SpotInCellsCount,X_Cluster,Y_Cluster,Z_Cluster,Intensity)
	
	selectWindow("Nb_cluster_par_cell");
	nb_ligne_label = Table.size; // Stock dans la variable le nombre de lignes de la fenêtre ouverte.
	Label 		   = newArray(nb_ligne_label); // Il dois avoir une longeur egale à "Nb_cluster_par_cell" pour la suite
	
	selectWindow("Results_1.csv"); // Initialise les vecteurs représentant le tableau "Results_1.csv" (t pour temporaire)
	nb_ligne_1 = Table.size;
	// Créer un vecteur pour chaque colonnes avec "nb_ligne_1" nombre de lignes.
	Volumet 	= newArray(nb_ligne_1);
	X_Centroidt = newArray(nb_ligne_1);
	Y_Centroidt = newArray(nb_ligne_1);
	Z_Centroidt = newArray(nb_ligne_1);
	Table.sort("Label");
	for (row = 0; row < nb_ligne_1 ; row++) { // Extrait les données de "Results_1.csv" dans chaques vecteurs.
		Label[row] 			= Table.get("Label", row); 
		Volumet[row]		= Table.get("Volume", row); 
		X_Centroidt[row]	= Table.get("X_Centroid", row);
		Y_Centroidt[row]	= Table.get("Y_Centroid", row);
		Z_Centroidt[row]	= Table.get("Z_Centroid", row);
	}
	
	selectWindow("Nb_cluster_par_cell");
	nb_ligne = Table.size;
	indexOfCellt 		= newArray(nb_ligne);
	SpotInCellsCountt 	= newArray(nb_ligne);
	
	Volumett 	 = newArray(nb_ligne);
	X_Centroidtt = newArray(nb_ligne);
	Y_Centroidtt = newArray(nb_ligne);
	Z_Centroidtt = newArray(nb_ligne);
	
	Table.sort("indexOfCell"); // Trie le tableau "Nb_cluster_par_cell" en fonction de la colonne "indexOfCell".
	
	i = 0;
	for (row = 0; row < nb_ligne ; row++) {
		indexOfCellt[row] 		= Table.get("indexOfCell", row);
		SpotInCellsCountt[row] 	= Table.get("SpotInCellsCount", row);
	
		// Apposition de "Results_1" et "Nb_cluster_par_cell".
		if (indexOfCellt[row] != Label[i]) { // Si ils sont différent la cellules n'existe pas
			Volumett[row] 	  = NaN;
			X_Centroidtt[row] = NaN;
			Y_Centroidtt[row] = NaN;
			Z_Centroidtt[row] = NaN;
		}
			
		if (indexOfCellt[row] == Label[i]){ // Création du vecteur "Volumett,..." de même longueur que "indexOfCellt" avec les mêmes positions pour chaque index de cellules. 
			Volumett[row] 	  = Volumet[i];
			X_Centroidtt[row] = X_Centroidt[i];
			Y_Centroidtt[row] = Y_Centroidt[i];
			Z_Centroidtt[row] = Z_Centroidt[i];	
			i += 1;
		}
	} // Les vecteurs "Nombre de spot.." et "Results_1.csv" sont maintenant équivalents.
	
	// Création des vecteurs qui vont représenter le tabeau final
	selectWindow("Results_2.csv"); 
	nb_ligne_2 = Table.size;
	
	// Initialisation des vecteurs avec une longeur equivalente à "Results_2.csv".
	Volume 		= newArray(nb_ligne_2);
	X_Centroid 	= newArray(nb_ligne_2);
	Y_Centroid 	= newArray(nb_ligne_2);
	Z_Centroid 	= newArray(nb_ligne_2);
	
	indexOfCell 		= newArray(nb_ligne_2);
	SpotInCellsCount 	= newArray(nb_ligne_2);
	
	X_Cluster 			= newArray(nb_ligne_2);
	Y_Cluster 			= newArray(nb_ligne_2);
	Z_Cluster 			= newArray(nb_ligne_2);
	Cell_Value 			= newArray(nb_ligne_2);
	Intensity			= newArray(nb_ligne_2);
	
	selectWindow("Results_2.csv");
	Table.sort("CellNumber"); // Trie de tableau "Results_2.csv" pour obtenir les valeurs cumulées de SpotInCellsCount.
	
	for (row = 0; row < nb_ligne_2 ; row++) {
		X_Cluster[row] = Table.get("X_Cluster", row);
		Y_Cluster[row] = Table.get("Y_Cluster", row); 
		Z_Cluster[row] = Table.get("Z_Cluster", row);
		Cell_Value[row]= Table.get("CellNumber", row);
		Intensity[row] = Table.get("Intensity", row);
	
		SpotInCellsCount[row] = SpotInCellsCountt[Cell_Value[row]];
		Volume[row] 	   	  = Volumett[Cell_Value[row]];
		X_Centroid[row]  	  = X_Centroidtt[Cell_Value[row]];
		Y_Centroid[row]       = Y_Centroidtt[Cell_Value[row]];
		Z_Centroid[row]		  = Z_Centroidtt[Cell_Value[row]];
	}
	Array.show("Results_Finished_1.csv",Cell_Value,Volume,X_Centroid,Y_Centroid,Z_Centroid,SpotInCellsCount,X_Cluster,Y_Cluster,Z_Cluster,Intensity); // Construction du tableau final


	Table.set("Intensity", row, NaN)
	
// ajout des lignes manquante
// Table.deleteRows(firstIndex, lastIndex) - Supprime les lignes spécifiées.
}

function Poissons_zebre(){
	Phase1();	
	Phase2();
	Phase3();	
	Phase4();
	Phase5();
	Phase6();
	Phase7();
	Mesure_intensite();
	Concatenation_Resultat();
}