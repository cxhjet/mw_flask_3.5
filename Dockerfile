FROM cxhjet/flask3.5:1.4
COPY ./requirements.txt /var/requirements.txt

RUN  apk add --no-cache --virtual .build-deps  \
		git \
    && pip3 uninstall mwutils -y \
    && pip3 uninstall mwauth -y  \
    && pip3 uninstall mwsdk -y  \
    && pip3 uninstall mwpermission -y \
    && pip3 install -r /var/requirements.txt \
    && find /usr/local -depth \
		\( \
		    \( -type d -a -name test -o -name tests \) \
		    -o \
		    \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' + \
	&& runDeps="$( \
		scanelf --needed --nobanner --recursive /usr/local \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --virtual .python-rundeps $runDeps \
    && apk del .build-deps
