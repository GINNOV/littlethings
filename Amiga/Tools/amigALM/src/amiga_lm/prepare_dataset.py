import os
import glob
from datasets import Dataset

# --- Configuration: List of repos with Amiga 68k assembly code ---
# Each entry: { url: "repo_url", path: "glob_pattern_to_asm_files" }
REPOS_TO_SCRAPE = [
    {
        "url": "https://github.com/Ziagl/Amiga-Assembler",
        "path": "Amiga-Assembler/src/*.asm"
    },
    {
        "url": "https://github.com/stefanocoppi/amiga_game_prog",
        "path": "amiga_game_prog/src/*.S" # Note the .S extension
    },
    {
        "url": "https://github.com/alpine9000/amiga_examples",
        "path": "amiga_examples/**/*.s" # Recursive search for .s files
    },
    {
        "url": "https://github.com/MagerValp/Arcade-Amiga",
        "path": "Arcade-Amiga/src/**/*.s"
    }
]

# --- Main Script ---
data = []
output_dir = "amiga_asm_dataset"
os.makedirs("source_code", exist_ok=True)
os.chdir("source_code")

# 1. Clone all repositories
for repo in REPOS_TO_SCRAPE:
    repo_name = repo["url"].split("/")[-1]
    if not os.path.exists(repo_name):
        print(f"Cloning {repo['url']}...")
        os.system(f"git clone {repo['url']}")
    else:
        print(f"Repository {repo_name} already exists. Skipping clone.")

# 2. Process assembly files and format them
for repo in REPOS_TO_SCRAPE:
    # Use glob to find all matching files
    files = glob.glob(repo["path"], recursive=True)
    print(f"Found {len(files)} files in {repo['url'].split('/')[-1]}")
    
    for file_path in files:
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                code = f.read()
            
            # Create a simple but effective prompt
            filename = os.path.basename(file_path)
            prompt = f"Generate a complete Amiga assembly program for the task '{filename.split('.')[0]}'."

            # Append to our data list
            if code.strip(): # Ensure the file is not empty
                data.append({"prompt": prompt, "completion": code})
        except Exception as e:
            print(f"Could not read file {file_path}: {e}")

os.chdir("..") # Return to the root directory

# 3. Create and save the Hugging Face Dataset
if not data:
    raise ValueError("No data was collected! Check repository paths and file patterns.")

print(f"\nCollected a total of {len(data)} code examples.")
ds = Dataset.from_list(data)
ds = ds.train_test_split(test_size=0.1, seed=42)

print(f"Saving dataset to disk at '{output_dir}'")
ds.save_to_disk(output_dir)

print("\nDataset preparation complete!")
print(f"Train examples: {len(ds['train'])}")
print(f"Test examples: {len(ds['test'])}")