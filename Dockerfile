#
# Dockerfile for pfcon repository.
#
# Build with
#
#   docker build -t <name> .
#
# For example if building a local version, you could do:
#
#   docker build --build-arg UID=$UID -t local/pfdcm .
#
# In the case of a proxy (located at 192.168.13.14:3128), do:
#
#    docker build --build-arg http_proxy=http://192.168.13.14:3128 --build-arg UID=$UID -t local/pfdcm .
#
# To run an interactive shell inside this container, do:
#
#   docker run -ti --entrypoint /bin/bash local/pfdcm
#
# To pass an env var HOST_IP to container, do:
#
#   docker run -ti -e HOST_IP=$(ip route | grep -v docker | awk '{if(NF==11) print $9}') --entrypoint /bin/bash local/pfdcm
#

FROM fnndsc/ubuntu-python3:latest
MAINTAINER fnndsc "dev@babymri.org"

# Pass a UID on build command line (see above) to set internal UID
ARG UID=1001
ENV UID=$UID

RUN apt-get update \
  && apt-get install sudo                                             \
  && useradd -u $UID -ms /bin/bash localuser                          \
  && addgroup localuser sudo                                          \
  && echo "localuser:localuser" | chpasswd                            \
  && adduser localuser sudo                                           \
  && apt-get install -y libssl-dev libcurl4-openssl-dev bsdmainutils vim net-tools inetutils-ping \
  && apt-get install -y xinetd                                        \
  && apt-get install -y dcmtk                                         \
  && pip3 install pypx==0.10                                          \
  && pip3 install pfmisc==1.0.1                                       \
  && pip3 install pfdcm==1.1.5.dev0

COPY ./docker-entrypoint.py /dock/docker-entrypoint.py
RUN chmod 777 /dock                                                   \
  && chmod 777 /dock/docker-entrypoint.py                             \
  && echo "localuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENTRYPOINT ["/dock/docker-entrypoint.py"]
EXPOSE 5055

CMD ["/usr/sbin/xinetd", "--dontfork"]

# Start as user $UID
# USER $UID

