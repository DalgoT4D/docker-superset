# Use the specific Superset base image
FROM apache/superset:6.1.0

# Switching to root to install the required packages
USER root

# Set environment variable for Playwright
ENV PLAYWRIGHT_BROWSERS_PATH=/usr/local/share/playwright-browsers

# Install system packages
RUN apt-get update && apt-get install -y \
    python3-dev \
    default-libmysqlclient-dev \
    build-essential \
    pkg-config \
    libssl-dev \
    libffi-dev \
    python3-pip \
    libsasl2-dev \
    libldap2-dev \
    chromium-driver


# Upgrade pip
RUN pip install --upgrade pip

# Install packages using uv into the virtual environment
RUN . /app/.venv/bin/activate && \
    uv pip install \
    # install psycopg2 for using PostgreSQL metadata store - could be a MySQL package if using that backend:
    psycopg2-binary pymssql sqlalchemy-bigquery pandas-gbq google-cloud-bigquery-storage flask_cors Flask-Mail asyncpg \
      # packages needed for various Superset features:  
    google-auth python-dotenv urllib3 requests botocore python-dotenv redis celery flower pytz\

    # package needed for using single-sign on authentication:
    Authlib \
    # openpyxl to be able to upload Excel files
    openpyxl \
    # Pillow for Alerts & Reports to generate PDFs of dashboards
    Pillow \
    # install Playwright for taking screenshots for Alerts & Reports. This assumes the feature flag PLAYWRIGHT_REPORTS_AND_THUMBNAILS is enabled
    # That feature flag will default to True starting in 6.0.0
    # Playwright works only with Chrome.
    # If you are still using Selenium instead of Playwright, you would instead install here the selenium package and a headless browser & webdriver
    playwright \
    && playwright install-deps \
    && PLAYWRIGHT_BROWSERS_PATH=/usr/local/share/playwright-browsers playwright install chromium

# Switching back to using the `superset` user
USER superset

# Copy jinja_context file
COPY assets/superset/jinja_context.py /app/superset/jinja_context.py

# Copy templates folder
COPY assets/superset/templates/ /app/superset/templates/

# Copy daos folder
COPY assets/superset/daos/ /app/superset/daos/