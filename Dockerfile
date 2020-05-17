FROM ruby:2.6.5-alpine3.11

##################################Rails install
#RUN apk update && apk add libgcrypt-dev
ENV RAILS_VERSION="6.0" \
    BUILD_PACKAGES="build-base" \
    DEV_PACKAGES="libgcrypt-dev libxslt-dev libxml2-dev sqlite-dev postgresql-dev mysql-dev vim" \
    RUBY_PACKAGES="nodejs nodejs-npm yarn tzdata"

RUN apk --update add $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES

RUN gem install -N bundler && \
    gem install -N nokogiri -- --use-system-libraries && \
    gem install -N rails --version "$RAILS_VERSION" && \
  echo 'gem: --no-document' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc && \

  # cleanup and settings
  bundle config --global build.nokogiri  "--use-system-libraries" && \
  bundle config --global build.nokogumbo "--use-system-libraries" && \
  find / -type f -iname \*.apk-new -delete && \
  rm -rf /var/cache/apk/* && \
  rm -rf /usr/lib/lib/ruby/gems/*/cache/* && \
  rm -rf ~/.gem

##################################Supervisor install

ENV SUPERVISOR_VERSION=3.3.1

RUN apk update && apk add py-pip python ;\
    apk add bash curl

RUN pip install supervisor==$SUPERVISOR_VERSION
ADD ./attachment /attachment
RUN cp -arp /attachment/supervisor/supervisord.d /etc/supervisord.d ;\
    cp -arp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime ;\
    cp -arp /attachment/supervisor/supervisord.conf /etc/supervisord.conf ;\
    cp -arp /attachment/cmd/ready.sh /ready.sh

RUN sh /attachment/cmd/build_ready.sh ;\
    rm -rf /var/cache/apk/*

CMD sh /ready.sh && /usr/bin/supervisord -c /etc/supervisord.conf