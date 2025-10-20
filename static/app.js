document.addEventListener('DOMContentLoaded', () => {
  const sentenceEl = document.getElementById('sentence');
  const outputEl = document.getElementById('output');
  const convertBtn = document.getElementById('convert');
  const examplesBtn = document.getElementById('examples');

  async function convertSentence(text) {
    outputEl.textContent = 'Converting...';
    try {
      const res = await fetch('/api/convert', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sentence: text })
      });
      const data = await res.json();
      if (data.success) {
        outputEl.textContent = `Tokens: ${JSON.stringify(data.tokens)}\n\nLogic: ${data.logic}`;
      } else {
        outputEl.textContent = `Error: ${data.error}`;
      }
    } catch (err) {
      outputEl.textContent = 'Request failed: ' + err.message;
    }
  }

  convertBtn.addEventListener('click', () => {
    const txt = sentenceEl.value.trim();
    if (!txt) return alert('Please enter a sentence');
    convertSentence(txt);
  });

  examplesBtn.addEventListener('click', async () => {
    const examples = [
      'every student reads a book',
      'all humans have a brain',
      'some birds build a nest',
      'a person likes a dog',
      'each programmer writes a code'
    ];
    for (const e of examples) {
      sentenceEl.value = e;
      await convertSentence(e);
      await new Promise(r => setTimeout(r, 600));
    }
  });
});
