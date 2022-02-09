
Dialog.create("Conditions d'utilisation :");
Dialog.addMessage("    -Veuillez créer un dossier pour chaque embryon dans lequel se trouvera 3 dossiers pour chaque stade.(T1,T2 et T3) \n \n    -Dans chaque dossier stade, doit se trouver l'image 488 et l'image 561. Ainsi, il ne doit contenir que 2 éléments (488 et 561) \n \nPar exemple : \nEmbryon1/T1/488             ...pour l'embryon 1 au stade 1.");
Dialog.show();



repertoire_image=getDir("Veuillez séléctionner le repertoire contenant les images"); 	//récupération du chemin menant au repertoire des image, ex: C:\Users\nd202\Desktop\TEST\EMBRYON 1\T1\
chemin_stade=File.getParent(repertoire_image);  //récupération des repertoire contenant les différent stades et embryons
chemin_embryon=File.getParent(chemin_stade);

embryon=getFileList(chemin_embryon);	// récupération de la liste des dossier embryon et stade
stade=getFileList(chemin_stade);		//par exemple dans embryon si on a que 2 embryons, array.show(embryon) retourne EMBRYON 1/
																											//			EMBRYON 2/

Array.sort(stade);			//trie la liste des embryons au cas où il seraientt dans le désordre
Array.sort(embryon);

l=lengthOf(embryon);		//nombre d'embryons
for (i=0;i<l;i++){	
	
	chemin_stade=chemin_embryon+"\\"+embryon[i];	//chemin_stade = chemin pour accéder au stade pour chaque embryons
	
	for (j=0;j<3;j++){
													
		chemin_image=replace(chemin_stade+stade[j], "/", "\\");		 //chemin_image = C:\Users\nd202\Desktop\TEST\EMBRYON [i]\T[j]\
		
		image=replace(chemin_image, "\\", "\\\\");			//image = C:\\Users\\nd202\\Desktop\\TEST\\EMBRYON [i]\\T[j]\\
															//utilisation de double anti slash car sinon pour de specialiser le caractère '\' (sinon open() ne fonctionne pas)
		
		nb=getFileList(image);		//nb contient le nom des fichiers images

		Array.sort(nb);		// on met l'image 488 en premier 
		if (lengthOf(nb) == 2) {  // par précaution, il faut qu'il y ait seulement les images 488 et 561 dans le dossier 
			
			open(image+nb[1]);

			open(image+nb[0]);//ouverture de 488 en dernier

			Poissons_zebre();

			Table.save(image);

			close("*");		//fermeture des images une fois le programme exécuté
			
			//appeler la fonction poisson zebre puis fermer les images

		}
		else {
			showMessage("Le repertoire contenant les images doit contenir seulement 488 et 561 !");
		}
	}
}



function Phase1(){

	//in : image avec le signal des contours ouverte (488 nm)
	//attention le contraste doit etre suffisament elevé fond autour de NG=10
	//utiliser image adjust contrast si necessaire
	//out: meme stack filtré

	selectWindow("488.tif");
	run("Gaussian Blur...", "sigma=1 stack");
	run("Subtract Background...", "rolling=50 stack");
	run("Anisotropic Anomalous Diffusion 2D Filter", "apply anomalous=1.0000 condutance=15.0000 time=0.1250 number=5 edge=Exponential");
	rename("ADD.tif");
	selectWindow("488.tif");
	close();
}

function Phase2(){

	//in : image avec le signal des contours fitres par la macro phase1 (normalement son nom est : ADD
	//out:  MorpholibJ-Morphological Segmentation plugin ouvert en attente de l'extraction des bassins (macro phase 3)
	//le mieux est de travailler en 8 bit apres avoir modifié le contraste
	
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

function Phase3(){

	//apres calcul et extraction des bassins, cette phase extrait l'image stack des bassins
	//extration depuis le plugin : MorpholibJ-Morphological Segmentation.
	//in : MorpholibJ-Morphological Segmentation doit etre en attente
	//out : stack des bassins nommée : "ADD-catchment-basins.tif"
	
	selectWindow("Morphological Segmentation");
	call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat", "Catchment basins");
	call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
	selectWindow("Morphological Segmentation");
	close();
}

function Phase4(){

	//Filtrage des cellules en fonction de leur surface,
	//les cellules de moins de 200 pixels sont retirées
	//in: image "ADD-catchment-basins" 32 bits issue de macro phase 3
	//out : image "bassin-filtered" 16 bits

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
	//clean
	selectWindow("Mask of mask");
	close();
	selectWindow("mask");
	close();
	selectWindow("ADD-catchment-basins.tif");
	close();
}

function Phase5(){

	//prominence p can be change in  function of image quality
	//Macro qui execute un find Maxima pour toutes les images d'un stack
	//Il s'agit de l'ancienne macro :"Finddaxima-dilateOnStack.ijm "
	//in: ouvrir l'image acquise sur canal 561 nm qui contient, outre les contours, mais les dots a repérer.
	//out : image stack des dots nommée: "Stack" en binaire

	// showMessage("l'image acquise sur canal 561 nm doit etre ouverte-marquage avec les ARNs et les contours");
	selectWindow("561.tif");
	p = 30;
	getDimensions(width, height, channels, slices, frames); // Returns the dimensions of the current image.
	setSlice((floor(slices/2))); // Affiche la nième tranche/slices de la pile active (celle du milieu ici).
	run("Enhance Contrast", "saturated=0.35"); // améliorer le contraste local d'une image
	run("8-bit");
	run("Gaussian Blur...", "sigma=2 stack"); // réduit le bruit
	
	n = nSlices; // Returns the number of images in the current stack.
	name = getTitle();
	for(i=1;i<=n;i++){
		selectWindow(name);
		setSlice(i); // Affiche la iième tranche de la pile active.
		run("Find Maxima...", "prominence="+p+" output=[Single Points]");
		}
	//Make stack from image named with "Maxima"
	run("Images to Stack", "method=[Copy (center)] name=Stack.tif title=Maxima use"); // Images to Stack
	run("Options...", "iterations=1 count=1 black do=Dilate stack");
}

function Phase6(){

	//utilise la methode 3D object counter de Fabrice Cordelière 
	//this macro will find all centroid in 3D, and display a Results tab with they coordonnates
	//in: image named "Stack.tif" of dilated maximas get from phase 5
	//out: Results tab with maximas coordonates
	
	selectWindow("Stack.tif");
	rename("origine");
	run("Set Scale...", "distance=0 known=0 unit=pixel");
	run("3D Objects Counter", "threshold=128 slice=48 min.=3 max.=64995840 centroids");
	selectWindow("Centroids map of origine");
	setThreshold(1, 65534); // Définit les niveaux de seuil inférieur et supérieur.
	setOption("BlackBackground", true); // Active/désactive l'option "Fond noir".
	run("Convert to Mask", "method=Default background=Dark black");
	run("Set Measurements...", "centroid stack redirect=None decimal=3");
	run("Analyze Particles...", "pixel display clear stack"); // le tabeau Results aces les coordonée des spots (en pixel)
	
	//clean
	selectWindow("origine");
	close();
	selectWindow("Centroids map of origine");
	close();
}

function Phase7(){

	//Scan Results tab and add a column with the Cell label for each X,Y position
	//in: 	image stack "bassin-filtered" : stack of cell in gray level labeled and size filtered (from phase 4)
	//		"Results" tab with X,Y coordonates and Slice position
	//out : index of Cell number and count of spots in each Cell label

	selectWindow("bassin-filtered.tif");
	for (row = 0; row < nResults; row++){
		x = floor(getResult("X", row));
		y = floor(getResult("Y", row));
		setSlice(floor(getResult("Slice", row)));
		setResult("CellNumber", row, getPixel(x, y));
		// a la fin nResult = 665
	}
	
	//This part count for each cell the number of dots included
	SpotInCellsCount = newArray(nResults);
	n = SpotInCellsCount.length;
	Array.fill(SpotInCellsCount,0); // initialisation du tableau à 0 (pour les 665 lignes)
	
	for (row = 0; row < n; row++) { // compte le nombre de point/CellNumber
		a = getResult("CellNumber", row);
		SpotInCellsCount[a]++;
	}
	indexOfCell = Array.getSequence(n);
	Array.show("Nombre de Spot / cellule",indexOfCell,SpotInCellsCount);
	// if macro erreur fenètre ouverte --> afficher un message qui explique l'erreur (c'est dû aux mauvais résultats)
}

function Poissons_zebre(){
	print("#### Début Phase 1 ####");
	Phase1();
	print("#### Phase 1 terminée ####");
	print("#### Début Phase 2 ####");	
	Phase2();
	print("#### Phase 2 terminée ####");
	print("#### Début Phase 3 ####");	
	Phase3();
	print("#### Phase 3 terminée ####");
	print("#### Début Phase 4 ####");	
	Phase4();
	print("#### Phase 4 terminée ####");
	print("#### Début Phase 5 ####");
	Phase5();
	print("#### Phase 5 terminée ####");	
	Phase6();
	print("#### Phase 6 terminée ####");
	Phase7();
	print("#### Phase 7 terminée ####");
	selectWindow("Results");

SpotInCellsCount=newArray(nResults); //créer une array pour chaque colonne, extrait les données de table results dans chaque array
CellValue=newArray(nResults);
x=newArray(nResults);
y=newArray(nResults);
slice=newArray(nResults);
Array.fill(SpotInCellsCount,1);
Table.sort("CellNumber"); //trie de table results pour pouvoir obtenir les sommes cumulées dans SpotInCellsCount

for (i = 0; i < nResults ; i++) {
	slice[i]=getResult("Slice", i);
	CellValue[i]=getResult("CellNumber", i); //extraction des numéros des cellules dans array CellValue
	x[i]= getResult("X", i); //coordonnée x et y des spots
	y[i]= getResult("Y", i); 
	
	if(CellValue[i]==0){ // les spot dans la cellule de valeur 0 ne sont pas utilisés (à modifier peut etre)
		SpotInCellsCount[i]="NaN";
	}
	if(SpotInCellsCount[i]!="NaN"){ //comptage des spot contenus dans chaque cellule, le comptage final se trouve dans la derniere ligne avec la valeur CellValue d'origine(à améliorer)
		selectWindow("Nombre de Spot / cellule");
		j=Table.get("SpotInCellsCount", CellValue[i]);
		selectWindow("Results");
		SpotInCellsCount[i]=j;
	}
}

Array.show("Results",CellValue,x,y,slice,SpotInCellsCount); //affichage des arrays dans results (écrase les donnés qui etaient de base dans results)


//ajouter la macro macrolut8bit quand elle sera terminée
}

