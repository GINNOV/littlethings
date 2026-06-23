document.addEventListener('DOMContentLoaded', () => {
    // Select all copy-code buttons
    const buttons = document.querySelectorAll('.copy-code-button');
    buttons.forEach(button => {
        button.addEventListener('click', () => {
            // Find the pre/code block following the button
            const pre = button.nextElementSibling;
            if (pre && pre.tagName === 'PRE') {
                const code = pre.querySelector('code');
                const text = code ? code.innerText : pre.innerText;
                
                navigator.clipboard.writeText(text).then(() => {
                    const originalText = button.innerHTML;
                    button.innerHTML = '<i class="fas fa-check"></i> Copied!';
                    setTimeout(() => {
                        button.innerHTML = originalText;
                    }, 2000);
                }).catch(err => {
                    console.error('Failed to copy text: ', err);
                });
            }
        });
    });
});
