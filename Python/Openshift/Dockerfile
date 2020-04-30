FROM registry.access.redhat.com/ubi8/go-toolset:latest as builder

ENV SKOPEO_VERSION=v0.2.0

RUN git clone -b $SKOPEO_VERSION https://github.com/containers/skopeo.git && \
    cd skopeo/ && \
    make binary-local DISABLE_CGO=1

USER root
RUN wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz &&\
    tar xvf openshift-origin-client-tools*.tar.gz &&\
    cd openshift-origin-client*/ &&\
    mv oc kubectl /usr/local/bin/ &&\
    rm -rf openshift-origin-client* &&\
    wget https://storage.googleapis.com/knative-nightly/client/latest/kn-linux-amd64 &&\
    mv kn-linux-amd64 /usr/local/bin/kn && chmod +x /usr/local/bin/kn 
USER 1001

FROM registry.redhat.io/ubi8/python-36

COPY --from=builder /usr/local/bin/* /usr/local/bin/
USER root
RUN mkdir /etc/containers/

COPY --from=builder /opt/app-root/src/skopeo/default-policy.json /etc/containers/policy.json
COPY --from=builder /opt/app-root/src/skopeo/skopeo /usr/bin/

USER 1001
