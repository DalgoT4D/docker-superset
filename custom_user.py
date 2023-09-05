"""https://flask-appbuilder.readthedocs.io/en/latest/security.html#extending-the-user-model"""

from flask_appbuilder.security.sqla.models import User
from flask_appbuilder.security.views import UserOAuthModelView
from sqlalchemy import Column, Text
from superset.security import SupersetSecurityManager


class CustomUser(User):
    """extend the user by adding a blob field"""

    __tablename__ = "ab_user"
    blob = Column(Text)


class CustomUserModelView(UserOAuthModelView):
    """a new view to allow the display and editing of the blob column"""

    edit_columns = [
        "first_name",
        "last_name",
        "username",
        "active",
        "email",
        "roles",
        "blob",
    ]


class CustomSecurityManager(SupersetSecurityManager):
    """register both of these via a custom security manager"""

    user_model = CustomUser
    useroauthmodelview = CustomUserModelView
