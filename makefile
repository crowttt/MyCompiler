all: myCompilerLexer.java myCompilerLexer.java  myCompiler_test.class test1.j test2.j test3.j

myCompilerLexer.java myCompilerParser.java: myCompiler.g
	java -cp ./antlr-3.5.2-complete.jar  org.antlr.Tool myCompiler.g

myCompiler_test.class: myCompilerLexer.java myCompilerParser.java myCompiler_test.java
	javac -cp ./antlr-3.5.2-complete.jar  myCompiler_test.java myCompilerLexer.java myCompilerParser.java

test1.j: myCompiler_test.class test1.c
	java -cp ./antlr-3.5.2-complete.jar:. myCompiler_test benchmark/test1.c  > test1.j

test2.j: myCompiler_test.class test2.c
	java -cp ./antlr-3.5.2-complete.jar:. myCompiler_test benchmark/test2.c  > test2.j

test3.j: myCompiler_test.class test3.c
	java -cp ./antlr-3.5.2-complete.jar:. myCompiler_test benchmark/test3.c  > test3.j

clean:
	rm *.class *.tokens *.j myCompilerLexer.java myCompilerParser.java