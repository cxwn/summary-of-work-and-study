# kubernetes 权威指南企业级容器云实战

1.
Nginx 、HAProxy 、Traefik 的特点
||<center>Nginx</center>|<center>HAProxy</center>|<center>Traefik</center>
:-:|:-|:-|:-
特点|<ol><li>工作在网络 7 层；</li><li>模块化，有丰富的第三方功能模块支持；</li><li>支持强大的正则匹配；</li><li>配置文件热更新；</li><li>除了做负载均衡，还能做静态 Wed 服务器、缓存服务器。</li></ol>|<ol><li>速度非常快；</li><li>节约计算资源（ CPU 和内存）；</li><li>配置文件热更新；<li>支持 TCP 与 HTTP ，工作在 4 层 和 7 层；</li>支持 Session 共享、Cookies 引导；</li><li>支持通过获取指定的 URL 来检测后端服务器的状态。</li></ol>|<ol><li>提供多种后台支持，比如 Rancher、Docker、Swarm、Kubernetes、Marathon、Mesos、Consul 和 etcd 等；</li><li>支持 Rest API;</li><li>配置文件热更新；</li><li>支持 SSL、Websocket、HTTP/2;</li><li>高可用集群模式。</li></ol>
性能|转发效率高|HTTP 转发效率高|吞吐率约为 Nginx 的 85%
配置难易程度|简单，支持强大的正则匹配|简单|简单，与为服务架构结合最好
负载均衡机制|一般|会话保持和健康检查机制全面|会话保持和健康检查机制全面
社区活跃度|活跃|一般|一般