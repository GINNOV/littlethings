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
# UPDATED: All settings files are now located in the 'model_settings' directory
SETTINGS_DIR = "model_settings"
REPOS_FILE = os.path.join(SETTINGS_DIR, "repos.csv")
PROMPT_FILE = os.path.join(SETTINGS_DIR, "prompt1.txt")
FINE_PARAMS_FILE = os.path.join(SETTINGS_DIR, "fine_params.txt")
KEYWORDS_FILE = os.path.join(SETTINGS_DIR, "code_keywords.txt")

LOCAL_SOURCE_DIR = "sources"
PDF_SOURCE_DIR = "pdf_docs"
source_dir = "source_code"
output_dir = "amiga_asm_dataset"

# --- Helper Functions (unchanged) ---

def _get_prompt_from_file(filename):
    """Retrieves the base prompt template from a file."""
    if os.path.exists(filename):
        with open(filename, 'r', encoding='utf-8') as f:
            prompt_text = f.read().strip()
        if not prompt_text:
            raise ValueError(f"Prompt file '{filename}' is empty.")
        return prompt_text
    else:
        raise FileNotFoundError(f"Prompt file '{filename}' not found.")

def _get_params_from_file(filename):
    """Retrieves fine-tuning parameters from a Key:value file."""
    params = {}
    if os.path.exists(filename):
        with open(filename, 'r', encoding='utf-8') as f:
            for line in f:
                # ADDED: Check for comments and colons before splitting
                if ':' in line and not line.strip().startswith('#'):
                    key, value = line.split(':', 1)
                    params[key.strip()] = value.strip()
        if 'test_size' not in params or 'seed' not in params:
            raise ValueError(f"Required keys 'test_size' and 'seed' not found in '{filename}'.")
        
        params['test_size'] = float(params['test_size'])
        params['seed'] = int(params['seed'])
        return params
    else:
        raise FileNotFoundError(f"Parameter file '{filename}' not found.")

def _get_keywords_from_file(filename):
    """Retrieves a list of keywords from a file, one per line, ignoring comments."""
    keywords = []
    if os.path.exists(filename):
        with open(filename, 'r', encoding='utf-8') as f:
            for line in f:
                clean_line = line.strip()
                if clean_line and not clean_line.startswith(';'):
                    keywords.append(clean_line)
        if not keywords:
            raise ValueError(f"Keyword file '{filename}' is empty or contains only comments.")
        return keywords
    else:
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
    print(f"Reading repository URLs from '{REPOS_FILE}'...")
    with open(REPOS_FILE, 'r', newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row.get('skip', '1').strip() == '0':
                url = row.get('repo', '').strip()
                if url:
                    repos_to_scrape.append({
                        "url": url,
                        "patterns": ["**/*.asm", "**/*.s", "**/*.S"]
                    })
            elif row.get('repo'):
                 print(f"{Fore.YELLOW}Skipping repository: {row['repo']}{Style.RESET_ALL}")

    if not repos_to_scrape:
        print(f"{Fore.YELLOW}Warning: No repositories to process from '{REPOS_FILE}'.{Style.RESET_ALL}")
else:
    print(f"{Fore.YELLOW}Warning: '{REPOS_FILE}' not found. Skipping GitHub processing.{Style.RESET_ALL}")

for repo in repos_to_scrape:
    repo_name = repo["url"].split("/")[-1].replace(".git", "")
    repo_path = os.path.join(source_dir, repo_name)
    if not os.path.exists(repo_path):
        print(f"Cloning {Fore.GREEN}{repo['url']}{Style.RESET_ALL}...")
        os.system(f"git clone {repo['url']} {repo_path}")
    else:
        print(f"Repository {Fore.GREEN}{repo_name}{Style.RESET_ALL} already exists. Skipping clone.")

for repo in repos_to_scrape:
    repo_name = repo["url"].split("/")[-1].replace(".git", "")
    repo_path = os.path.join(source_dir, repo_name)
    found_files = []
    for pattern in repo["patterns"]:
        search_path = os.path.join(repo_path, pattern)
        found_files.extend(glob.glob(search_path, recursive=True))
    print(f"Found {Fore.GREEN}{len(found_files)}{Style.RESET_ALL} source files in {Fore.GREEN}{repo_name}{Style.RESET_ALL}")
    for file_path in found_files:
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                code = f.read()
            task_name = os.path.basename(file_path).split('.')[0]
            prompt = base_prompt_text.format(task_name=task_name)
            if code.strip():
                data.append({"prompt": prompt, "completion": code})
        except Exception as e:
            print(f"{Fore.RED}Could not read file {file_path}: {e}{Style.RESET_ALL}")

# --- Processing Local Sources ---
print(f"{Fore.CYAN}\n--- Processing Local Sources from '{LOCAL_SOURCE_DIR}' Directory ---{Style.RESET_ALL}")
if os.path.isdir(LOCAL_SOURCE_DIR):
    local_patterns = ["**/*.asm", "**/*.s", "**/*.S"]
    local_files = []
    for pattern in local_patterns:
        local_files.extend(glob.glob(os.path.join(LOCAL_SOURCE_DIR, pattern), recursive=True))
    print(f"Found {Fore.GREEN}{len(local_files)}{Style.RESET_ALL} local source files.")
    for file_path in local_files:
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                code = f.read()
            task_name = os.path.basename(file_path).split('.')[0]
            prompt = base_prompt_text.format(task_name=task_name)
            if code.strip():
                data.append({"prompt": prompt, "completion": code})
        except Exception as e:
            print(f"{Fore.RED}Error reading file {file_path}: {e}{Style.RESET_ALL}")
else:
    print(f"{Fore.YELLOW}Warning: Local source directory '{LOCAL_SOURCE_DIR}' not found. Skipping local processing.{Style.RESET_ALL}")

# --- Processing PDFs ---
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
                            prompt = base_prompt_text.format(task_name=f"document page {page_num + 1}")
                            if "prompt" in locals() and "completion" in locals():
                                data.append({"prompt": prompt, "completion": code_block})
                            pdf_snippets_found += 1
                        current_snippet, code_line_count = [], 0
            print(f"    Extracted {Fore.GREEN}{pdf_snippets_found}{Style.RESET_ALL} potential code snippets.")
        except Exception as e:
            print(f"{Fore.RED}    Error processing {pdf_path}: {e}{Style.RESET_ALL}")
else:
    print(f"{Fore.YELLOW}Warning: PDF directory '{PDF_SOURCE_DIR}' not found. Skipping PDF processing.{Style.RESET_ALL}")

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