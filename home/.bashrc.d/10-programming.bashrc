# Git
source /usr/share/bash-completion/completions/git
__git_complete g __git_main

# Java
export JAVA_HOME=/usr/lib/jvm/default
export NASHORN_HOME=$JAVA_HOME/bin
export M2_HOME=/usr/share/maven
export M2=$M2_HOME/bin
export MAVEN_OPTS="-Xmx2048m -Xms512m -XX:MaxPermSize=312M -XX:ReservedCodeCacheSize=128m -Dsun.lang.ClassLoader.allowArraySyntax=true -ea -Dfile.encoding=UTF-8"
export MAVEN_JMX="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=6969 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"

# clojure
export CLOJURE_JAR=$HOME/.m2/repository/org/clojure/clojure/1.9.0/clojure-1.9.0.jar
export CLOJURE_EXT=$CLOJURE_JAR
export CLOJURE_OPTS="-Xms128M -Xmx512M -server"

# Emacs default editor
export ALTERNATE_EDITOR=""
export EDITOR="emacsclient-daemon.sh -nw"
export VISUAL="emacsclient-daemon.sh -c"
export EA_EDITOR="emacsclient-daemon.sh -c"

# Misc
export XMLLINT_INDENT="  "

# Leiningen
export LEIN_JVM_OPTS=

# Gtags & ctags
export GTAGSLABEL=universal-ctags
