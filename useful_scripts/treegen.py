#!/usr/bin/env python3
import os
import argparse
import sys

def generate_tree(start_path, output_file, ignore_dirs=None, ignore_files=None, max_depth=None):
    """
    Generates a text file representing the directory tree structure.

    Args:
        start_path (str): The root directory to start traversing from.
        output_file (str): The path to the output text file.
        ignore_dirs (list, optional): A list of directory names to ignore. Defaults to common ones.
        ignore_files (list, optional): A list of file names or patterns to ignore. Defaults to None.
        max_depth (int, optional): Maximum depth to traverse. Defaults to None (unlimited).
    """
    if ignore_dirs is None:
        ignore_dirs = ['.git', '__pycache__', '.vscode', '.idea', 'node_modules', 'venv', 'env', '.env']
    if ignore_files is None:
        ignore_files = []

    if not os.path.isdir(start_path):
        print(f"Error: Starting path '{start_path}' is not a valid directory.")
        sys.exit(1)

    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(f"Folder tree starting from: {os.path.abspath(start_path)}\n")
            f.write("=" * 40 + "\n")

            start_level = start_path.count(os.sep)
            for root, dirs, files in os.walk(start_path, topdown=True):
                # --- Depth Control ---
                current_level = root.count(os.sep) - start_level
                if max_depth is not None and current_level >= max_depth:
                    dirs[:] = []
                    continue

                # --- Directory Filtering ---
                dirs[:] = [d for d in dirs if d not in ignore_dirs]

                # --- Indentation and Output ---
                indent = ' ' * 4 * current_level
                f.write(f"{indent}└── {os.path.basename(root)}/\n")

                sub_indent = ' ' * 4 * (current_level + 1)
                # --- File Filtering and Output ---
                files_to_print = sorted([
                    filename for filename in files
                    if filename not in ignore_files and not filename.startswith('.')
                ])
                for filename in files_to_print:
                    f.write(f"{sub_indent}├── {filename}\n")

        print(f"Folder structure saved to: {output_file}")

    except IOError as e:
        print(f"Error writing to output file '{output_file}': {e}")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a text representation of a folder structure.")
    parser.add_argument(
        "--root",
        type=str,
        default=".",
        help="The root directory to start scanning from (default: current directory)."
    )
    parser.add_argument(
        "--output",
        type=str,
        default="folder_structure.txt",
        help="The name of the text file to save the structure to (default: folder_structure.txt)."
    )
    parser.add_argument(
        "--depth",
        type=int,
        default=None,
        help="Maximum directory depth to scan (default: unlimited)."
    )
    parser.add_argument(
        "--ignore-dir",
        action='append',
        default=['.git', '__pycache__', '.vscode', '.idea', 'node_modules', 'venv', 'env', '.env'],
        help="Directory names to ignore (can be specified multiple times)."
    )
    parser.add_argument(
        "--ignore-file",
        action='append',
        default=[],
        help="File names to ignore (can be specified multiple times)."
    )
    parser.add_argument(
        "--excludedir",
        nargs="+",
        default=[],
        help="One or more directory names to exclude (e.g. --excludedir dir1 dir2 dir3)."
    )

    args = parser.parse_args()

    # Merge ignore-dir and excludedir into one list
    all_ignored_dirs = list(set(args.ignore_dir + args.excludedir))

    start_directory = os.path.abspath(args.root)

    generate_tree(
        start_path=start_directory,
        output_file=args.output,
        ignore_dirs=all_ignored_dirs,
        ignore_files=args.ignore_file,
        max_depth=args.depth
    )