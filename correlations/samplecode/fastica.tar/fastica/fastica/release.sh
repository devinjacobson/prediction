#! /bin/sh

version=${1}

src=src
doc=doc
rel=rel
tmp=tmp
bin=bin

java_home=/opt/jdk1.5.0
javac=${java_home}/bin/javac
jar=${java_home}/bin/jar
jarsigner=${java_home}/bin/jarsigner

mkdir -p ${rel}

${jar} cvf ${rel}/fastica-${version}.jar -C bin/ .
${jarsigner} ${rel}/fastica-${version}.jar fastica

cd ${src}
zip -R ../${rel}/fastica-${version}-src.zip '*.java'
cd ..

cd ${doc}
zip -R ../${rel}/fastica-${version}-doc.zip '*'
cd ..

