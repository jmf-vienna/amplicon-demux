import os
import csv
from Bio.Seq import Seq

libraries = {}
with open("demux.tsv") as tsv_file:
    reader = csv.DictReader(tsv_file, delimiter="\t")
    for row in reader:
        libraries[row["id"]] = row


def get_config():
    return config["default"]["demux"]


def get_pools():
    return sorted(set([v["pool"] for k, v in libraries.items()]))


def get_min_length():
    return get_config()["read length"]["min"]


def get_max_length():
    return get_config()["read length"]["max"]
