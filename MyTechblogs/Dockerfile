FROM centos:7.4
ENV PATH_TRANSCRIBE=/usr/local/models/model_0103
ENV TEMP_FILE=/TempFile
ENV LOG_FILE=/LogFile
RUN yum -y install epel-release && \
    yum -y install stress stress-ng  bonnie++ strace iperf net-tools lsof ethtool