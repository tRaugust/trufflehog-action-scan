FROM python:3.7-alpine

LABEL name="trufflehog-actions-scan"
LABEL version="1.1.0"
LABEL repository="https://github.com/traugust/trufflehog-actions-scan"
LABEL homepage="https://github.com/traugust/trufflehog-actions-scan"
LABEL maintainer="Thomas Raugust"

LABEL "com.github.actions.name"="Trufflehog Actions Scan"
LABEL "com.github.actions.description"="Scan repository for secrets with basic trufflehog defaults in place for easy setup."
LABEL "com.github.actions.icon"="shield"
LABEL "com.github.actions.color"="yellow"

RUN pip install pyyaml truffleHog3
RUN apt-get install jq
RUN apk --update add git less openssh && \
  rm -rf /var/lib/apt/lists/* && \
  rm /var/cache/apk/*

ADD entrypoint.sh  /entrypoint.sh
ADD regexes.json /regexes.json

ENTRYPOINT ["/entrypoint.sh"]