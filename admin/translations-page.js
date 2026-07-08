class TranslationEditorPage {
  #dataStore;
  #containerElement;
  #isRendered = false;
  #selectedLanguageCode = '';
  #currentFilterText = '';
  #currentFilterPartOfSpeech = '';
  #controlsRowElement = null;
  #tableWrapperElement = null;
  #currentTbodyElement = null;
  #termRowsByTermId = new Map();

  constructor(containerElement, dataStore) {
    this.#containerElement = containerElement;
    this.#dataStore = dataStore;
  }

  render() {
    if (this.#isRendered) return;
    const codes = this.#dataStore.availableLanguageCodes;
    if (!this.#selectedLanguageCode && codes.length > 0) {
      this.#selectedLanguageCode = codes.includes('en') ? 'en' : codes[0];
    }
    this.#buildPageContent();
    this.#isRendered = true;
  }

  #buildPageContent() {
    this.#containerElement.innerHTML = '';

    this.#controlsRowElement = this.#buildControlsRow();
    this.#containerElement.appendChild(this.#controlsRowElement);

    this.#tableWrapperElement = this.#buildTableWrapper();
    this.#currentTbodyElement = this.#buildTableBody();
    this.#tableWrapperElement.querySelector('table').appendChild(this.#currentTbodyElement);
    this.#containerElement.appendChild(this.#tableWrapperElement);
  }

  #buildControlsRow() {
    const row = document.createElement('div');
    row.className = 'controls-row';

    const langSelect = document.createElement('select');
    langSelect.className = 'lang-select';
    for (const code of this.#dataStore.availableLanguageCodes) {
      const opt = document.createElement('option');
      opt.value = code;
      opt.textContent = code.toUpperCase();
      if (code === this.#selectedLanguageCode) opt.selected = true;
      langSelect.appendChild(opt);
    }
    langSelect.addEventListener('change', (e) => {
      this.#switchToLanguage(e.target.value);
    });

    const posSelect = document.createElement('select');
    posSelect.className = 'pos-select';
    const allOption = document.createElement('option');
    allOption.value = '';
    allOption.textContent = 'All POS';
    posSelect.appendChild(allOption);
    for (const pos of this.#collectPartOfSpeechTypes()) {
      const opt = document.createElement('option');
      opt.value = pos;
      opt.textContent = pos;
      posSelect.appendChild(opt);
    }
    posSelect.addEventListener('change', (e) => {
      this.#currentFilterPartOfSpeech = e.target.value;
      this.#applyRowFilter();
    });

    const searchInput = document.createElement('input');
    searchInput.type = 'text';
    searchInput.className = 'search-input';
    searchInput.placeholder = 'Search by ID or text...';
    searchInput.addEventListener('input', (e) => {
      this.#currentFilterText = e.target.value.toLowerCase();
      this.#applyRowFilter();
    });

    row.appendChild(langSelect);
    row.appendChild(posSelect);
    row.appendChild(searchInput);
    return row;
  }

  #buildTableWrapper() {
    const wrapper = document.createElement('div');
    wrapper.className = 'translation-table-wrapper';

    const table = document.createElement('table');
    table.className = 'translation-table';

    const thead = document.createElement('thead');
    const headerRow = document.createElement('tr');

    const headers = [
      { text: 'ID', className: 'col-id' },
      { text: 'POS', className: 'col-pos' },
      { text: 'Text', className: 'col-text' },
      { text: 'Note', className: 'col-note' },
      { text: 'Grammar', className: 'col-grammar' },
    ];

    for (const h of headers) {
      const th = document.createElement('th');
      th.className = h.className;
      th.textContent = h.text;
      headerRow.appendChild(th);
    }

    thead.appendChild(headerRow);
    table.appendChild(thead);
    wrapper.appendChild(table);
    return wrapper;
  }

  #buildTableBody() {
    this.#termRowsByTermId.clear();
    const tbody = document.createElement('tbody');
    const terms = this.#dataStore.dictionaryTerms;
    const entries = this.#dataStore.getTranslationEntries(this.#selectedLanguageCode);
    const sortedTermIds = Object.keys(terms).sort();

    for (const termId of sortedTermIds) {
      const termDef = terms[termId];
      const entry = entries[termId] || {};
      const row = this.#buildTermTableRow(termId, termDef, entry);
      this.#termRowsByTermId.set(termId, row);
      tbody.appendChild(row);
    }

    return tbody;
  }

  #buildTermTableRow(termId, termDef, entry) {
    const row = document.createElement('tr');
    const shape = this.#detectEntryShape(entry);

    if (shape === 'empty') row.classList.add('missing-entry');

    const idCell = document.createElement('td');
    idCell.className = 'col-id';
    idCell.textContent = termId;

    const posCell = document.createElement('td');
    posCell.className = 'col-pos';
    posCell.textContent = termDef.pos;

    const textCell = document.createElement('td');
    textCell.className = 'col-text';

    if (shape === 'simple' || shape === 'empty') {
      const input = document.createElement('input');
      input.type = 'text';
      input.className = 'cell-input';
      input.value = entry.text || '';
      if (shape === 'empty') input.placeholder = 'missing';
      input.addEventListener('input', (e) => {
        this.#dataStore.updateTranslationText(
          this.#selectedLanguageCode, termId, e.target.value
        );
        window.dispatchEvent(new CustomEvent('dirty-change'));
      });
      textCell.appendChild(input);
    } else {
      const label = document.createElement('span');
      label.className = 'readonly-shape';
      label.textContent = this.#formatReadonlyShapeLabel(shape);
      textCell.appendChild(label);
    }

    const noteCell = document.createElement('td');
    noteCell.className = 'col-note';
    const noteInput = document.createElement('input');
    noteInput.type = 'text';
    noteInput.className = 'cell-input';
    noteInput.value = entry.note || '';
    noteInput.addEventListener('input', (e) => {
      this.#dataStore.updateTranslationNote(
        this.#selectedLanguageCode, termId, e.target.value
      );
      window.dispatchEvent(new CustomEvent('dirty-change'));
    });
    noteCell.appendChild(noteInput);

    const grammarCell = document.createElement('td');
    grammarCell.className = 'col-grammar';
    const grammarText = this.#formatGrammarFieldsDisplay(entry, shape);
    if (grammarText) {
      const grammarSpan = document.createElement('span');
      grammarSpan.className = 'grammar-info';
      grammarSpan.textContent = grammarText;
      grammarCell.appendChild(grammarSpan);
    }

    row.appendChild(idCell);
    row.appendChild(posCell);
    row.appendChild(textCell);
    row.appendChild(noteCell);
    row.appendChild(grammarCell);
    return row;
  }

  #applyRowFilter() {
    const entries = this.#dataStore.getTranslationEntries(this.#selectedLanguageCode);
    const terms = this.#dataStore.dictionaryTerms;

    for (const [termId, row] of this.#termRowsByTermId) {
      const termDef = terms[termId];
      const matchesPos = !this.#currentFilterPartOfSpeech ||
        termDef.pos === this.#currentFilterPartOfSpeech;

      let matchesText = true;
      if (this.#currentFilterText) {
        const entry = entries[termId] || {};
        const textVal = entry.text || '';
        matchesText = termId.includes(this.#currentFilterText) ||
          textVal.toLowerCase().includes(this.#currentFilterText);
      }

      row.hidden = !(matchesPos && matchesText);
    }
  }

  #switchToLanguage(languageCode) {
    this.#selectedLanguageCode = languageCode;
    if (this.#currentTbodyElement) this.#currentTbodyElement.remove();
    this.#currentTbodyElement = this.#buildTableBody();
    this.#tableWrapperElement.querySelector('table').appendChild(this.#currentTbodyElement);
    this.#applyRowFilter();
  }

  #detectEntryShape(entry) {
    if (Object.keys(entry).length === 0) return 'empty';
    if (entry.imperfective || entry.perfective) return 'aspect-pair';
    if (entry.m || entry.f) return 'adjective';
    return 'simple';
  }

  #formatReadonlyShapeLabel(shape) {
    if (shape === 'aspect-pair') return 'aspect pair';
    if (shape === 'adjective') return 'adjective forms';
    return shape;
  }

  #formatGrammarFieldsDisplay(entry, shape) {
    const parts = [];
    if (shape === 'aspect-pair') {
      if (entry.imperfective) parts.push('imp: ' + entry.imperfective);
      if (entry.perfective) parts.push('pf: ' + entry.perfective);
    } else if (shape === 'adjective') {
      if (entry.m) parts.push('m: ' + entry.m);
      if (entry.f) parts.push('f: ' + entry.f);
      if (entry.n) parts.push('n: ' + entry.n);
    } else {
      if (entry.gender) parts.push(entry.gender);
      if (entry.article) parts.push(entry.article);
      if (entry.aspect) parts.push(entry.aspect);
    }
    return parts.join(' · ');
  }

  #collectPartOfSpeechTypes() {
    const types = new Set();
    const terms = this.#dataStore.dictionaryTerms;
    for (const termDef of Object.values(terms)) {
      types.add(termDef.pos);
    }
    return Array.from(types).sort();
  }
}
