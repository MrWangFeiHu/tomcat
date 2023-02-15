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
# catalina server 的启动脚本
# -----------------------------------------------------------------------------

# Better OS/400 detection: see Bugzilla 31132
# OS-400是IBM公司为其AS-400以及AS-400e系列商业计算机开发的操作系统。
os400=false
case "`uname`" in
OS400*) os400=true;;
esac
#上一个判断是为了判断操作系统

# resolve links - $0 may be a softlink
# 获取当前文件名称
PRG="$0" # PRG=.

# 解析可能得软引用, 拼出 startup.sh 的相对路径
# test –h File 文件存在并且是一个符号链接（同-L）
while [ -h "$PRG" ] ; do
  # afeiamic@192 bin % ls -ld startup.sh
  # -rwxr-xr-x  1 afeiamic  staff  1904  2 15 10:49 startup.sh
  ls=`ls -ld "$PRG"`
  # afeiamic@192 bin % echo `expr "8 -rwxr-xr-x  1 afeiamic  staff  2375 Feb 15 13:10 startup.sh" : '.*-> \(.*\)$'`
  #
  # 得到的link为空
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"                   # 若有软引用，则PRG为软引用的相对路径
  else
    PRG=`dirname "$PRG"`/"$link"  # PRG=./startup.sh 因为这里没有软引用，所以执行后还是startup.sh
  fi
done
#上面循环语句的意思是保证文件路径不是一个连接，使用循环直至找到文件原地址

PRGDIR=`dirname "$PRG"` # PRGDIR=./startup.sh
EXECUTABLE=catalina.sh  # 要执行的脚本名称 catalina.sh

# Check that target executable exists
# 判断是否是其他的操作系统环境
if $os400; then
  # -x will Only work on the os400 if the files are:              -x将仅在os400上工作，如果文件是:
  # 1. owned by the user                                          由用户拥有
  # 2. owned by the PRIMARY group of the user                     由用户的PRIMARY组拥有
  # this will not work if the user belongs in secondary groups    如果用户属于次要组，则此操作将不起作用
  eval
else
  if [ ! -x "$PRGDIR"/"$EXECUTABLE" ]; then
    echo "Cannot find $PRGDIR/$EXECUTABLE"                        # 找不到 ./catalina.sh
    echo "The file is absent or does not have execute permission" # 该文件不存在或者没有执行权限
    echo "This file is needed to run this program"                # 程序运行需要此文件
    exit 1                                                        # 异常退出
  fi
fi

# exec ./catalina.sh start                                        # 有命令行参数则带上$@, 没有则无
exec "$PRGDIR"/"$EXECUTABLE" start "$@"

# 请转./catalina.sh 继续查看