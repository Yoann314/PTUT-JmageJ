max=getNumber("Choisir le max d'intensité possible dans une cellule", 0);
rouge=newArray(256);
vert=newArray(256);
bleu=newArray(256);
selectWindow("Results_Finished.csv");
coef1=255/max
for (i = 1; i < Table.size ; i++) {
	l=Table.get("Intensity", i);
	if(l==0){
		rouge[i]=89;
		vert[i]=89;
		bleu[i]=215;
	}
	if(l==max){
		rouge[i]=255;
		vert[i]=0;
		bleu[i]=0;
	}
	else {
		a=(max*coef1)-(l*coef1);
		rouge[i]=a;
		vert[i]=0;
		bleu[i]=0;
	}

}
setLut(rouge, vert, bleu);
Array.show(rouge,vert,bleu);

