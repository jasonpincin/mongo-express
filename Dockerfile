FROM mongo-express:0.32

# we need Container Pilot to monitor consul for MongoDB cluster changes so we can update ME_CONFIG_MONGODB_SERVER appropriately
# "If it is a replica set, use a comma delimited list of the host names."

RUN apt-get update \
	&& apt-get install -y \
		ca-certificates \
		unzip \
		wget \
	&& rm -rf /var/lib/apt/lists/*

ENV CONTAINERPILOT_VERSION 2.6.0
ENV CONTAINERPILOT_SHA1 c1bcd137fadd26ca2998eec192d04c08f62beb1f
RUN set -x \
	&& wget -O containerpilot.tar.gz "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz" \
	&& echo "${CONTAINERPILOT_SHA1} *containerpilot.tar.gz" | sha1sum -c - \
	&& tar -xvf containerpilot.tar.gz -C /usr/local/bin \
	&& rm -v containerpilot.tar.gz

ENV CONSUL_TEMPLATE_VERSION 0.16.0
ENV CONSUL_TEMPLATE_SHA256 064b0b492bb7ca3663811d297436a4bbf3226de706d2b76adade7021cd22e156
RUN set -x \
	&& wget -O consul-template.zip "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" \
	&& echo "${CONSUL_TEMPLATE_SHA256} *consul-template.zip" | sha256sum -c - \
	&& unzip consul-template.zip -d /usr/local/bin \
	&& rm -v consul-template.zip

ENV CONTAINERPILOT file:///etc/containerpilot.json

COPY etc/* /etc/
COPY bin/* /usr/local/bin/

# override any parent entrypoint
ENTRYPOINT []
CMD [ \
	"containerpilot", \
# see comment in bin/mongo-express-wrapper.sh for why this is necessary
	"mongo-express-wrapper.sh", \
# this is taken from the "mongo-express" default CMD (minus "tini" since we have containerpilot instead)
	"node", "app" \
]