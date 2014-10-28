#######
# Image for creating Koha Restful container
#######

FROM busybox

MAINTAINER Oslo Public Library "digitalutvikling@gmail.com"

ENV REFRESHED_AT 2014-10-20
ENV KOHA_INSTANCE name
ENV KOHA_SRC /usr/share/koha

# Add files
ADD ./etc/rest/config.yaml /etc/koha/sites/$KOHA_INSTANCE/rest/config.yaml
ADD ./opac/rest.pl $KOHA_SRC/opac/rest.pl

# Add folders to use as default in volumes
ADD ./Koha/REST $KOHA_SRC/Koha/REST
ADD ./t/rest $KOHA_SRC/t/rest

VOLUME ["/etc/koha/sites/$KOHA_INSTANCE/rest", "$KOHA_SRC/Koha/REST", "$KOHA_SRC/t/rest"]

CMD /bin/sh
