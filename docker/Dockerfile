FROM docker.io/bitnami/rails:5

USER root

RUN mkdir -p /var/lib/apt/lists && install_packages shared-mime-info curl && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    install_packages nodejs

RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarnkey.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get -qq update && apt-get -qqy install yarn

RUN sed -i '1 s/bash$/bash -x/' /app-entrypoint.sh

USER bitnami
