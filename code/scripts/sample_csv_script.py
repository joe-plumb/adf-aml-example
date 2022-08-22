import argparse
import os

try:
    parser = argparse.ArgumentParser()
    # parser.add_argument("--arg1", type=str, help="sample string argument")
    parser.add_argument("--arg1", type=str, help="sample datapath argument")
    args = parser.parse_args()

    # print("Sample string argument  : %s" % args.arg1)
    print("Sample datapath argument: %s" % args.datapath)

    print(datapath_input, dir(datapath_input))

except Exception as e:
    print(f"Encountered error processing {datapath_input} :")
    print(e)
