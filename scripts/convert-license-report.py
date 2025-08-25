#
# Copyright (c) 2025 by Dribia Data Research.
# This file is part of project Github,
# and is released under the MIT License Agreement.
# See the LICENSE file for more information.
#
"""Simple script to create a table-like license report.

It takes the output license report of liccheck and converts it
to CSV, with the relevant information we want to hand-in at the
end of the project. This is, package dependencies and their licenses.

Args:
    -f, --file: License report file path.
    -co, --csv-output: Path of the output CSV license report file.
    -ro, --rst-output: Path of the output RST license report file.

"""

import csv
import sys
from argparse import ArgumentParser, RawTextHelpFormatter
from pathlib import Path

import pandas as pd

if __name__ == "__main__":
    parser = ArgumentParser(
        description="Convert a liccheck license report file to csv.",
        formatter_class=RawTextHelpFormatter,
    )
    parser.add_argument(
        "-f",
        "--file",
        dest="file",
        help="License report file to convert.",
        required=True,
    )
    parser.add_argument(
        "-co",
        "--csv-output",
        dest="csv_output_file",
        help="Converted output file in CSV format.",
        required=True,
    )
    parser.add_argument(
        "-ro",
        "--rst-output",
        dest="rst_output_file",
        help="Converted output file.",
        required=False,
    )

    args = parser.parse_args(sys.argv[1:])

    header = ["Name", "Version", "License"]
    rows = []
    with Path(args.file).open() as f:
        for line in f:
            pkg_name, pkg_version, *license_name_list, license_status = tuple(
                x.strip() for x in line.split(" ")
            )
            license_name = " ".join(license_name_list)
            rows.append([pkg_name, pkg_version, license_name])

    if args.csv_output_file:
        with Path(args.csv_output_file).open(mode="w", newline="") as csv_file:
            csv_writer = csv.writer(
                csv_file, delimiter=";", quotechar="|", quoting=csv.QUOTE_MINIMAL
            )
            csv_writer.writerow(header)
            csv_writer.writerows(rows)

    if args.rst_output_file:
        license_df = pd.DataFrame(
            {header[i]: [r[i] for r in rows] for i in range(len(header))}
        )
        md_table = license_df.to_markdown(tablefmt="grid", index=False)
        with Path(args.rst_output_file).open(mode="w") as f:
            f.write(md_table)
