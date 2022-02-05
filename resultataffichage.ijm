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
