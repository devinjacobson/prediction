export CLASSPATH=$CLASSPATH:/Users/hoge/Desktop/axis-1_4/lib/axis.jar:/Users/hoge/Desktop/axis-1_4/lib/jaxrpc.jar:/Users/hoge/Desktop/axis-1_4/lib/saaj.jar:/Users/hoge/Desktop/axis-1_4/lib/commons-logging-1.0.4.jar:/Users/hoge/Desktop/axis-1_4/lib/commons-discovery-0.2.jar:/Users/hoge/Desktop/axis-1_4/lib/wsdl4j-1.5.1.jar:/Users/hoge/Desktop/xerces-2_8_0/resolver.jar:/Users/hoge/Desktop/xerces-2_8_0/xercesImpl.jar:/Users/hoge/Desktop/xerces-2_8_0/xml-apis.jar
javac Test.java
java org.apache.axis.wsdl.Java2WSDL -o test.wsdl -l "http://rubato.nic.uoregon.edu:4063/SOAP" -n "urn:Test" Test
