FROM nginx:latest

RUN rm -rf /etc/nginx/conf.d/
COPY ./conf.d/ /etc/nginx/conf.d/

COPY ./index.html /usr/share/nginx/html/swag/index.html
COPY ./code /usr/share/nginx/html/code/code
COPY ./images/ /usr/share/nginx/html/images/
