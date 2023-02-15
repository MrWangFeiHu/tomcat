#!/bin/sh

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -----------------------------------------------------------------------------
# 1.检测操作系统
# 2.获取脚本路径$PRG
# 3.设置两个重要的环境变量，CATALINA_HOME、CATALINA_BASE
# 4.设置CLASSPATH变量
# 5.在CLASSPATH后追加Bootstrap.jar、Tomcat-juli.jar
# 6.解析脚本参数，执行Bootstrap类的main方法，并传入相应的参数

# 控制catalina服务的脚本
#
# 关支持的命令，请调用“catalina.sh help”或参阅本文件末尾的用法部分。
#
# 环境变量前提条件
#
#   不要在此脚本中设置变量。而是将它们放入 CATALINA_BASE/bin 中的脚本 setenv.sh 中，以保持自定义的独立性。
#
#   CATALINA_HOME   可以指向您的 Catalina "build" 目录。
#
#   CATALINA_BASE   (可选) 用于解析 Catalina 安装目录的动态部分。
#                   如果不存在，则解析为 CATALINA_HOME 所指向的同一目录。
#
#   CATALINA_OUT    (可选) 将重定向 stdout 和 stderr 文件的完整路径。
#                   默认是 $CATALINA_BASE/logs/catalina.out
#
#   CATALINA_OUT_CMD (可选) 从 Tomcat 的 java 进程里获取将要执行的stdout和stderr的值作为他自己的stdin。
#                   如果 CATALINA_OUT_CMD 没有设置, CATALINA_OUT 将被作为输出路径。
#                   无默认值。
#                   示例
#                   CATALINA_OUT_CMD="/usr/bin/rotatelogs -f $CATALINA_BASE/logs/catalina.out.%Y-%m-%d.log 86400"
#
#   CATALINA_OPTS   (可选) 当执行 "run" "start" "debug" 命令的时候，java 运行时选项被启用。
#                   包含在此处但不在 JAVA_OPTS 的所有选项, 它只应由Tomcat本身使用，而不应由停止进程、版本命令等使用。
#                   例如堆大小、GC日志、JMX端口等。
#
#   CATALINA_TMPDIR (可选) JVM 临时目录应使用（java.io.tmpdir）。默认值为
#                   $CATALINA_BASE/temp.
#
#   JAVA_HOME       必须指向 JDK 安装目录，需要 "debug" 执行。
#
#   JRE_HOME        必须指向 JRE 安装目录。
#                   默认是空。
#                   如果 JRE_HOME 和 JAVA_HOME 都设置了，则使用 JRE_HOME。
#
#   JAVA_OPTS       (可选) 执行任何命令都会被使用的 java 运行时选项.
#                   JAVA_OPTS 有而 CATALINA_OPS 没有的所有选项, 会被 Tomcat 的 stop、version 等命令中用到。
#                   CATALINA_OPTS 应该包含 大多数选项.
#
#   JAVA_ENDORSED_DIRS (可选) 允许冒号分割的jar目录列表替换在JCP之外创建的API (例如. DOM and SAX from W3C).
#                   它还可以用于更新XML解析器实现。这仅适用于Java<=8。
#                   默认值是 $CATALINA_HOME/endorsed.
#
#   JPDA_TRANSPORT  (可选) 当 "jpda start" 命令被执行的时候，JPDA transport 被启用。
#                   默认值是 "dt_socket".
#
#   JPDA_ADDRESS    (可选) 当 "jpda start" 命令被执行的时候，java 运行时选项被启用。
#                   默认值是 localhost:8000.
#
#   JPDA_SUSPEND    (可选) 当 "jpda start" 命令被执行的时候，java 运行时选项被启用。
#                   指定JVM是否应在启动后立即暂停执行。默认值为 "n"。
#
#   JPDA_OPTS       (可选) 当 "jpda start" 命令被执行的时候，java 运行时选项被启用。
#                   如果使用，将忽略JPDA_TRANSPORT、JPDA_ADDRESS和JPDA_SUSPEND。
#                   因此，必须指定所有必需的jpda选项。默认值为：
#
#                   -agentlib:jdwp=transport=$JPDA_TRANSPORT,
#                       address=$JPDA_ADDRESS,server=y,suspend=$JPDA_SUSPEND
#
#   JSSE_OPTS       (可选) 使用 JSSE 时，用于控制 TLS 实现的 Java 运行时选项。默认值为：
#                   "-Djdk.tls.ephemeralDHKeySize=2048"
#
#   CATALINA_PID    (可选) 使用start（fork）时，catalina 启动 java 进程的文件目录应该包含 pid
#
#   CATALINA_LOGGING_CONFIG (可选) 覆盖Tomcat的日志配置文件
#                   例如
#                   CATALINA_LOGGING_CONFIG="-Djava.util.logging.config.file=$CATALINA_BASE/conf/logging.properties"
#
#   LOGGING_CONFIG  过时
#                   使用 CATALINA_LOGGING_CONFIG
#                   仅仅当 CATALINA_LOGGING_CONFIG 没有设置的时候才使用
#                   and LOGGING_CONFIG starts with "-D..."
#
#   LOGGING_MANAGER (可选) 覆盖Tomcat的日志管理器
#                   例如
#                   LOGGING_MANAGER="-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager"
#
#   UMASK           (可选) 覆盖 Tomcat 0027 的默认密码
#
#   USE_NOHUP       (可选) true - 使用nohup模式，这样Tomcat进程将忽略任何挂起信号。
#                   默认是false，只有在 除非在HP-UX上运行 才为 true
# -----------------------------------------------------------------------------

# OS specific support.  $var _must_ be set to either true or false.
# 对一些特定的操作系统，设置以下变量
cygwin=false
darwin=false
os400=false
hpux=false
case "`uname`" in
CYGWIN*) cygwin=true;;
Darwin*) darwin=true;;
OS400*) os400=true;;
HP-UX*) hpux=true;;
esac

# resolve links - $0 may be a softlink  # 解析软引用
PRG="$0"                                # PRG=catalina.sh
# 若为软引用，找到真实文件的位置
while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
# 获取标准环境变量
PRGDIR=`dirname "$PRG"` # PRGDIR=./catalina.sh

# Only set CATALINA_HOME if not already set
# 仅在 CATALINA_HOME 未设置 则 设置 CATALINA_HOME
[ -z "$CATALINA_HOME" ] && CATALINA_HOME=`cd "$PRGDIR/.." >/dev/null; pwd`

# Copy CATALINA_BASE from CATALINA_HOME if not already set
# 若 CATALINA_BASE 未设置 则将 $CATALINA_HOME 赋值 给 $CATALINA_BASE
[ -z "$CATALINA_BASE" ] && CATALINA_BASE="$CATALINA_HOME"

# Ensure that any user defined CLASSPATH variables are not used on startup,     确保启动时未使用任何用户定义的 CLASSPATH 变量，
# but allow them to be specified in setenv.sh, in rare case when it is needed.  但允许在setenv.sh中指定它们，这种情况在需要时很少见。
CLASSPATH=

if [ -r "$CATALINA_BASE/bin/setenv.sh" ]; then
  . "$CATALINA_BASE/bin/setenv.sh"
elif [ -r "$CATALINA_HOME/bin/setenv.sh" ]; then
  . "$CATALINA_HOME/bin/setenv.sh"
fi

# 根据不同的环境，使用不同的方法获取环境变量 JAVA_HOME JRE_HOME CATALINA_HOME CATALINA_BASE CLASSPATH  转 311行
# For Cygwin, ensure paths are in UNIX format before anything is touched
if $cygwin; then
  [ -n "$JAVA_HOME" ] && JAVA_HOME=`cygpath --unix "$JAVA_HOME"`
  [ -n "$JRE_HOME" ] && JRE_HOME=`cygpath --unix "$JRE_HOME"`
  [ -n "$CATALINA_HOME" ] && CATALINA_HOME=`cygpath --unix "$CATALINA_HOME"`
  [ -n "$CATALINA_BASE" ] && CATALINA_BASE=`cygpath --unix "$CATALINA_BASE"`
  [ -n "$CLASSPATH" ] && CLASSPATH=`cygpath --path --unix "$CLASSPATH"`
fi

# Ensure that neither CATALINA_HOME nor CATALINA_BASE contains a colon
# as this is used as the separator in the classpath and Java provides no
# mechanism for escaping if the same character appears in the path.
case $CATALINA_HOME in
  *:*) echo "Using CATALINA_HOME:   $CATALINA_HOME";
       echo "Unable to start as CATALINA_HOME contains a colon (:) character";
       exit 1;
esac
case $CATALINA_BASE in
  *:*) echo "Using CATALINA_BASE:   $CATALINA_BASE";
       echo "Unable to start as CATALINA_BASE contains a colon (:) character";
       exit 1;
esac

# For OS400
if $os400; then
  # Set job priority to standard for interactive (interactive - 6) by using
  # the interactive priority - 6, the helper threads that respond to requests
  # will be running at the same priority as interactive jobs.
  COMMAND='chgjob job('$JOBNAME') runpty(6)'
  system $COMMAND

  # Enable multi threading
  export QIBM_MULTI_THREADED=Y
fi

# Get standard Java environment variables
if $os400; then
  # -r will Only work on the os400 if the files are:
  # 1. owned by the user
  # 2. owned by the PRIMARY group of the user
  # this will not work if the user belongs in secondary groups
  . "$CATALINA_HOME"/bin/setclasspath.sh
else
  if [ -r "$CATALINA_HOME"/bin/setclasspath.sh ]; then
    . "$CATALINA_HOME"/bin/setclasspath.sh
  else
    echo "Cannot find $CATALINA_HOME/bin/setclasspath.sh"
    echo "This file is needed to run this program"
    exit 1
  fi
fi

# Add on extra jar files to CLASSPATH
if [ ! -z "$CLASSPATH" ] ; then
  CLASSPATH="$CLASSPATH":
fi
CLASSPATH="$CLASSPATH""$CATALINA_HOME"/bin/bootstrap.jar

if [ -z "$CATALINA_OUT" ] ; then
  CATALINA_OUT="$CATALINA_BASE"/logs/catalina.out
fi

if [ -z "$CATALINA_TMPDIR" ] ; then
  # Define the java.io.tmpdir to use for Catalina
  CATALINA_TMPDIR="$CATALINA_BASE"/temp
fi

# Add tomcat-juli.jar to classpath
# tomcat-juli.jar can be over-ridden per instance
if [ -r "$CATALINA_BASE/bin/tomcat-juli.jar" ] ; then
  CLASSPATH=$CLASSPATH:$CATALINA_BASE/bin/tomcat-juli.jar
else
  CLASSPATH=$CLASSPATH:$CATALINA_HOME/bin/tomcat-juli.jar
fi

# Bugzilla 37848: When no TTY is available, don't output to console
have_tty=0
if [ -t 0 ]; then
    have_tty=1
fi

# For Cygwin, switch paths to Windows format before running java
if $cygwin; then
  JAVA_HOME=`cygpath --absolute --windows "$JAVA_HOME"`
  JRE_HOME=`cygpath --absolute --windows "$JRE_HOME"`
  CATALINA_HOME=`cygpath --absolute --windows "$CATALINA_HOME"`
  CATALINA_BASE=`cygpath --absolute --windows "$CATALINA_BASE"`
  CATALINA_TMPDIR=`cygpath --absolute --windows "$CATALINA_TMPDIR"`
  CLASSPATH=`cygpath --path --windows "$CLASSPATH"`
  [ -n "$JAVA_ENDORSED_DIRS" ] && JAVA_ENDORSED_DIRS=`cygpath --path --windows "$JAVA_ENDORSED_DIRS"`
fi

if [ -z "$JSSE_OPTS" ] ; then
  JSSE_OPTS="-Djdk.tls.ephemeralDHKeySize=2048"
fi
JAVA_OPTS="$JAVA_OPTS $JSSE_OPTS"

# Check for the deprecated LOGGING_CONFIG
# Only use it if CATALINA_LOGGING_CONFIG is not set and LOGGING_CONFIG starts with "-D..."
if [ -z "$CATALINA_LOGGING_CONFIG" ]; then
  case $LOGGING_CONFIG in
    -D*) CATALINA_LOGGING_CONFIG="$LOGGING_CONFIG"
  esac
fi

# Set juli LogManager config file if it is present and an override has not been issued
if [ -z "$CATALINA_LOGGING_CONFIG" ]; then
  if [ -r "$CATALINA_BASE"/conf/logging.properties ]; then
    CATALINA_LOGGING_CONFIG="-Djava.util.logging.config.file=$CATALINA_BASE/conf/logging.properties"
  else
    # Bugzilla 45585
    CATALINA_LOGGING_CONFIG="-Dnop"
  fi
fi

if [ -z "$LOGGING_MANAGER" ]; then
  LOGGING_MANAGER="-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager"
fi

# Set UMASK unless it has been overridden
if [ -z "$UMASK" ]; then
    UMASK="0027"
fi
umask $UMASK

# Java 9 no longer supports the java.endorsed.dirs
# system property. Only try to use it if
# JAVA_ENDORSED_DIRS was explicitly set
# or CATALINA_HOME/endorsed exists.
ENDORSED_PROP=ignore.endorsed.dirs
if [ -n "$JAVA_ENDORSED_DIRS" ]; then
    ENDORSED_PROP=java.endorsed.dirs
fi
if [ -d "$CATALINA_HOME/endorsed" ]; then
    ENDORSED_PROP=java.endorsed.dirs
fi

# Make the umask available when using the org.apache.catalina.security.SecurityListener
JAVA_OPTS="$JAVA_OPTS -Dorg.apache.catalina.security.SecurityListener.UMASK=`umask`"

if [ -z "$USE_NOHUP" ]; then
    if $hpux; then
        USE_NOHUP="true"
    else
        USE_NOHUP="false"
    fi
fi
unset _NOHUP
if [ "$USE_NOHUP" = "true" ]; then
    _NOHUP="nohup"
fi

# Add the JAVA 9 specific start-up parameters required by Tomcat
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS --add-opens=java.base/java.lang=ALL-UNNAMED"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS --add-opens=java.base/java.io=ALL-UNNAMED"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS --add-opens=java.base/java.util=ALL-UNNAMED"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS --add-opens=java.base/java.util.concurrent=ALL-UNNAMED"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS --add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED"
export JDK_JAVA_OPTIONS

# 环境变量获取完毕...

# ----- 执行请求命令 -----------------------------------------

# Bugzilla 37848: only output this if we have a TTY
if [ $have_tty -eq 1 ]; then
  echo "Using CATALINA_BASE:   $CATALINA_BASE"
  echo "Using CATALINA_HOME:   $CATALINA_HOME"
  echo "Using CATALINA_TMPDIR: $CATALINA_TMPDIR"
  if [ "$1" = "debug" ] ; then
    echo "Using JAVA_HOME:       $JAVA_HOME"
  else
    echo "Using JRE_HOME:        $JRE_HOME"
  fi
  echo "Using CLASSPATH:       $CLASSPATH"
  echo "Using CATALINA_OPTS:   $CATALINA_OPTS"
  if [ ! -z "$CATALINA_PID" ]; then
    echo "Using CATALINA_PID:    $CATALINA_PID"
  fi
fi

if [ "$1" = "jpda" ] ; then
  if [ -z "$JPDA_TRANSPORT" ]; then
    JPDA_TRANSPORT="dt_socket"
  fi
  if [ -z "$JPDA_ADDRESS" ]; then
    JPDA_ADDRESS="localhost:8000"
  fi
  if [ -z "$JPDA_SUSPEND" ]; then
    JPDA_SUSPEND="n"
  fi
  if [ -z "$JPDA_OPTS" ]; then
    JPDA_OPTS="-agentlib:jdwp=transport=$JPDA_TRANSPORT,address=$JPDA_ADDRESS,server=y,suspend=$JPDA_SUSPEND"
  fi
  CATALINA_OPTS="$JPDA_OPTS $CATALINA_OPTS"
  # https://blog.csdn.net/hilaochen/article/details/8244924
  # shell 下 shift 和 eval。 shift 是左移参数列表，$1 $2 $3 $4 shift后$1的值就没了，$2就编程$1啦
  shift
fi

if [ "$1" = "debug" ] ; then
  if $os400; then
    echo "Debug command not available on OS400"
    exit 1
  else
    shift
    if [ "$1" = "-security" ] ; then
      if [ $have_tty -eq 1 ]; then
        echo "Using Security Manager"
      fi
      shift
      eval exec "\"$_RUNJDB\"" "\"$CATALINA_LOGGING_CONFIG\"" $LOGGING_MANAGER "$JAVA_OPTS" "$CATALINA_OPTS" \
        -D$ENDORSED_PROP="$JAVA_ENDORSED_DIRS" \
        -classpath "$CLASSPATH" \
        -sourcepath "$CATALINA_HOME"/../../java \
        -Djava.security.manager \
        -Djava.security.policy=="$CATALINA_BASE"/conf/catalina.policy \
        -Dcatalina.base="$CATALINA_BASE" \
        -Dcatalina.home="$CATALINA_HOME" \
        -Djava.io.tmpdir="$CATALINA_TMPDIR" \
        org.apache.catalina.startup.Bootstrap "$@" start
    else
      eval exec "\"$_RUNJDB\"" "\"$CATALINA_LOGGING_CONFIG\"" $LOGGING_MANAGER "$JAVA_OPTS" "$CATALINA_OPTS" \
        -D$ENDORSED_PROP="$JAVA_ENDORSED_DIRS" \
        -classpath "$CLASSPATH" \
        -sourcepath "$CATALINA_HOME"/../../java \
        -Dcatalina.base="$CATALINA_BASE" \
        -Dcatalina.home="$CATALINA_HOME" \
        -Djava.io.tmpdir="$CATALINA_TMPDIR" \
        org.apache.catalina.startup.Bootstrap "$@" start
    fi
  fi

# run 命令
elif [ "$1" = "run" ]; then

  shift
  # $1 参数值若为 -security，则
  if [ "$1" = "-security" ] ; then
    # tty只有1个
    if [ $have_tty -eq 1 ]; then
      # 输出 "正在使用安全管理器"
      echo "Using Security Manager"
    fi
    shift
    # 执行后面的命令
    # $_RUNJAVA : "/Library/Java/JavaVirtualMachines/jdk1.8.0_351.jdk/Contents/Home/bin/java"
    # $CATALINA_LOGGING_CONFIG : "-Djava.util.logging.config.file=/Users/afeimaic/IdeaProjects/tomcat/conf/logging.properties"
    # $LOGGING_MANAGER : -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
    # $JAVA_OPTS : -Djdk.tls.ephemeralDHKeySize=2048
    # $CATALINA_OPTS : -Dorg.apache.catalina.security.SecurityListener.UMASK=0027
    # $ENDORSED_PROP : ignore.endorsed.dirs
    # $JAVA_ENDORSED_DIRS : ""
    # $CLASSPATH : /Users/afeimaic/IdeaProjects/tomcat/bin/bootstrap.jar:/Users/afeimaic/IdeaProjects/tomcat/bin/tomcat-juli.jar
    # $CATALINA_BASE : "/Users/afeimaic/IdeaProjects/tomcat"
    # $CATALINA_HOME : "/Users/afeimaic/IdeaProjects/tomcat"
    # $CATALINA_TMPDIR : "/Users/afeimaic/IdeaProjects/tomcat/temp"
    # org.apache.catalina.startup.Bootstrap : 主启动类
    # main函数入参 : start
    # $@ : 全部入参，无
    eval exec "\"$_RUNJAVA\"" "\"$CATALINA_LOGGING_CONFIG\"" $LOGGING_MANAGER "$JAVA_OPTS" "$CATALINA_OPTS" \
      -D$ENDORSED_PROP="\"$JAVA_ENDORSED_DIRS\"" \
      -classpath "\"$CLASSPATH\"" \
      -Djava.security.manager \
      -Djava.security.policy=="\"$CATALINA_BASE/conf/catalina.policy\"" \
      -Dcatalina.base="\"$CATALINA_BASE\"" \
      -Dcatalina.home="\"$CATALINA_HOME\"" \
      -Djava.io.tmpdir="\"$CATALINA_TMPDIR\"" \
      org.apache.catalina.startup.Bootstrap "$@" start
  else
    # 不使用安全管理器
    # 命令行参数少了 -Djava.security.manager -Djava.security.policy=="\"$CATALINA_BASE/conf/catalina.policy\""
    eval exec "\"$_RUNJAVA\"" "\"$CATALINA_LOGGING_CONFIG\"" $LOGGING_MANAGER "$JAVA_OPTS" "$CATALINA_OPTS" \
      -D$ENDORSED_PROP="\"$JAVA_ENDORSED_DIRS\"" \
      -classpath "\"$CLASSPATH\"" \
      -Dcatalina.base="\"$CATALINA_BASE\"" \
      -Dcatalina.home="\"$CATALINA_HOME\"" \
      -Djava.io.tmpdir="\"$CATALINA_TMPDIR\"" \
      org.apache.catalina.startup.Bootstrap "$@" start
  fi

# 启动程序
elif [ "$1" = "start" ] ; then

  # shell https://blog.csdn.net/weixin_43025071/article/details/122337013
  # if [ -z $string ] 如果string 为空
  if [ ! -z "$CATALINA_PID" ]; then
    # if [ -f file ] 如果文件存在
    if [ -f "$CATALINA_PID" ]; then
      # if [ -s file ] 如果文件存在且非空
      if [ -s "$CATALINA_PID" ]; then
        echo "Existing PID file found during start."
        # if [ -r file ] 如果文件存在且可读
        if [ -r "$CATALINA_PID" ]; then
          PID=`cat "$CATALINA_PID"`
          ps -p $PID >/dev/null 2>&1
          if [ $? -eq 0 ] ; then
            echo "Tomcat appears to still be running with PID $PID. Start aborted."
            echo "If the following process is not a Tomcat process, remove the PID file and try again:"
            ps -f -p $PID
            exit 1
          else
            echo "Removing/clearing stale PID file."
            rm -f "$CATALINA_PID" >/dev/null 2>&1
            if [ $? != 0 ]; then
              if [ -w "$CATALINA_PID" ]; then
                cat /dev/null > "$CATALINA_PID"
              else
                echo "Unable to remove or clear stale PID file. Start aborted."
                exit 1
              fi
            fi
          fi
        else
          # 输出 "无法读取PID 文件。启动终止。"
          echo "Unable to read PID file. Start aborted."
          # 异常退出
          exit 1
        fi
      else
        # 删除正在启动的 $CATALINA_PID
        rm -f "$CATALINA_PID" >/dev/null 2>&1
        # $? 最后运行的命令的结束代码（返回值）即执行上一个指令的返回值 (显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误)
        if [ $? != 0 ]; then
          # if [ -w file ] 如果文件存在且可写
          if [ ! -w "$CATALINA_PID" ]; then
            # 输出 "无法删除或写入到空的PID文件。启动终止。"
            echo "Unable to remove or write to empty PID file. Start aborted."
            # 异常退出
            exit 1
          fi
        fi
      fi
    fi
  fi

  shift
  # if [ -z $string ] 如果string 为空
  if [ -z "$CATALINA_OUT_CMD" ] ; then
    # 若为空，则创建
    touch "$CATALINA_OUT"
  else
    # [ -e FILE ] 如果 FILE 存在则为真。
    if [ ! -e "$CATALINA_OUT" ]; then
      # https://www.cnblogs.com/old-path-white-cloud/p/11685558.html    mkfifo命令基本用法
      # 通常情况下，终端只能执行一条命令，然后按下回车，那么执行多条命令呢
      # mkfifo则可以创建命名管道，若创建失败，则
      if ! mkfifo "$CATALINA_OUT"; then
        # 输出 "不能创建命名管道 $CATALINA_OUT。启动终止。"
        echo "cannot create named pipe $CATALINA_OUT. Start aborted."
        # 异常退出
        exit 1
      fi
    # [ -p FILE ] 如果 FILE 存在且是一个名字管道(F如果O)则为真。判断 $CATALINA_OUT 是不是命名管道，若不是，则
    elif [ ! -p "$CATALINA_OUT" ]; then
      # 输出 "$CATALINA_OUT 存在但不是命名管道。启动终止。"
      echo "$CATALINA_OUT exists and is not a named pipe. Start aborted."
      # 异常退出
      exit 1
    fi
    # $CATALINA_OUT_CMD 内容 存入 $CATALINA_OUT 命名管道
    $CATALINA_OUT_CMD <"$CATALINA_OUT" &
  fi
  # 因为上面 shift 过，所以如果有 -security，它就在$1位置了。若有 -security 入参，则
  if [ "$1" = "-security" ] ; then
    # 判断tty个数是否为1
    if [ $have_tty -eq 1 ]; then
      # 输出 "使用安全管理器"
      echo "Using Security Manager"
    fi
    # 移动参数列表
    shift
    # 执行后面的命令
    # $_NOHUP : 因为 USE_NOHUP 默认是 false，所以默认不使用 nohup 启动，此处为 ""
    # $_RUNJAVA : "/Library/Java/JavaVirtualMachines/jdk1.8.0_351.jdk/Contents/Home/bin/java"
    # $CATALINA_LOGGING_CONFIG : "-Djava.util.logging.config.file=/Users/afeimaic/IdeaProjects/tomcat/conf/logging.properties"
    # $LOGGING_MANAGER : -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
    # $JAVA_OPTS : -Djdk.tls.ephemeralDHKeySize=2048
    # $CATALINA_OPTS : -Dorg.apache.catalina.security.SecurityListener.UMASK=0027
    # $ENDORSED_PROP : ignore.endorsed.dirs
    # $JAVA_ENDORSED_DIRS : ""
    # $CLASSPATH : /Users/afeimaic/IdeaProjects/tomcat/bin/bootstrap.jar:/Users/afeimaic/IdeaProjects/tomcat/bin/tomcat-juli.jar
    # $CATALINA_BASE : "/Users/afeimaic/IdeaProjects/tomcat"
    # $CATALINA_HOME : "/Users/afeimaic/IdeaProjects/tomcat"
    # $CATALINA_TMPDIR : "/Users/afeimaic/IdeaProjects/tomcat/temp"
    # org.apache.catalina.startup.Bootstrap : 主启动类
    # main函数入参 : start
    # $@ : 全部入参，无
    # $CATALINA_OUT : /Users/afeimaic/IdeaProjects/tomcat/logs/catalina.out
    # 2>&1 : 使用 2>&1 来重定向 stderr 的输出至 stdout 的地方
    # & : 后台启动
    eval $_NOHUP "\"$_RUNJAVA\"" "\"$CATALINA_LOGGING_CONFIG\"" $LOGGING_MANAGER "$JAVA_OPTS" "$CATALINA_OPTS" \
      -D$ENDORSED_PROP="\"$JAVA_ENDORSED_DIRS\"" \
      -classpath "\"$CLASSPATH\"" \
      -Djava.security.manager \
      -Djava.security.policy=="\"$CATALINA_BASE/conf/catalina.policy\"" \
      -Dcatalina.base="\"$CATALINA_BASE\"" \
      -Dcatalina.home="\"$CATALINA_HOME\"" \
      -Djava.io.tmpdir="\"$CATALINA_TMPDIR\"" \
      org.apache.catalina.startup.Bootstrap "$@" start \
      >> "$CATALINA_OUT" 2>&1 "&"

  else
    # 不使用安全管理器
    # 命令行参数少了 -Djava.security.manager -Djava.security.policy=="\"$CATALINA_BASE/conf/catalina.policy\""
    eval $_NOHUP "\"$_RUNJAVA\"" "\"$CATALINA_LOGGING_CONFIG\"" $LOGGING_MANAGER "$JAVA_OPTS" "$CATALINA_OPTS" \
      -D$ENDORSED_PROP="\"$JAVA_ENDORSED_DIRS\"" \
      -classpath "\"$CLASSPATH\"" \
      -Dcatalina.base="\"$CATALINA_BASE\"" \
      -Dcatalina.home="\"$CATALINA_HOME\"" \
      -Djava.io.tmpdir="\"$CATALINA_TMPDIR\"" \
      org.apache.catalina.startup.Bootstrap "$@" start \
      >> "$CATALINA_OUT" 2>&1 "&"

  fi

  # if [ -z $string ] 如果string 为空
  if [ ! -z "$CATALINA_PID" ]; then # 如果 $CATALINA_PID 不为空
    # $! : Shell最后运行的后台Process的PID(后台运行的最后一个进程的 进程ID号)
    echo $! > "$CATALINA_PID"
  fi

  # 输出 "Tomcat 已启动。"
  echo "Tomcat started."

# 终止程序
elif [ "$1" = "stop" ] ; then

  # 参数列表移动
  shift
  # 休眠5秒
  SLEEP=5
  # if [ -z $string ] 如果string 为空。 || 若$1非空，则
  if [ ! -z "$1" ]; then
    echo $1 | grep "[^0-9]" >/dev/null 2>&1
    # $? 最后运行的命令的结束代码（返回值）即执行上一个指令的返回值 (显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误)
    if [ $? -gt 0 ]; then
      SLEEP=$1 # 休眠的秒数
      shift    # 移动参数列表
    fi
  fi

  FORCE=0     # 定义变量 FORCE
  # 若 $1 等于 -force
  if [ "$1" = "-force" ]; then
    shift     # 移动参数列表
    FORCE=1   # 强制
  fi

  # if [ -z $string ] 如果string 为空。这里是若 $CATALINA_PID 不为空
  if [ ! -z "$CATALINA_PID" ]; then
    # if [ -f file ] 如果文件存在
    if [ -f "$CATALINA_PID" ]; then
      # if [ -s file ] 如果文件存在且非空
      if [ -s "$CATALINA_PID" ]; then
        # 终止进程
        kill -0 `cat "$CATALINA_PID"` >/dev/null 2>&1
        # $? 最后运行的命令的结束代码（返回值）即执行上一个指令的返回值 (显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误)
        if [ $? -gt 0 ]; then
          # 输出 "PID 文件已找到但是没有找到匹配的进程或者当前用户没有停止该进程的权限。stop 程序已终止。"
          echo "PID file found but either no matching process was found or the current user does not have permission to stop the process. Stop aborted."
          # 异常退出
          exit 1
        fi
      else
        # 输出 "PID file 为空，已被忽略"
        echo "PID file is empty and has been ignored."
      fi
    else
      # $CATALINA_PID 已设置，但是指定的文件不存在。Tomcat 在运行吗？ stop 程序已终止。
      echo "\$CATALINA_PID was set but the specified file does not exist. Is Tomcat running? Stop aborted."
      # 异常退出
      exit 1
    fi
  fi

  # 执行后面的命令
  # $_RUNJAVA : "/Library/Java/JavaVirtualMachines/jdk1.8.0_351.jdk/Contents/Home/bin/java"
  # $LOGGING_MANAGER : -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
  # $JAVA_OPTS : -Djdk.tls.ephemeralDHKeySize=2048
  # $CATALINA_OPTS : -Dorg.apache.catalina.security.SecurityListener.UMASK=0027
  # $ENDORSED_PROP : ignore.endorsed.dirs
  # $JAVA_ENDORSED_DIRS : ""
  # $CLASSPATH : /Users/afeimaic/IdeaProjects/tomcat/bin/bootstrap.jar:/Users/afeimaic/IdeaProjects/tomcat/bin/tomcat-juli.jar
  # $CATALINA_BASE : "/Users/afeimaic/IdeaProjects/tomcat"
  # $CATALINA_HOME : "/Users/afeimaic/IdeaProjects/tomcat"
  # $CATALINA_TMPDIR : "/Users/afeimaic/IdeaProjects/tomcat/temp"
  # org.apache.catalina.startup.Bootstrap : 主启动类
  # main函数入参 : stop
  # $@ : 全部入参，无
  eval "\"$_RUNJAVA\"" $LOGGING_MANAGER "$JAVA_OPTS" \
    -D$ENDORSED_PROP="\"$JAVA_ENDORSED_DIRS\"" \
    -classpath "\"$CLASSPATH\"" \
    -Dcatalina.base="\"$CATALINA_BASE\"" \
    -Dcatalina.home="\"$CATALINA_HOME\"" \
    -Djava.io.tmpdir="\"$CATALINA_TMPDIR\"" \
    org.apache.catalina.startup.Bootstrap "$@" stop

  # stop failed. Shutdown port disabled? Try a normal kill.
  # 停止失败。关闭端口号已禁用？尝试普通的 kill
  if [ $? != 0 ]; then
    # if [ -z $string ] 如果string 为空。
    if [ ! -z "$CATALINA_PID" ]; then
      # 输出 "stop 命令执行失败。尝试通过操作系统唤醒功能去唤醒进程"
      echo "The stop command failed. Attempting to signal the process to stop through OS signal."
      # 停掉 $CATALINA_PID 里的进程
      kill -15 `cat "$CATALINA_PID"` >/dev/null 2>&1
    fi
  fi

  # if [ -z $string ] 如果string 为空。
  if [ ! -z "$CATALINA_PID" ]; then
    # if [ -f file ] 如果文件存在
    if [ -f "$CATALINA_PID" ]; then
      # 当 SLEEP = 0, 进入循环
      while [ $SLEEP -ge 0 ]; do
        # 停掉 $CATALINA_PID 里的进程
        kill -0 `cat "$CATALINA_PID"` >/dev/null 2>&1
        # 若执行失败
        if [ $? -gt 0 ]; then
          # 删除 $CATALINA_PID
          rm -f "$CATALINA_PID" >/dev/null 2>&1
          # 若删除失败
          if [ $? != 0 ]; then
            # if [ -w file ] 如果文件存在且可写
            if [ -w "$CATALINA_PID" ]; then
              # 将 /dev/null 写入 $CATALINA_PID
              cat /dev/null > "$CATALINA_PID"
              # 如果 Tomcat 已经停止了则不再尝试强制停止 PID file
              # If Tomcat has stopped don't try and force a stop with an empty PID file
              FORCE=0
            else
              # 输出 "无法删除或清除PID文件。"
              echo "The PID file could not be removed or cleared."
            fi
          fi
          # 输出 "Tomcat 已终止。"
          echo "Tomcat stopped."
          # 终止循环
          break
        fi
        # 如果 SLEEP > 0
        if [ $SLEEP -gt 0 ]; then
          # 休眠 1 秒
          sleep 1
        fi
        # 如果SLEEP = 0
        if [ $SLEEP -eq 0 ]; then
          # 输出 "Tomcat没有及时停止。"
          echo "Tomcat did not stop in time."
          # 如果 $FORCE = 0
          if [ $FORCE -eq 0 ]; then
            # 输出 "PID "
            echo "未删除PID文件。"
          fi
          # 输出 ""
          echo "为了提供判断依据，线程转储已写入标准输出。"
          kill -3 `cat "$CATALINA_PID"`
        fi
        # 减少 1 秒休眠
        SLEEP=`expr $SLEEP - 1 `
      done
    fi
  fi

  # KILL 休眠间隔时长 5 秒
  KILL_SLEEP_INTERVAL=5
  # $FORCE == 1
  if [ $FORCE -eq 1 ]; then
    # if [ -z $string ] 如果string 为空。
    if [ -z "$CATALINA_PID" ]; then
      # 输出 "停止失败: PID 未设置"
      echo "Kill failed: \$CATALINA_PID not set"
    else
      # 判断 $CATALINA_PID 是否存在
      if [ -f "$CATALINA_PID" ]; then
        # 从 $CATALINA_PID 读取 PID
        PID=`cat "$CATALINA_PID"`
        # 输出 "正在杀死 Tomcat PID: xxx"
        echo "Killing Tomcat with the PID: $PID"
        # 强制kill
        kill -9 $PID
        # 若休眠时长大于 0，则循环
        while [ $KILL_SLEEP_INTERVAL -ge 0 ]; do
            # 接着清理
            kill -0 `cat "$CATALINA_PID"` >/dev/null 2>&1
            # 清理失败
            if [ $? -gt 0 ]; then
                # 删除
                rm -f "$CATALINA_PID" >/dev/null 2>&1
                # 删除失败
                if [ $? != 0 ]; then
                    # 判断是否可写
                    if [ -w "$CATALINA_PID" ]; then
                        # 转储
                        cat /dev/null > "$CATALINA_PID"
                    else
                        # 输出 "无法删除PID文件"
                        echo "The PID file could not be removed."
                    fi
                fi
                # 输出 "Tomcat 进程已被杀死。"
                echo "The Tomcat process has been killed."
                # 跳出循环
                break
            fi
            # 间隔时长大于 0，休 1 秒
            if [ $KILL_SLEEP_INTERVAL -gt 0 ]; then
                sleep 1
            fi
            # 自减 1
            KILL_SLEEP_INTERVAL=`expr $KILL_SLEEP_INTERVAL - 1 `
        done
        if [ $KILL_SLEEP_INTERVAL -lt 0 ]; then
            # 输出 "Tomcat 还没有完全关闭。该进程可能在等待一些系统调用或者可能被中断了。"
            echo "Tomcat has not been killed completely yet. The process might be waiting on some system call or might be UNINTERRUPTIBLE."
        fi
      fi
    fi
  fi

# 测试配置
elif [ "$1" = "configtest" ] ; then

    # $_RUNJAVA : "/Library/Java/JavaVirtualMachines/jdk1.8.0_351.jdk/Contents/Home/bin/java"
    # $ENDORSED_PROP : ignore.endorsed.dirs
    # $JAVA_ENDORSED_DIRS : ""
    # $CLASSPATH : /Users/afeimaic/IdeaProjects/tomcat/bin/bootstrap.jar:/Users/afeimaic/IdeaProjects/tomcat/bin/tomcat-juli.jar
    # $CATALINA_BASE : "/Users/afeimaic/IdeaProjects/tomcat"
    # $CATALINA_HOME : "/Users/afeimaic/IdeaProjects/tomcat"
    $CATALINA_TMPDIR : "/Users/afeimaic/IdeaProjects/tomcat/temp"
    # org.apache.catalina.startup.Bootstrap : 主启动类
    # main函数入参 : configtest
    eval "\"$_RUNJAVA\"" $LOGGING_MANAGER "$JAVA_OPTS" \
      -D$ENDORSED_PROP="\"$JAVA_ENDORSED_DIRS\"" \
      -classpath "\"$CLASSPATH\"" \
      -Dcatalina.base="\"$CATALINA_BASE\"" \
      -Dcatalina.home="\"$CATALINA_HOME\"" \
      -Djava.io.tmpdir="\"$CATALINA_TMPDIR\"" \
      org.apache.catalina.startup.Bootstrap configtest
    result=$? # 将执行结果赋值给 result 变量
    # 上条命令没执行成功
    if [ $result -ne 0 ]; then
        # 输出 "检测到配置错误！"
        echo "Configuration error detected!"
    fi
    exit $result  # 异常退出

# 打印版本信息
elif [ "$1" = "version" ] ; then

    # $_RUNJAVA : "/Library/Java/JavaVirtualMachines/jdk1.8.0_351.jdk/Contents/Home/bin/java"
    # $CATALINA_HOME : "/Users/afeimaic/IdeaProjects/tomcat"
    "$_RUNJAVA"   \
      -classpath "$CATALINA_HOME/lib/catalina.jar" \
      org.apache.catalina.util.ServerInfo

else
  # 命令输入有误，给出提示
  echo "Usage: catalina.sh ( commands ... )"
  echo "commands:"
  # 不同环境对使用了安全管理器的日志打印区分
  if $os400; then
    echo "  debug             Start Catalina in a debugger (not available on OS400)"
    echo "  debug -security   Debug Catalina with a security manager (not available on OS400)"
  else
    echo "  debug             Start Catalina in a debugger"
    echo "  debug -security   Debug Catalina with a security manager"
  fi
  echo "  jpda start        Start Catalina under JPDA debugger" # 在 JPDA debugger 模式下启动 Catalina
  echo "  run               Start Catalina in the current window" # 在当前窗口启动 Catalina
  echo "  run -security     Start in the current window with security manager"  # 在当前窗口使用安全管理器启动 Catalina
  echo "  start             Start Catalina in a separate window" # 在新窗口启动 Catalina
  echo "  start -security   Start in a separate window with security manager" # 在新窗口使用安全管理器启动 Catalina
  echo "  stop              Stop Catalina, waiting up to 5 seconds for the process to end"  # 停止 Catalina，进程等待 5 秒后停止
  echo "  stop n            Stop Catalina, waiting up to n seconds for the process to end"  # 停止 Catalina，进程等待 n 秒后停止
  echo "  stop -force       Stop Catalina, wait up to 5 seconds and then use kill -KILL if still running"  # 停止 Catalina，5 秒后还运行则使用kill命令停止
  echo "  stop n -force     Stop Catalina, wait up to n seconds and then use kill -KILL if still running"  # 停止 Catalina，n 秒后还运行则使用kill命令停止
  echo "  configtest        Run a basic syntax check on server.xml - check exit code for result" # 对 server.xml 运行基础语法检查，退出的 code 为检查结果
  echo "  version           What version of tomcat are you running?" # 打印你运行的tomcat是哪个版本
  # "备注: 等待进程终止并且使用了 -force 选项则需要定义 $CATALINA_PID"
  echo "Note: Waiting for the process to end and use of the -force option require that \$CATALINA_PID is defined"
  # 异常退出
  exit 1

fi
