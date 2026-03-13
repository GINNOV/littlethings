import os
import glob
import re
import csv
import fitz # PyMuPDF
from datasets import Dataset
from colorama import Fore, Style, init

# Initialize Colorama for colored output
init(autoreset=True)

# --- Configuration: File-based sources for parameters and data ---
SETTINGS_DIR = "model_settings"
REPOS_FILE = os.path.join(SETTINGS_DIR, "repos.csv")
PROMPT_FILE = os.path.join(SETTINGS_DIR, "prompt1.txt")
FINE_PARAMS_FILE = os.path.join(SETTINGS_DIR, "fine_params.txt")
KEYWORDS_FILE = os.path.join(SETTINGS_DIR, "code_keywords.txt")

LOCAL_SOURCE_DIR = "sources"
PDF_SOURCE_DIR = "pdf_docs"
source_dir = "source_code"
output_dir = "amiga_asm_dataset"

# --- Helper Functions ---

def is_good_assembly_file(content, file_path):
    """
    Applies rules to determine if a file contains useful, functional assembly code.
    This is the core of our data cleaning process.
    """
    # Rule 1: Reject header/include files immediately
    if file_path.lower().endswith('.i'):
        return False

    lines = content.split('\n')
    
    # Rule 2: Must contain at least one instruction to return from a subroutine
    if 'rts' not in content.lower():
        return False
        
    # Rule 3: Count instructions vs. definitions
    instruction_count = 0
    definition_count = 0
    for line in lines:
        clean_line = line.strip().lower()
        if clean_line.startswith('xdef') or clean_line.startswith('xref'):
            definition_count += 1
        # A simple check for common instructions
        if any(instr in clean_line for instr in ['move', 'lea', 'jsr', 'add', 'sub', 'cmp', 'bra', 'bne', 'beq']):
            instruction_count += 1
            
    # Rule 4: If the file is mostly definitions, it's probably a header. Reject it.
    if definition_count > instruction_count and instruction_count < 5:
        return False
        
    return True


def _get_prompt_from_file(filename):
    """Retrieves the base prompt template from a file."""
    if os.path.exists(filename):
        with open(filename, 'r', encoding='utf-8') as f:
            return f.read().strip()
    raise FileNotFoundError(f"Prompt file '{filename}' not found.")

def _get_params_from_file(filename):
    """Retrieves fine-tuning parameters from a Key:value file."""
    params = {}
    if os.path.exists(filename):
        with open(filename, 'r', encoding='utf-8') as f:
            for line in f:
                if ':' in line and not line.strip().startswith('#'):
                    key, value = line.split(':', 1)
                    params[key.strip()] = value.strip()
        params['test_size'] = float(params['test_size'])
        params['seed'] = int(params['seed'])
        return params
    raise FileNotFoundError(f"Parameter file '{filename}' not found.")

def _get_keywords_from_file(filename):
    """Retrieves a list of keywords, ignoring comments."""
    keywords = []
    if os.path.exists(filename):
        with open(filename, 'r', encoding='utf-8') as f:
            for line in f:
                clean_line = line.strip()
                if clean_line and not clean_line.startswith(';'):
                    keywords.append(clean_line)
        return keywords
    raise FileNotFoundError(f"Keyword file '{filename}' not found.")

# --- Main Script ---
data = []
os.makedirs(source_dir, exist_ok=True)

try:
    base_prompt_text = _get_prompt_from_file(PROMPT_FILE)
    fine_tuning_params = _get_params_from_file(FINE_PARAMS_FILE)
    code_keywords = _get_keywords_from_file(KEYWORDS_FILE)
except (FileNotFoundError, ValueError) as e:
    print(f"{Fore.RED}Error: {e}{Style.RESET_ALL}")
    exit(1)

code_pattern = re.compile(r'\b(' + r'|'.join(code_keywords) + r')\b', re.IGNORECASE)

# --- Processing GitHub Repositories ---
print(f"{Fore.CYAN}--- Processing GitHub Repositories ---{Style.RESET_ALL}")
repos_to_scrape = []
if os.path.exists(REPOS_FILE):
    with open(REPOS_FILE, 'r', newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row.get('skip', '1').strip() == '0':
                repos_to_scrape.append({"url": row.get('repo', '').strip(), "patterns": ["**/*.asm", "**/*.s", "**/*.S"]})
            elif row.get('repo'):
                 print(f"{Fore.YELLOW}Skipping repository: {row['repo']}{Style.RESET_ALL}")

for repo in repos_to_scrape:
    repo_name = repo["url"].split("/")[-1].replace(".git", "")
    repo_path = os.path.join(source_dir, repo_name)
    if not os.path.exists(repo_path):
        print(f"Cloning {Fore.GREEN}{repo['url']}{Style.RESET_ALL}...")
        os.system(f"git clone {repo['url']} {repo_path}")
    else:
        print(f"Repository {Fore.GREEN}{repo_name}{Style.RESET_ALL} already exists.")

# This loop now filters the files before adding them to the dataset
for repo in repos_to_scrape:
    repo_name = repo["url"].split("/")[-1].replace(".git", "")
    repo_path = os.path.join(source_dir, repo_name)
    found_files = []
    for pattern in repo["patterns"]:
        found_files.extend(glob.glob(os.path.join(repo_path, pattern), recursive=True))
    
    print(f"Found {len(found_files)} files in {repo_name}. Filtering for quality...")
    filtered_count = 0
    for file_path in found_files:
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                code = f.read()
            if code.strip() and is_good_assembly_file(code, file_path):
                task_name = os.path.basename(file_path).split('.')[0]
                prompt = base_prompt_text.format(task_name=task_name)
                data.append({"prompt": prompt, "completion": code})
                filtered_count += 1
        except Exception as e:
            print(f"{Fore.RED}Could not read file {file_path}: {e}{Style.RESET_ALL}")
    print(f"Added {Fore.GREEN}{filtered_count}{Style.RESET_ALL} high-quality files from {repo_name}.")

# --- Processing Local Sources ---
print(f"{Fore.CYAN}\n--- Processing Local Sources from '{LOCAL_SOURCE_DIR}' Directory ---{Style.RESET_ALL}")
if os.path.isdir(LOCAL_SOURCE_DIR):
    local_patterns = ["**/*.asm", "**/*.s", "**/*.S"]
    local_files = []
    for pattern in local_patterns:
        local_files.extend(glob.glob(os.path.join(LOCAL_SOURCE_DIR, pattern), recursive=True))
    
    print(f"Found {len(local_files)} local files. Filtering for quality...")
    filtered_count = 0
    for file_path in local_files:
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                code = f.read()
            if code.strip() and is_good_assembly_file(code, file_path):
                task_name = os.path.basename(file_path).split('.')[0]
                prompt = base_prompt_text.format(task_name=task_name)
                data.append({"prompt": prompt, "completion": code})
                filtered_count += 1
        except Exception as e:
            print(f"{Fore.RED}Error reading file {file_path}: {e}{Style.RESET_ALL}")
    print(f"Added {Fore.GREEN}{filtered_count}{Style.RESET_ALL} high-quality local files.")
else:
    print(f"{Fore.YELLOW}Warning: Local source directory '{LOCAL_SOURCE_DIR}' not found.{Style.RESET_ALL}")

# --- Processing PDFs ---
# (Note: PDF extraction is less precise, so we keep the existing logic)
print(f"{Fore.CYAN}\n--- Processing PDFs from '{PDF_SOURCE_DIR}' Directory ---{Style.RESET_ALL}")
if os.path.isdir(PDF_SOURCE_DIR):
    pdf_files = glob.glob(os.path.join(PDF_SOURCE_DIR, "*.pdf"))
    print(f"Found {Fore.GREEN}{len(pdf_files)}{Style.RESET_ALL} PDF file(s) to process.")
    for pdf_path in pdf_files:
        pdf_snippets_found = 0
        try:
            pdf_doc = fitz.open(pdf_path)
            print(f"--> Processing '{Fore.GREEN}{os.path.basename(pdf_path)}{Style.RESET_ALL}' ({len(pdf_doc)} pages)...")
            for page_num, page in enumerate(pdf_doc):
                text = page.get_text()
                lines = text.split('\n')
                current_snippet, code_line_count = [], 0
                for line in lines:
                    if code_pattern.search(line):
                        current_snippet.append(line)
                        code_line_count += 1
                    else:
                        if len(current_snippet) > 3 and code_line_count > len(current_snippet) / 2:
                            code_block = "\n".join(current_snippet)
                            task_name = f"snippet from {os.path.basename(pdf_path)} page {page_num + 1}"
                            prompt = base_prompt_text.format(task_name=task_name)
                            data.append({"prompt": prompt, "completion": code_block})
                            pdf_snippets_found += 1
                        current_snippet, code_line_count = [], 0
            print(f"    Extracted {Fore.GREEN}{pdf_snippets_found}{Style.RESET_ALL} potential code snippets.")
        except Exception as e:
            print(f"{Fore.RED}    Error processing {pdf_path}: {e}{Style.RESET_ALL}")
else:
    print(f"{Fore.YELLOW}Warning: PDF directory '{PDF_SOURCE_DIR}' not found.{Style.RESET_ALL}")

# --- Create and save the final Hugging Face Dataset ---
if not data:
    print(f"{Fore.RED}Error: No data was collected! Check your sources and file paths.{Style.RESET_ALL}")
    exit(1)

print(f"\nCollected a total of {Fore.GREEN}{len(data)}{Style.RESET_ALL} code examples from all sources.")
ds = Dataset.from_list(data)
ds = ds.train_test_split(test_size=fine_tuning_params['test_size'], seed=fine_tuning_params['seed'])

print(f"Saving dataset to disk at '{Fore.GREEN}{output_dir}{Style.RESET_ALL}'")
ds.save_to_disk(output_dir)

print(f"\n{Fore.GREEN}Dataset preparation complete!{Style.RESET_ALL}")
print(f"Train examples: {Fore.GREEN}{len(ds['train'])}{Style.RESET_ALL}")
print(f"Test examples: {Fore.GREEN}{len(ds['test'])}{Style.RESET_ALL}")