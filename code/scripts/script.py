import argparse
import os
import sys

print("In script.py")
print("As a data scientist, this is where I use my training code.")

parser = argparse.ArgumentParser("train")

parser.add_argument("--pipeline_arg", type=str, help="pipeline_arg")
parser.add_argument("--sampledata", type=str, help="sample data files")

args = parser.parse_args()

print("Argument 1: %s" % args.pipeline_arg)
print("Argument 2: %s" % args.sampledata)

for fname in args.sampledata:
    try:
        with open(fname, 'r') as fin:
            print(fin.read())

    except Exception as e:
        print(f"An ERROR happened: {e}")
