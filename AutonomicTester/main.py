"""
This file contains the main function to run the Autonomic Tester application.
"""

from src.cli.cli import main_args_parser
import logging
import os


def main():
    """
    The main function to run the Autonomic Tester application.
    """
    args = main_args_parser.parse_args()

    if args.log_level is not None:
        logs_dir = os.environ.get("LOGS_DIR", None)
        log_level = getattr(logging, args.log_level)
        log_handlers = []
        if logs_dir is not None:
            file_handler = logging.FileHandler(logs_dir + "/autonomic_tester.log")
            file_handler.setLevel(log_level)
            file_handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s %(message)s'))
            log_handlers.append(file_handler)
        logging.basicConfig(level=log_level, handlers=log_handlers)

    args.func(args)


if __name__ == "__main__":
    main()
