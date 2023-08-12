from flask_appbuilder.security.sqla.models import User
from sqlalchemy import Column, Text
from superset.security import SupersetSecurityManager


class CustomUser(User):
    __tablename__ = "ab_user"
    blob = Column(Text)


class CustomSecurityManager(SupersetSecurityManager):
    user_model = CustomUser
