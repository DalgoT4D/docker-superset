FROM apache/superset:2.1.0

# Switching to root to install the required packages
USER root

# https://superset.apache.org/docs/installation/alerts-reports/#custom-dockerfile
RUN apt-get update && \
  apt-get install --no-install-recommends -y firefox-esr wget

ENV GECKODRIVER_VERSION=0.29.0
RUN wget -q https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz && \
  tar -x geckodriver -zf geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz -O > /usr/bin/geckodriver && \
  chmod 755 /usr/bin/geckodriver && \
  rm geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz

# python packages
USER root
RUN pip install --upgrade pip
RUN pip install --no-cache gevent psycopg2-binary redis celery flower
RUN pip install --upgrade urllib3 requests botocore boto3 authlib python-dotenv
RUN pip install --upgrade sqlalchemy-bigquery

# Example: installing a driver to connect to Redshift
# Find which driver you need based on the analytics database
# you want to connect to here:
# https://superset.apache.org/installation.html#database-dependencies
# RUN pip install sqlalchemy-redshift

# Switching back to using the `superset` user
USER superset

COPY superset_config.py /app/pythonpath/superset_config.py
COPY custom_user.py /app/superset/custom_user.py
COPY jinja_context.py /app/superset/jinja_context.py
COPY baselayout.html /app/superset/templates/appbuilder/baselayout.html
COPY basic.html /app/superset/templates/superset/basic.html
COPY importexport.py /app/superset/cli/importexport.py
COPY scripts/uploadusers.py /app/uploadusers.py

# this repo ships with the tech4dev logo, replace it if you need to
COPY logo.png /app/superset/static/assets/images/logo.png
