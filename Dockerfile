#######
# Image for creating Koha Restful container
#######

FROM busybox

MAINTAINER Oslo Public Library "digitalutvikling@gmail.com"

ENV REFRESHED_AT 2014-10-20
ENV KOHA_INSTANCE name
ENV KOHA_SRC /usr/share/koha

ADD ./etc/rest/config.yaml /etc/koha/$KOHA_INSTANCE/config.yaml
ADD ./opac/rest.pl $KOHA_SRC/opac/rest.pl

ADD ./Koha/REST $KOHA_SRC/Koha/REST
ADD ./t/rest $KOHA_SRC/t/rest

VOLUME ["$KOHA_SRC/Koha/REST", "$KOHA_SRC/REST/t/rest"]

CMD /bin/sh