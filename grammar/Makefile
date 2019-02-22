java: clean
	antlr4 ALF.g4 -o java
	cd java && javac ALF*.java -cp /usr/share/java/antlr-4.7.2-complete.jar

show_java: java
	cd java && grun ALF start -gui ../../examples/samplelibrary.alf

trace_java: java
	cd java && grun ALF start -trace ../../examples/samplelibrary.alf

clean:
	rm -rf java
