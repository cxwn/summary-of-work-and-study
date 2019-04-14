FROM centos:7.6.1810
ENV  SSD='/high-speed-storage' DATA='/data'
COPY . /
RUN  yum -y install nfs-utils && \
     mkdir $DATA
CMD  [ "/bin/bash","/start-client.sh" ]