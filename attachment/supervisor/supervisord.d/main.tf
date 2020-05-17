[supervisord]
nodaemon=true

[program:rails]
command=bash -lc 'cd $ROOT_PATH;bundle exec puma'
user=root
autostart=true
autorestart=true
redirect_stderr=true
exitcodes=1