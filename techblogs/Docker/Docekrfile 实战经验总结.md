# Dockerfile 一指禅

1. 在 USER 指令前执行的 RUN 指令总以 root 的身份执行。指定 USER 指令前后当前 shell 的 PID 都是1。

2. WORKDIR
   - WORKDIR 指令会创建指定目录，无需重复创建。
   - 如果存在多个 WORKDIR ，Doceker 容器运行时则以最后一个 WORKDIR 指定的目录为当前工作目录。
   - WORKDIR 指令指定的目录不能以“~”代替HOME目录。
   - 在 Docke 镜像的构建过程中，可以通过指定的 WORKDIR 随时切换工作目录。

3. AGR
   - ARG 