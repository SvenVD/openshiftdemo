DEMO for applications builds

Builds can be:
* dockerfiles that download a war or rpm and package it in a new container
* S2I build process with an S2I builder image
* just a copy of the code into the application image if the code does not need to be compiled or build ( the demo show the latter)
* combination

If applications need config this should be fetched at runtime of the container