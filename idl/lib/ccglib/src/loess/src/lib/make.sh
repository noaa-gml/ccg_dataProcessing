cp ../loess*.o ./
cp ../misc.o ./
cp ../support/*.o ./

ar r libloess.a *.o
