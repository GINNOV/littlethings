import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline

# --- Configuration ---
# Use the path where your final model was saved
model_path = "./amiga_codegemma_finetuned/final_checkpoint"

# --- Load Model and Tokenizer ---
print("Loading fine-tuned model...")
model = AutoModelForCausalLM.from_pretrained(
    model_path,
    device_map="auto",
    torch_dtype=torch.float16, # Use float16 for faster inference
)
tokenizer = AutoTokenizer.from_pretrained(model_path)

# --- Create Inference Pipeline ---
pipe = pipeline("text-generation", model=model, tokenizer=tokenizer)

# --- Test Prompts ---
prompts = [
    "Generate a complete Amiga assembly program for the task 'WaitForVBlank'.",
    "Generate a complete Amiga assembly program for the task 'clear_screen_blitter'.",
    "Generate a complete Amiga assembly program for the task 'read_joystick_port_2'."
]

# --- Generate and Print Outputs ---
for prompt in prompts:
    print("-" * 50)
    print(f"### PROMPT:\n{prompt}")
    print("\n### GENERATED CODE:")
    
    # We only want the model to generate the code part.
    # The prompt format helps guide it.
    formatted_prompt = f"### Prompt:\n{prompt}\n\n### Code:\n"
    
    result = pipe(
        formatted_prompt,
        max_new_tokens=256,
        do_sample=True,
        temperature=0.7,
        top_p=0.9,
        repetition_penalty=1.1,
    )
    
    # Extract just the generated text
    generated_text = result[0]['generated_text']
    # Clean up the output to only show the new code
    code_part = generated_text.split("### Code:\n")[-1]

    print(code_part)
    print("-" * 50)