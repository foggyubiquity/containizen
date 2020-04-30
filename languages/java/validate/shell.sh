javac HelloWorld/Main.java
jar --create --file=containizen.jar --main-class=HelloWorld.Main HelloWorld/Main.class
java -jar containizen.jar
