import os
from datetime import timedelta
from cachelib.redis import RedisCache
from superset.superset_typing import CacheConfig
from celery.schedules import crontab

SQLALCHEMY_DATABASE_URI = os.environ["SQLALCHEMY_DATABASE_URI"]
FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
    "ALERT_REPORTS": True,
}

# Default cache for Superset objects
CACHE_CONFIG: CacheConfig = {
    "CACHE_DEFAULT_TIMEOUT": int(timedelta(days=1).total_seconds()),
    # should the timeout be reset when retrieving a cached value
    "REFRESH_TIMEOUT_ON_RETRIEVAL": True,
    "CACHE_TYPE": "RedisCache",
    "CACHE_KEY_PREFIX": "superset_results",
    "CACHE_REDIS_URL": "redis://superset_cache:6379/0",
}

# Cache for datasource metadata and query results
DATA_CACHE_CONFIG: CacheConfig = {
    "CACHE_DEFAULT_TIMEOUT": int(timedelta(days=1).total_seconds()),
    # should the timeout be reset when retrieving a cached value
    "REFRESH_TIMEOUT_ON_RETRIEVAL": True,
    "CACHE_TYPE": "RedisCache",
    "CACHE_KEY_PREFIX": "superset_data_cache",
    "CACHE_REDIS_URL": "redis://superset_cache:6379/0",
}

# Cache for dashboard filter state (`CACHE_TYPE` defaults to `SimpleCache` when
#  running in debug mode unless overridden)
FILTER_STATE_CACHE_CONFIG: CacheConfig = {
    "CACHE_DEFAULT_TIMEOUT": int(timedelta(days=1).total_seconds()),
    # should the timeout be reset when retrieving a cached value
    "REFRESH_TIMEOUT_ON_RETRIEVAL": True,
    "CACHE_TYPE": "RedisCache",
    "CACHE_KEY_PREFIX": "superset_filter_cache",
    "CACHE_REDIS_URL": "redis://superset_cache:6379/0",
}

# Cache for explore form data state (`CACHE_TYPE` defaults to `SimpleCache` when
#  running in debug mode unless overridden)
EXPLORE_FORM_DATA_CACHE_CONFIG: CacheConfig = {
    "CACHE_DEFAULT_TIMEOUT": int(timedelta(days=1).total_seconds()),
    # should the timeout be reset when retrieving a cached value
    "REFRESH_TIMEOUT_ON_RETRIEVAL": True,
    "CACHE_TYPE": "RedisCache",
    "CACHE_KEY_PREFIX": "superset_explore_form_data_cache",
    "CACHE_REDIS_URL": "redis://superset_cache:6379/0",
}


REDIS_HOST = "superset_cache"
REDIS_PORT = "6379"


class CeleryConfig:  # pylint: disable=too-few-public-methods
    broker_url = "redis://superset_cache:6379/0"
    imports = (
        "superset.sql_lab",
        "superset.tasks",
    )
    result_backend = "redis://superset_cache:6379/0"
    worker_log_level = "DEBUG"
    worker_prefetch_multiplier = 10
    task_acks_late = True
    task_annotations = {
        "sql_lab.get_sql_results": {
            "rate_limit": "100/s",
        },
        "email_reports.send": {
            "rate_limit": "1/s",
            "time_limit": 120,
            "soft_time_limit": 150,
            "ignore_result": True,
        },
    }
    beat_schedule = {
        "email_reports.schedule_hourly": {
            "task": "email_reports.schedule_hourly",
            "schedule": crontab(minute=1, hour="*"),
        },
        # https://superset.apache.org/docs/installation/alerts-reports/
        "reports.scheduler": {
            "task": "reports.scheduler",
            "schedule": crontab(minute="*", hour="*"),
        },
    }


CELERY_CONFIG = CeleryConfig  # pylint: disable=invalid-name


RESULTS_BACKEND = RedisCache(
    host="superset_cache", port=6379, key_prefix="superset_results"
)


EMAIL_NOTIFICATIONS = True
SMTP_HOST = os.environ["SMTP_HOST"]
SMTP_PORT = os.environ["SMTP_PORT"]
SMTP_STARTTLS = True
SMTP_SSL = False
SMTP_USER = os.environ["SMTP_USER"]
SMTP_PASSWORD = os.environ["SMTP_PASSWORD"]
SMTP_MAIL_FROM = os.environ["SMTP_MAIL_FROM"]
SMTP_SSL_SERVER_AUTH = False

WEBDRIVER_BASEURL = "http://superset:8088/"
