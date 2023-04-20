FROM python:3.6.15-slim-buster
RUN apt update
RUN apt install -y git libmagic-dev
RUN mkdir -p /usr/lib/ckan/default
RUN mkdir -p /var/lib/ckan/default
RUN python -m venv /usr/lib/ckan/default
RUN /usr/lib/ckan/default/bin/pip install setuptools==44.1.0
RUN /usr/lib/ckan/default/bin/pip install --upgrade pip
RUN /usr/lib/ckan/default/bin/pip install psycopg2-binary==2.8.2
COPY requirements.txt .
RUN /usr/lib/ckan/default/bin/pip install -e 'git+https://github.com/ckan/ckan.git@ckan-2.9.5#egg=ckan'
RUN /usr/lib/ckan/default/bin/pip install -r requirements.txt
RUN mkdir -p /etc/ckan/default
RUN mkdir -p /var/lib/ckan/default
RUN /usr/lib/ckan/default/bin/ckan generate config /etc/ckan/default/ckan.ini
RUN ln -s /usr/lib/ckan/default/src/ckan/who.ini /etc/ckan/default/who.ini
EXPOSE 5000
COPY ckan-entrypoint.sh /
