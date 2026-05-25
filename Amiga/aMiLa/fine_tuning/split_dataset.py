import os
import json
import random
import subprocess
import tempfile

from curated_asm_regressions import CURATED_ASM_REGRESSIONS

dataset_asm_path = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/dataset_asm.jsonl"
dataset_c_path = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/dataset_c.jsonl"

data_asm_dir = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/data_asm"
data_c_dir = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/data_c"
vasm_path = "/usr/local/bin/vasmm68k_mot"
ndk_include = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/Dataset/corpus3/amiga-dev/targets/m68k-amigaos/ndk/include_i"
curated_asm_train_weight = 20
max_assistant_chars = 3500

os.makedirs(data_asm_dir, exist_ok=True)
os.makedirs(data_c_dir, exist_ok=True)

def assistant_content(record):
    return record["messages"][-1]["content"]

def user_prompt(record):
    for message in record["messages"]:
        if message.get("role") == "user":
            return message.get("content", "")
    return ""

def is_reference_request(prompt):
    lower = prompt.lower()
    return any(token in lower for token in ["register-list", "register list", "constants", "equates", "reference"])

def is_allowed_non_executable(prompt):
    lower = prompt.lower()
    return is_reference_request(prompt) or "bootblock" in lower or "subroutine" in lower or "routine" in lower

def is_runnable_asm_record(record):
    source = assistant_content(record)
    prompt = user_prompt(record)
    upper_source = source.upper()
    if len(source) > max_assistant_chars:
        return False
    if is_allowed_non_executable(prompt):
        return True
    return "SECTION" in upper_source and "XDEF" in upper_source and "_START" in upper_source

def verify_asm_record(record):
    if not os.path.exists(vasm_path):
        raise RuntimeError(f"vasm compiler not found at {vasm_path}")

    source = assistant_content(record)
    with tempfile.NamedTemporaryFile(suffix=".s", delete=False) as source_file:
        source_file.write(source.encode("utf-8"))
        source_path = source_file.name
    output_path = source_path + ".bin"

    try:
        result = subprocess.run(
            [
                vasm_path,
                "-kick1hunks",
                "-Fhunkexe",
                f"-I{ndk_include}",
                "-o",
                output_path,
                "-nosym",
                source_path,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=5,
        )
        if result.returncode != 0:
            raise RuntimeError(
                "Curated ASM regression failed VASM validation:\n"
                f"{source}\n\n{result.stdout}\n{result.stderr}"
            )
    finally:
        if os.path.exists(source_path):
            os.remove(source_path)
        if os.path.exists(output_path):
            os.remove(output_path)

def dedupe_records(records):
    deduped = []
    seen = set()
    for record in records:
        key = json.dumps(record["messages"], sort_keys=True)
        if key not in seen:
            seen.add(key)
            deduped.append(record)
    return deduped

def split_file(input_path, output_dir, label, extra_records=None):
    if not os.path.exists(input_path):
        print(f"Skipping {label} split: {input_path} not found.")
        return
        
    with open(input_path, "r", encoding="utf-8") as f:
        records = [json.loads(line) for line in f if line.strip()]

    records = dedupe_records(records)
    if label == "Assembly":
        before_filter_count = len(records)
        records = [record for record in records if is_runnable_asm_record(record)]
        print(f"[{label}] Removed {before_filter_count - len(records)} fragment/reference/long records before split.")

    # Shuffle records
    random.seed(42)
    random.shuffle(records)

    # 90% train, 10% valid
    split_idx = int(len(records) * 0.9)
    train_records = records[:split_idx]
    valid_records = records[split_idx:]

    extra_records = extra_records or []
    if label == "Assembly":
        for record in extra_records:
            verify_asm_record(record)
        weighted_extra_records = extra_records * curated_asm_train_weight
        train_records.extend(weighted_extra_records)
        print(
            f"[{label}] Added {len(weighted_extra_records)} weighted curated regression records "
            f"to train ({len(extra_records)} unique x{curated_asm_train_weight})."
        )

    train_path = os.path.join(output_dir, "train.jsonl")
    valid_path = os.path.join(output_dir, "valid.jsonl")

    with open(train_path, "w", encoding="utf-8") as f:
        for rec in train_records:
            f.write(json.dumps(rec) + "\n")

    with open(valid_path, "w", encoding="utf-8") as f:
        for rec in valid_records:
            f.write(json.dumps(rec) + "\n")

    print(f"\n[{label}] Split completed! Total records: {len(records)}")
    print(f"- Train records saved: {len(train_records)} -> {train_path}")
    print(f"- Valid records saved: {len(valid_records)} -> {valid_path}")

split_file(dataset_asm_path, data_asm_dir, "Assembly", extra_records=CURATED_ASM_REGRESSIONS)
split_file(dataset_c_path, data_c_dir, "C")
