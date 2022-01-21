//Scan Results tab and add a column with the Cell label for each X,Y position
//in: 	image stack "bassin-filtered" : stack of cell in gray level labeled and size filtered (from phase 4)
//		Results tab with X,Y coordonates and Slice position
//out : index of Cell number and count of spots in each Cell label
//ver1.1

selectWindow("bassin-filtered.tif");
for (row = 0; row < nResults; row++) {
	x=floor(getResult("X", row));
	y=floor(getResult("Y", row));
	setSlice(floor(getResult("Slice", row)));
	setResult("CellNumber", row, getPixel(x, y));
}

//This part count for each cell the number of dots included
SpotInCellsCount=newArray(nResults);
n=SpotInCellsCount.length;
Array.fill(SpotInCellsCount,0);

for (row = 0; row < n; row++) {
	a=getResult("CellNumber", row);
	SpotInCellsCount[a]++;
}
indexOfCell=Array.getSequence(n);
Array.show(indexOfCell,SpotInCellsCount);
