import os
import glob
import re
import fitz  # PyMuPDF
from datasets import Dataset

# --- Configuration: Your verified list of sources ---
REPOS_TO_SCRAPE = [
    {
        "url": "https://github.com/Ziagl/Amiga-Assembler",
        "patterns": ["**/*.asm", "**/*.s"]
    },
    {
        "url": "https://github.com/stefanocoppi/amiga_game_prog",
        "patterns": ["**/*.asm", "**/*.s", "**/*.S"]
    },
    {
        "url": "https://github.com/alpine9000/amiga_examples",
        "patterns": ["**/*.asm", "**/*.s"]
    },
    {
        "url": "https://github.com/pararaum/amigaexamples",
        "patterns": ["**/*.asm", "**/*.s"]
    }
]
# CORRECTED: Point to the new directory for PDFs
PDF_SOURCE_DIR = "pdf_docs"

# --- Main Script ---
data = []
source_dir = "source_code"
output_dir = "amiga_asm_dataset"
os.makedirs(source_dir, exist_ok=True)

print("--- Processing GitHub Repositories ---")
# 1. Clone all repositories
for repo in REPOS_TO_SCRAPE:
    repo_name = repo["url"].split("/")[-1]
    repo_path = os.path.join(source_dir, repo_name)
    if not os.path.exists(repo_path):
        print(f"Cloning {repo['url']}...")
        os.system(f"git clone {repo['url']} {repo_path}")
    else:
        print(f"Repository {repo_name} already exists. Skipping clone.")

# 2. Process assembly files from repos
for repo in REPOS_TO_SCRAPE:
    repo_name = repo["url"].split("/")[-1]
    repo_path = os.path.join(source_dir, repo_name)
    
    found_files = []
    for pattern in repo["patterns"]:
        search_path = os.path.join(repo_path, pattern)
        found_files.extend(glob.glob(search_path, recursive=True))
    
    print(f"Found {len(found_files)} source files in {repo_name}")
    
    for file_path in found_files:
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                code = f.read()
            
            filename = os.path.basename(file_path)
            prompt = f"Generate Amiga assembly code for the task '{filename.split('.')[0]}'."

            if code.strip():
                data.append({"prompt": prompt, "completion": code})
        except Exception as e:
            print(f"Could not read file {file_path}: {e}")

print(f"\n--- Processing PDFs from '{PDF_SOURCE_DIR}' Directory ---")
# 3. Process all PDF files in the specified directory
if os.path.isdir(PDF_SOURCE_DIR):
    pdf_files = glob.glob(os.path.join(PDF_SOURCE_DIR, "*.pdf"))
    print(f"Found {len(pdf_files)} PDF file(s) to process.")
    
    code_keywords = ['move', 'lea', 'jsr', 'rts', 'add', 'sub', 'cmp', 'bra', 'bne', 'beq', 'dc.w', 'ds.b', 'clr']
    code_pattern = re.compile(r'\b(' + r'|'.join(code_keywords) + r')\b', re.IGNORECASE)
    
    for pdf_path in pdf_files:
        pdf_snippets_found = 0
        try:
            pdf_doc = fitz.open(pdf_path)
            print(f"--> Processing '{os.path.basename(pdf_path)}' ({len(pdf_doc)} pages)...")
            
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
                            prompt = f"Generate Amiga assembly code for the following task described in '{os.path.basename(pdf_path)}' (page {page_num + 1})."
                            data.append({"prompt": prompt, "completion": code_block})
                            pdf_snippets_found += 1
                        current_snippet, code_line_count = [], 0
            
            print(f"    Extracted {pdf_snippets_found} potential code snippets.")
        except Exception as e:
            print(f"    Error processing {pdf_path}: {e}")
else:
    print(f"Warning: PDF directory '{PDF_SOURCE_DIR}' not found. Skipping PDF processing.")

# 4. Create and save the final Hugging Face Dataset
if not data:
    raise ValueError("No data was collected! Check your sources and file paths.")

print(f"\nCollected a total of {len(data)} code examples from all sources.")
ds = Dataset.from_list(data)
ds = ds.train_test_split(test_size=0.1, seed=42)

print(f"Saving dataset to disk at '{output_dir}'")
ds.save_to_disk(output_dir)

print("\nDataset preparation complete!")
print(f"Train examples: {len(ds['train'])}")
print(f"Test examples: {len(ds['test'])}")