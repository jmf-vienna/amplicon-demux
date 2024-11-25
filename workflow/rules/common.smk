import os
from Bio import SeqIO
from Bio.Seq import Seq


def get_config():
    return config["default"]["demux"]


def get_pools():
    return set([v["pool"] for k, v in get_config()["libraries"].items()])


def get_library_ids():
    return get_config()["libraries"].keys()


cutadapt_log_command = " | sed '/^Finished in /d' > {log}"
