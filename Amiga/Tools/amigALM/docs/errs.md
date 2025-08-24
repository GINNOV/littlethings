# Houston We Have A Problem

This error occurs because Gemma 3 is a **"gated" model**. This means you must agree to its license terms and log in to your Hugging Face account before you can download it. It's a simple permissions issue, not a problem with your code.

The fix involves two quick steps: accepting the terms on the website and then logging in from your terminal.

-----

### \#\# Step 1: Accept the Model's Terms on the Website 📝

You first need to visit the model's page on Hugging Face and accept its terms of use. This grants your account permission to download the model.

1.  **Go to the Gemma 3 model page:** [https://huggingface.co/google/gemma-3-270m-it](https://huggingface.co/google/gemma-3-270m-it)
2.  Make sure you are **logged into your Hugging Face account**.
3.  Read and **accept the license terms**. You will see a form or a checkbox to agree to the terms to gain access.

-----

### \#\# Step 2: Log In from Your Terminal 💻

Next, you need to log your machine into your Hugging Face account so your scripts can authenticate themselves when downloading.

1.  **Run the login command in your terminal:**

    ```bash
    huggingface-cli login
    ```

2.  **Provide an Access Token:** The command will prompt you to enter a Hugging Face access token.

      * You can get a token from your Hugging Face account settings here: [https://huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)
      * If you don't have one, create a new token with the "read" role.
      * Copy the token and paste it into the terminal when prompted.

-----

Once you've completed both steps, run your training script again. It will now be able to authenticate your account, verify your permissions, and download the model successfully.

```bash
uv run src/amiga_lm/train_model.py
```