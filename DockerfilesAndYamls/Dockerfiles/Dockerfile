FROM centos:7.4.1708
ENV  SSD='/high-speed-storage'
RUN  yum -y install nfs-utils && \
     mkdir $SSD 
CMD  [ "/bin/bash","/start.sh" ]


