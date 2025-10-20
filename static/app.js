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
document.getElementById('useStart').addEventListener('click', () => {
  if (!navigator.geolocation) return alert('Geolocation not supported');
  navigator.geolocation.getCurrentPosition(p => {
    document.getElementById('startLat').value = p.coords.latitude;
    document.getElementById('startLon').value = p.coords.longitude;
  }, e => alert('Geolocation error: ' + e.message));
});

document.getElementById('useEnd').addEventListener('click', () => {
  if (!navigator.geolocation) return alert('Geolocation not supported');
  navigator.geolocation.getCurrentPosition(p => {
    document.getElementById('endLat').value = p.coords.latitude;
    document.getElementById('endLon').value = p.coords.longitude;
  }, e => alert('Geolocation error: ' + e.message));
});

document.getElementById('find').addEventListener('click', async () => {
  const sLat = parseFloat(document.getElementById('startLat').value);
  const sLon = parseFloat(document.getElementById('startLon').value);
  const eLat = parseFloat(document.getElementById('endLat').value);
  const eLon = parseFloat(document.getElementById('endLon').value);
  if (![sLat, sLon, eLat, eLon].every(v => Number.isFinite(v))) return alert('Please provide numeric lat/lon for start and end');

  const body = { start: { lat: sLat, lon: sLon }, end: { lat: eLat, lon: eLon } };
  const resElem = document.getElementById('result');
  resElem.textContent = 'Finding route...';

  try {
    const r = await fetch('/api/get_route', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
    const data = await r.json();
    if (data.error) {
      resElem.textContent = 'Error: ' + data.error; return;
    }
    if (!data.route || data.route.length === 0) {
      resElem.innerHTML = `<p>No route found. Nearest stations: <strong>${data.start_station}</strong> -> <strong>${data.end_station}</strong></p>`;
      return;
    }
    let html = `<p>Nearest stations: <strong>${data.start_station}</strong> -> <strong>${data.end_station}</strong></p>`;
    html += '<ol>' + data.route.map(s => `<li>${s}</li>`).join('') + '</ol>';
    resElem.innerHTML = html;
  } catch (err) {
    resElem.textContent = 'Request failed: ' + err.message;
  }
});
