import os
from Bio import SeqIO
from Bio.Seq import Seq


def get_config():
    return config["default"]


def get_pool():
    return get_config()["pool"]["id"]


sublib_ids = get_config()["sublibraries"].keys()

cutadapt_log_command = " | sed '/^Finished in /d' > {log}"
