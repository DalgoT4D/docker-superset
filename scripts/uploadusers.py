"""
this script will be copied into and run from within the docker container
"""
import argparse
from csv import DictReader

import logging

logger = logging.getLogger("uploadusers")
handler = logging.FileHandler("/logs/uploadusers.log")
handler.setLevel(logging.INFO)
formatter = logging.Formatter("[%(levelname)s] %(asctime)s: %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)


try:
    from custom_user import CustomUser
except ImportError:
    from superset.custom_user import CustomUser

from sqlalchemy import create_engine, select

engine = create_engine("postgresql://postgres:password@db/superset")

from sqlalchemy.orm import sessionmaker

Session = sessionmaker(bind=engine)

parser = argparse.ArgumentParser()
parser.add_argument(
    "-f",
    "--file",
    default="/host_data/users.csv",
    help="CSV file containing users to upsert, usually from /host_data/",
)
args = parser.parse_args()


def read_csv(filename: str):
    """reads and returns all objects in the csv specified by the user"""
    retval = []
    with open(filename, "r", encoding="utf-8") as infile:
        reader = DictReader(infile)
        logger.info("reading users from %s", filename)
        for obj in reader:
            retval.append(obj)
            logger.info(obj)
        logger.info("finished reading users from %s", filename)
    return retval


# == start
# we treat `email` as the comparison key
users_to_upload = read_csv(args.file)
session = Session()

for csvuser in users_to_upload:
    email = csvuser["email"].strip().lower()
    # first see if the user is already in the db, check by email address
    query = select(CustomUser).where(CustomUser.email == email)
    result = session.scalars(query).all()

    if len(result) > 1:
        raise ValueError(f"too many results matching email={email}")

    if len(result) == 1:
        user = result[0]
        logger.info("found user having email %s", email)
    else:
        user = CustomUser()
        session.add(user)
        logger.info("creating user with email %s", email)

    user.username = csvuser["username"]
    user.first_name = csvuser["first_name"]
    user.last_name = csvuser["last_name"]
    user.email = email
    user.blob = csvuser["blob"]

    logger.info(
        "writing user email=%s username=%s blob=%s",
        user.email,
        user.username,
        user.blob,
    )
    session.commit()
