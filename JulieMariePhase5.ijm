//JulieMariePhase5.ijm
//prominence p can be change in  function of image quality
//Macro qui execute un find Maxima pour toutes les images d'un stack
//Il s'agit de l'ancienne macro :"Finddaxima-dilateOnStack.ijm "
//in: ouvrir l'image acquise sur canal 561 nm qui contient, outre les contours, mais les dots a repérer.
//out : image stack des dots nommée: "Stack" en binaire
//ver 1.0

showMessage("l'image acquise sur canal 561 nm doit etre ouverte-marquage avec les ARNs et les contours");
p=30;
getDimensions(width, height, channels, slices, frames);
setSlice((floor(slices/2)));
run("Enhance Contrast", "saturated=0.35");
run("8-bit");
run("Gaussian Blur...", "sigma=2 stack");

n=nSlices;
name=getTitle();
for(i=1;i<=n;i++){
	selectWindow(name);
	setSlice(i);
	run("Find Maxima...", "prominence="+p+" output=[Single Points]");
	}
//Make stack from image named with "Maxima"
run("Images to Stack", "method=[Copy (center)] name=Stack title=Maxima use");
run("Options...", "iterations=1 count=1 black do=Dilate stack");

