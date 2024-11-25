import os
from Bio import SeqIO
from Bio.Seq import Seq


def get_config():
    return config["default"]


def get_pools():
    return set([v["pool"] for k, v in get_config()["sublibraries"].items()])


sublib_ids = get_config()["sublibraries"].keys()

cutadapt_log_command = " | sed '/^Finished in /d' > {log}"
