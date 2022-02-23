

max=getNumber("Choisir le max d'intensité possible dans une cellule", 0);
rouge=newArray(256);
vert=newArray(256);
bleu=newArray(256);
selectWindow("Results_2.csv");
for (i = 0; i < 256; i++) {
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
		a=max-l;
		r=255%a;
		d=(255-r)/a;
		rouge[i]=255-d;
		vert[i]=0;
		bleu[i]=0;
	}

}
setLut(rouge, vert, bleu);
Array.show(rouge,vert,bleu);

