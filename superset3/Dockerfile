FROM apache/superset:3.1.3

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
RUN pip install --no-cache gevent psycopg2-binary redis celery flower pytz
RUN pip install --upgrade urllib3 requests botocore boto3 authlib python-dotenv
RUN pip install --upgrade sqlalchemy-bigquery pandas_gbq google-auth

# Example: installing a driver to connect to Redshift
# Find which driver you need based on the analytics database
# you want to connect to here:
# https://superset.apache.org/installation.html#database-dependencies
# RUN pip install sqlalchemy-redshift

# Switching back to using the `superset` user
USER superset

# copy contents of assets/ to /app/ in the container
COPY assets/pythonpath/superset_config.py /app/pythonpath/superset_config.py
COPY assets/pythonpath/client_color_palettes.py /app/pythonpath/client_color_palettes.py
COPY assets/superset/custom_user.py /app/superset/custom_user.py
COPY assets/superset/jinja_context.py /app/superset/jinja_context.py
COPY assets/superset/templates/appbuilder/baselayout.html /app/superset/templates/appbuilder/baselayout.html
COPY assets/superset/templates/superset/basic.html /app/superset/templates/superset/basic.html
COPY assets/superset/daos/log.py /app/superset/daos/log.py
COPY assets/superset/static/assets/images/logo.png /app/superset/static/assets/images/logo.png

# COPY scripts/uploadusers.py /app/uploadusers.py
