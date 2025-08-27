Yes, you can build a program to analyze your dataset. It's a great way to understand what knowledge you've provided to the model and to predict how it should respond to certain prompts.

This type of script is a crucial part of the machine learning workflow, as it helps you identify gaps in your training data and understand the model's "knowledge base."

I've created a new script, `analyze_dataset.py`, that allows you to search your dataset for specific keywords. This will show you exactly which examples in your training data are relevant to a given prompt, giving you a clear idea of what the model *should* be able to answer.

-----

### \#\# 1. run `analyze_dataset.py` script


### \#\# 2. How to Use the Script

You can now run this script from your project's root directory to search your dataset.

**Example Usage:**

To find all examples related to the **Copper**, run:

```bash
uv run python src/amiga_lm/analyze_dataset.py "copper"
```

To find all examples related to the **Blitter**, run:

```bash
uv run python src/amiga_lm/analyze_dataset.py "blitter"
```

The script will print all the matching prompts and code completions from your dataset, giving you a clear picture of what the model has learned and what it should be able to generate.