import os
import argparse
from datasets import load_from_disk
from colorama import Fore, Style, init

# Initialize Colorama for colored output
init(autoreset=True)

# --- Configuration ---
DATASET_DIR = "amiga_asm_dataset"

def analyze_dataset(query):
    """
    Searches the fine-tuning dataset for examples matching a query.
    """
    print(f"{Fore.CYAN}--- Analyzing Dataset for query: '{query}' ---{Style.RESET_ALL}")

    # Load the dataset from disk
    if not os.path.isdir(DATASET_DIR):
        print(f"{Fore.RED}Error: Dataset directory '{DATASET_DIR}' not found.{Style.RESET_ALL}")
        print("Please run the `prepare_dataset.py` script first.")
        return

    try:
        dataset = load_from_disk(DATASET_DIR)
        # Combine train and test splits for a full search
        full_dataset = dataset['train'].to_list() + dataset['test'].to_list()
    except Exception as e:
        print(f"{Fore.RED}Error loading dataset: {e}{Style.RESET_ALL}")
        return

    # Perform a case-insensitive search
    query = query.lower()
    matches = []
    for example in full_dataset:
        prompt = example.get('prompt', '').lower()
        completion = example.get('completion', '').lower()
        if query in prompt or query in completion:
            matches.append(example)

    # Display the results
    if not matches:
        print(f"{Fore.YELLOW}No examples found in the dataset matching '{query}'.{Style.RESET_ALL}")
        print("The model likely has limited knowledge on this topic.")
    else:
        print(f"Found {Fore.GREEN}{len(matches)}{Style.RESET_ALL} relevant examples in the dataset:")
        for i, match in enumerate(matches, 1):
            print("\n" + "="*50 + f" Match #{i} " + "="*50)
            print(f"{Fore.YELLOW}Prompt:{Style.RESET_ALL}")
            print(match.get('prompt', 'N/A'))
            print(f"\n{Fore.YELLOW}Completion (Code):{Style.RESET_ALL}")
            print(match.get('completion', 'N/A'))
        print("\n" + "="*110)
        print("Based on these examples, the model should be able to generate similar code.")

if __name__ == "__main__":
    # Set up command-line argument parsing
    parser = argparse.ArgumentParser(description="Analyze the Amiga assembly dataset to find relevant examples.")
    parser.add_argument("query", type=str, help="The keyword or phrase to search for in the dataset (e.g., 'copper list').")
    args = parser.parse_args()
    
    analyze_dataset(args.query)