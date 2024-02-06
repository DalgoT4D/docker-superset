import json
import pandas as pd
import argparse

parser = argparse.ArgumentParser("creates users.json for SNEHA")
parser.add_argument("--csv", required=True)
parser.add_argument("--json", required=True)
args = parser.parse_args()

df = pd.read_csv(args.csv)
del df["Cluster Id"]
del df["Username"]

df.columns = ["program_code", "first_name", "last_name", "designation", "coid", "email"]


def mkblob(row):
    """this is our custom extension to the superset user object"""
    return {"coid": f"{row['coid']:02d}", "program_code": row["program_code"]}


def mkroles(row):  # pylint:disable=unused-argument
    """we always add gamma, and then other roles based on the user's needs"""
    if row["Designation"] == "CO":
        return ["Gamma", "Community Organizer"]
    return ["Gamma"]


df["blob"] = df.apply(mkblob, axis=1)
df["username"] = ""
df["roles"] = df.apply(mkroles, axis=1)

users = json.loads(
    df[["email", "username", "first_name", "last_name", "roles", "blob"]].to_json(
        orient="records"
    )
)

with open(args.json, "w", encoding="utf-8") as jsonfile:
    json.dump({"users": users}, jsonfile)
