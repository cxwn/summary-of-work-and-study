# Docker 实践经验总结

1. 由于 Docker 默认情况下，一般直接挂载宿主机的 /proc ，降低了 Docekr 的隔离程度，因此会造成一些系统安全问题，可以采用 lxcfs 来增强 Docker 容器隔离性。

2. 1