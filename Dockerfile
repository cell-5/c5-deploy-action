FROM debian:9.5-slim

RUN apt update
RUN apt -yq install rsync openssh-client openssl ca-certificates

LABEL "maintainer"="Peter Barry <peter@cell5.co.uk>"
LABEL "com.github.actions.name"="c5-deploy-action"
LABEL "com.github.actions.description"="Deploy to a remote server using rsync or sftp over ssh with arbitary command running support"
LABEL "com.github.actions.icon"="server"
LABEL "com.github.actions.color"="green"
LABEL "version"="1.0.0"

LABEL "repository"="https://github.com/cell-5/c5-deploy-action"
LABEL "homepage"="https://github.com/cell-5/c5-deploy-action"

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]