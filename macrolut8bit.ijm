//cette macro associe une LUT pour une image en fonction de la colonne "SpotInCellsCount" de arrays.csv
//Les cellules sont distinguées par Indexofcell (value) dans le tableau arrays


huitbit = getBoolean("L'image est de type 8-bits ?");
if(huitbit == true) {
	rouge=newArray(256);	//création d'arrays pour chaque couleur primaire
	vert=newArray(256);		//taille 256 car 255 niveau pour une LUT
	bleu=newArray(256);
	selectWindow("Arrays.csv");
	rowmax=0;
	for (i=1;i<256;i++){
		if(rowmax<Table.get("SpotInCellsCount", i){
			rowmax=Table.get("SpotInCellsCount",i)
		}
	for (i = 0; i < 256; i++) {
		row=Table.get("SpotInCellsCount", i);	//attribue à 3 niveaux de couleur en fonction du nombre de cluster indiqué dans "SpotInCellsCount"
		print(row);
		if (row==0) {
			rouge[i]=89;	 //Noir pour les cellules ayants 0 spot
			vert[i]=89;
			bleu[i]=215;
		}
		else if (row==rowmax){			//bleu clair pour les cellules ayant le plus de spots
			rouge[i]=255;
			vert[i]=0;
			bleu[i]=0;
		}
		else{                       // Un bleu adapté en fonction du nombre de spot. 
			a=rowmax-row;
			r=255%a;
			d=255-r/a;
			rouge[i]=255-d;
			vert[i]=0;
			bleu[i]=0;
		}
	}
//selectwindow("nom");
setLut(rouge, vert, bleu);
}
Array.show(rouge,vert,bleu);