FROM --platform=linux/amd64 apache/superset:4.1.1

ARG ARCH_TYPE=linux/amd64

# Switching to root to install the required packages
USER root

# https://superset.apache.org/docs/installation/alerts-reports/#custom-dockerfile
RUN apt-get update && \
  apt-get install --no-install-recommends -y firefox-esr wget

RUN pip install flask_cors  

ENV GECKODRIVER_VERSION=0.35.0

RUN if [ "$ARCH_TYPE" = "linux/amd64" ]; then \
      wget -q https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz && \
      tar -x geckodriver -zf geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz -O > /usr/bin/geckodriver && \
      rm geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz; \
    elif [ "$ARCH_TYPE" = "linux/arm64" ]; then \
      wget -q https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux-aarch64.tar.gz && \
      tar -x geckodriver -zf geckodriver-v${GECKODRIVER_VERSION}-linux-aarch64.tar.gz -O > /usr/bin/geckodriver && \
      rm geckodriver-v${GECKODRIVER_VERSION}-linux-aarch64.tar.gz; \
    else \
      echo "Unsupported architecture: $ARCH_TYPE" && exit 1; \
    fi && \
    chmod 755 /usr/bin/geckodriver

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

# Copy jinja_context file
COPY assets/superset/jinja_context.py /app/superset/jinja_context.py

# Copy templates folder
COPY assets/superset/templates/ /app/superset/templates/

# Copy daos folder
COPY assets/superset/daos/ /app/superset/daos/

# COPY scripts/uploadusers.py /app/uploadusers.py

# # this repo ships with the tech4dev logo, replace it if you need to
# COPY assets/logo.png /app/superset/static/assets/images/logo.png