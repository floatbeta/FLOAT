CP=conf/:classes/:lib/*
SP=src/java/

/bin/mkdir -p classes/

javac -sourcepath $SP -classpath $CP -d classes/ src/java/nxt/*.java src/java/nxt/*/*.java src/java/fr/cryptohash/*.java || exit 1

/bin/rm -f float.jar 
jar cf float.jar -C classes . || exit 1
/bin/rm -rf classes

echo "float.jar generated successfully"
