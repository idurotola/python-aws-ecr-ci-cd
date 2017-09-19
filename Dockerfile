# Building on top of Ubuntu 14.04. The best distro around.
FROM tiangolo/uwsgi-nginx-flask:python2.7

# copy over our requirements.txt file
COPY requirements.txt /tmp/

# upgrade pip and install our requirements
RUN pip install -U pip
RUN pip install -r /tmp/requirements.txt

COPY ./app /app