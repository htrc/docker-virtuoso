FROM ubuntu:16.04

ENV VIRTUOSO_VERSION=7.2.4.2
ENV VIRTUOSO_SOURCE=https://github.com/openlink/virtuoso-opensource/releases/download/v$VIRTUOSO_VERSION/virtuoso-opensource-$VIRTUOSO_VERSION.tar.gz

RUN \
        # install runtime dependencies
        apt-get update \
        && apt-get install -y openssl crudini \

        # remember installed packages for later cleanup
        && dpkg --get-selections > /inst_packages.dpkg \

        # install build dependencies
        && apt-get install -y build-essential autotools-dev autoconf automake unzip wget net-tools libtool flex bison gperf gawk m4 libssl-dev libreadline-dev zlib1g-dev libbz2-dev openssl crudini \

        # download and extract virtuoso source
        && echo -n "downloading..." \
        && wget -nv "$VIRTUOSO_SOURCE" \
        && echo " done." \
        && echo -n "extracting..." \
        && tar -xaf virtuoso*.tar* \
        && rm virtuoso*.tar* \
        && echo " done." \

        # build virtuoso
        && cd virtuoso-opensource-*/ \
        && ./autogen.sh \
        && export CFLAGS="-O2 -m64" && ./configure --prefix=/opt/virtuoso --disable-bpel-vad --enable-conductor-vad --enable-fct-vad --disable-dbpedia-vad --disable-demo-vad --enable-isparql-vad --enable-ods-vad --enable-rdfmappers-vad --enable-rdb2rdf-vad --disable-sparqldemo-vad --enable-syncml-vad --disable-tutorial-vad --with-readline --without-internal-zlib --program-transform-name="s/isql/isql-v/" \
        && make && make install \
        && ln -s /opt/virtuoso/var/lib/virtuoso/db /db \
        && cd .. \
        && rm -r /virtuoso-opensource-* \

        # cleanup packages and caches for building virtuoso (reduce container size)
        && dpkg --clear-selections \
        && dpkg --set-selections < /inst_packages.dpkg \
        && rm /inst_packages.dpkg \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get -y dselect-upgrade \

        # allow virtuoso to access the /import DIR in container
        && sed -i '/^DirsAllowed\s*=/ s_\s*$_, /import_' /db/virtuoso.ini

# Add Virtuoso bin to the PATH
ENV PATH /opt/virtuoso/bin:$PATH

# Add Virtuoso config
COPY virtuoso.ini /virtuoso.ini

# Add dump_nquads_procedure
COPY dump_nquads_procedure.sql /dump_nquads_procedure.sql

# Add Virtuoso log cleaning script
COPY clean-logs.sh /clean-logs.sh

# Add startup script
COPY virtuoso.sh /virtuoso.sh

WORKDIR /db

VOLUME /db /import

EXPOSE 1111 8890

CMD ["/bin/bash", "/virtuoso.sh"]
