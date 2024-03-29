"""
this script will be copied into and run from within the docker container
"""
import argparse
import json
import os
from dotenv import load_dotenv

from superset.custom_user import CustomUser
from sqlalchemy import create_engine, select

load_dotenv()
DBCONNECTION = os.getenv("DBCONNECTION")
engine = create_engine(DBCONNECTION)
from sqlalchemy.orm import sessionmaker
from flask_appbuilder.security.sqla.models import Role

Session = sessionmaker(bind=engine)

parser = argparse.ArgumentParser()
parser.add_argument(
    "-f",
    "--file",
    default="/host_data/users.json",
    help="JSON file containing users to upsert, usually from /host_data/",
)
parser.add_argument(
    "--create-new",
    action="store_true",
    help="Create new users. Without this flag only update existing users",
)
args = parser.parse_args()


def read_json(filename: str):
    """reads and returns all objects in the json specified by the user"""
    with open(filename, "r", encoding="utf-8") as infile:
        return json.load(infile)


# == start
# load roles from database
session = Session()
DBROLES = {}
for rr in session.scalars(select(Role)).all():
    DBROLES[rr.name] = rr

# we treat `email` as the comparison key
users_to_upload = read_json(args.file)

for jsonuser in users_to_upload["users"]:
    email = jsonuser["email"].strip().lower()
    # first see if the user is already in the db, check by email address
    query = select(CustomUser).where(CustomUser.email == email)
    result = session.scalars(query).all()

    if len(result) > 1:
        raise ValueError(f"too many results matching email={email}")

    if len(result) == 1:
        user = result[0]
        print(f"found user having email {email}")
    elif args.create_new:
        user = CustomUser()
        session.add(user)
        user.username = jsonuser["username"]
        print(f"creating user with email {email}")
    else:
        print(f"skipping user with email {email}")
        continue

    user.first_name = jsonuser["first_name"]
    user.last_name = jsonuser["last_name"]
    user.email = email
    user.roles = [DBROLES[role_str] for role_str in jsonuser["roles"]]
    user.blob = json.dumps(jsonuser["blob"])

    print(f"writing user email={user.email} username={user.username} blob={user.blob}")
    session.commit()
