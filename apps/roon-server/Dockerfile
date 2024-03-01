	
FROM	ghcr.io/onedr0p/ubuntu:jammy-20231004@sha256:6e060e90482632408063d0fbb4b616c77914ef10eaa6b089a00de5815471006c
USER	root
RUN	apt-get -qq update \
	&& apt-get install -y \
	ffmpeg \
	libasound2 \
	libicu70 \
	cifs-utils \
	alsa \
	usbutils \
	udev \
	curl \
	wget \
	bzip2 \
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf         /tmp/*         /var/lib/apt/lists/*         /var/cache/apt/*         /var/tmp/*
ENV	ROOTPATH	/app/RoonServer
ARG	VERSION
ARG	ROON_PACKAGE_URI=https://download.roonlabs.net/updates/production/RoonServer_linuxx64_${VERSION}.tar.bz2
RUN	wget --progress=bar:force --tries=2 -O - ${ROON_PACKAGE_URI} | tar -xvj --overwrite -C /app \
	&& ${ROOTPATH}/check.sh
EXPOSE	9003/udp
EXPOSE	9100/tcp
EXPOSE	9100-9200/tcp
EXPOSE	9200/tcp
EXPOSE	30000-30010/tcp
EXPOSE	9330-9339/tcp
EXPOSE	49863/tcp
EXPOSE	52667/tcp
EXPOSE	52709/tcp
EXPOSE	63098-63100/tcp
RUN	mkdir /data \
	&& chown -R root:root /app \
	&& chmod -R 555 /app \
	&& chown -R kah:kah /data \
	&& chmod -R 755 /data \
	&& printf "umask %d\n" "${UMASK}" >> /etc/bash.bashrc
COPY	/roon-entrypoint.sh	/roon-entrypoint.sh
COPY	/RoonAppliance	${ROOTPATH}/Appliance/RoonAppliance
COPY	/RAATServer	${ROOTPATH}/Appliance/RAATServer
USER	kah
ENV	DISPLAY	localhost:0.0
ENV	ROON_DATAROOT	/data
ENV	ROON_ID_DIR	/data
WORKDIR	${ROOTPATH}
VOLUME	/data
CMD	["/roon-entrypoint.sh"]
