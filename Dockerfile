#######
# Busybox image for creating koha-restful image
#######

FROM busybox

MAINTAINER Oslo Public Library "digitalutvikling@gmail.com"

ENV REFRESHED_AT 2014-10-20
ENV KOHA_INSTANCE name
ENV KOHA_SRC /usr/share/koha/

#######
# 
#######

ADD ./etc/rest /etc/koha/$KOHA_INSTANCE/

ADD ./Koha/REST $KOHA_SRC/Koha/

ADD ./opac/rest.pl $KOHA_SRC/opac/rest.pl

ADD ./t/rest $KOHA_SRC/t/

VOLUME ["$KOHA_SRC/Koha/REST", "$KOHA_SRC/REST/t/rest"]

CMD /bin/sh