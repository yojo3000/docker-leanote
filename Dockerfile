FROM ubuntu

RUN apt update; apt upgrade -y; apt autoremove -y;

RUN apt install \
vim \
wget \
curl \
unzip \
golang \
-y

# install mongodb client tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list
RUN apt update
RUN apt install mongodb-org-shell iputils-ping dnsutils net-tools -y
RUN apt install mongodb-org-tools -y

# golang project path
RUN mkdir /root/gopackage

# leanote code, put them into golang project path
RUN wget https://github.com/leanote/leanote-all/archive/master.zip
RUN unzip master.zip
RUN mv leanote-all-master/src /root/gopackage

# golang revel web framework
ENV GOPATH=/root/gopackage
RUN go install github.com/revel/cmd/revel

# leanote configuration, set localhost to hostname / ip address
ENV PATH="$PATH:$GOPATH/bin"
RUN sed -i 's/db.host=127.0.0.1/db.host=mongodb/g' $GOPATH/src/github.com/leanote/leanote/conf/app.conf
RUN sed -i 's/localhost:9000/192.168.168.8:9000/g' $GOPATH/src/github.com/leanote/leanote/conf/app.conf

# init database to mongodb
RUN mongorestore -h mongodb -d leanote /root/gopackage/src/github.com/leanote/leanote/mongodb_backup/leanote_install_data/
RUN mongo mongodb:27017

