import json
import logging
import os
import sys
from typing import Dict, List

from jinja2 import Template

# global variables
CONFIG_PATH = "tracers.json"


def import_json(path: str) -> Dict[str, List[str]]:
    """Import json data into a dictionary.

    Parameters
    ----------
    path : str
        file path

    Returns
    -------
    Dict[str, List[str]]
        the json data in dict format
    """

    data = {}
    with open(path, "r") as file:
        data = json.load(file)
    return data


def read_to_str(path: str) -> str:
    """Read a file data into a string.

    Parameters
    ----------
    path : str
        file path

    Returns
    -------
    str
        the file data in string format
    """

    try:
        data = ""
        with open(path, "r") as file:
            data = file.read()
        return data
    except Exception:
        return ""


def read_template(path: str) -> Template:
    """Read template into jinja2 object.

    Parameters
    ----------
    path : str
        file path

    Returns
    -------
    Template
        the template in jinja2 Template format
    """

    return Template(open(path).read())


def save_template(out: str, data: str) -> None:
    """Save the templates into files.

    Parameters
    ----------
    out : str
        output path
    data : str
        content to write
    """

    with open(out, "w") as file:
        file.write(data)


def main():
    # load the configs
    cfg = import_json(CONFIG_PATH)

    logging.info(f"loading templates from {CONFIG_PATH}")

    # form the template paths
    templates_dir_path = os.path.join(cfg["templates_dir"], cfg["sources_dir"])

    # generate bpftrace scripts by going through inputs and sources
    for entry in cfg["inputs"]:
        logging.info(f"generating tracing templates for {entry}")

        # form the paths
        dir_path = os.path.join(cfg["templates_dir"], cfg["inputs_dir"], entry)
        filter_path = os.path.join(dir_path, "filter.bt")
        begin_path = os.path.join(dir_path, "begin.bt")
        output_dir_path = os.path.join(cfg["outputs_dir"], entry)

        os.makedirs(output_dir_path, exist_ok=True)
        os.makedirs(os.path.join(output_dir_path, "v0"), exist_ok=True)
        os.makedirs(os.path.join(output_dir_path, "v1"), exist_ok=True)

        # read inputs
        filter_section = read_to_str(filter_path)
        begin_section = read_to_str(begin_path)

        # read configs template
        cfg_tmp = read_template(cfg["config_source"])
        cfg_section = cfg_tmp.render(**cfg["configs"])

        # create the outputs
        for out in cfg["sources"]:
            logging.info(f"exporting script {entry} : {out}")

            # form the paths
            template_path = os.path.join(templates_dir_path, out) + ".j2"

            # export with or without capture_metadata
            output_path = os.path.join(output_dir_path, out)
            tmp = read_template(template_path)

            res = tmp.render(
                config_section=cfg_section,
                begin_section=begin_section,
                filter=filter_section,
                capture_metadata=True,
            )

            save_template(output_path, res)

            logging.info(f"template saved: {output_path}")

            parts = out.split("/")
            new_out = parts[0] + "/headless_" + parts[1]
            output_path = os.path.join(output_dir_path, new_out)
            tmp = read_template(template_path)

            res = tmp.render(
                config_section=cfg_section,
                begin_section=begin_section,
                filter=filter_section,
                capture_metadata=False,
            )

            save_template(output_path, res)

            logging.info(f"template saved: {output_path}")

    logging.info("done")


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    try:
        main()
    except Exception as e:
        logging.error(f"error: {e}")
        sys.exit(1)
