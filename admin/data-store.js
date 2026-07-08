class LanguageDataStore {
  #directoryHandle = null;
  #dictionaryData = null;
  #levelsData = null;
  #translationsByLanguage = {};
  #translationMetaByLanguage = {};
  #deckLookupMap = null;
  #termDeckMembershipIndex = null;
  #modifiedFileKeys = new Set();

  async selectDirectory() {
    this.#directoryHandle = await window.showDirectoryPicker({ mode: 'readwrite' });
    await this.#saveHandleToDatabase(this.#directoryHandle);
  }

  async restoreDirectory() {
    const handle = await this.#loadHandleFromDatabase();
    if (!handle) return false;
    const permission = await handle.requestPermission({ mode: 'readwrite' });
    if (permission !== 'granted') return false;
    this.#directoryHandle = handle;
    return true;
  }

  async hasSavedDirectory() {
    const handle = await this.#loadHandleFromDatabase();
    return handle !== null;
  }

  async loadAllDataFiles() {
    this.#dictionaryData = await this.#readJsonFromHandle(this.#directoryHandle, 'dictionary.json');
    this.#levelsData = await this.#readJsonFromHandle(this.#directoryHandle, 'levels.json');

    const translationsDir = await this.#directoryHandle.getDirectoryHandle('translations');
    for await (const entry of translationsDir.values()) {
      if (entry.kind !== 'file' || !entry.name.endsWith('.json')) continue;
      const langCode = entry.name.replace('.json', '');
      const data = await this.#readJsonFromHandle(translationsDir, entry.name);
      if (data.meta) {
        this.#translationMetaByLanguage[langCode] = data.meta;
        delete data.meta;
      }
      this.#translationsByLanguage[langCode] = data;
    }

    this.#buildDeckLookupMap();
    this.#buildTermDeckMembershipIndex();
    this.#modifiedFileKeys.clear();
  }

  async saveModifiedFiles() {
    if (this.#modifiedFileKeys.has('levels')) {
      await this.#writeJsonToHandle(this.#directoryHandle, 'levels.json', this.#levelsData);
      this.#modifiedFileKeys.delete('levels');
    }

    const translationsDir = await this.#directoryHandle.getDirectoryHandle('translations');
    for (const langCode of this.availableLanguageCodes) {
      const key = 'translation:' + langCode;
      if (!this.#modifiedFileKeys.has(key)) continue;

      const merged = {};
      const entries = Object.entries(this.#translationsByLanguage[langCode]);
      if (this.#translationMetaByLanguage[langCode]) {
        entries.push(['meta', this.#translationMetaByLanguage[langCode]]);
      }
      entries.sort((a, b) => a[0].localeCompare(b[0]));
      for (const [k, v] of entries) {
        merged[k] = v;
      }

      await this.#writeJsonToHandle(translationsDir, langCode + '.json', merged);
      this.#modifiedFileKeys.delete(key);
    }
  }

  get dictionaryTerms() {
    return this.#dictionaryData.terms;
  }

  get levelDefinitions() {
    return this.#levelsData.levels;
  }

  get availableLanguageCodes() {
    return Object.keys(this.#translationsByLanguage).sort();
  }

  get displayNames() {
    const meta = this.#translationMetaByLanguage.en || {};
    return { levels: meta.levels || {}, decks: meta.decks || {} };
  }

  get hasUnsavedChanges() {
    return this.#modifiedFileKeys.size > 0;
  }

  getDeckDefinition(deckId) {
    return this.#deckLookupMap.get(deckId);
  }

  getDeckIdsForTerm(termId) {
    return this.#termDeckMembershipIndex.get(termId) || new Set();
  }

  getUnassignedTermIds() {
    return Object.keys(this.#dictionaryData.terms).filter(
      id => !this.#termDeckMembershipIndex.has(id) || this.#termDeckMembershipIndex.get(id).size === 0
    );
  }

  getTranslationEntries(languageCode) {
    return this.#translationsByLanguage[languageCode] || {};
  }

  moveTermBetweenDecks(termId, sourceDeckId, targetDeckId, targetIndex = null) {
    if (sourceDeckId === targetDeckId) return;

    if (sourceDeckId) {
      const sourceDeck = this.#deckLookupMap.get(sourceDeckId);
      const index = sourceDeck.terms.indexOf(termId);
      if (index !== -1) sourceDeck.terms.splice(index, 1);
      const membershipSet = this.#termDeckMembershipIndex.get(termId);
      if (membershipSet) membershipSet.delete(sourceDeckId);
    }

    if (targetDeckId) {
      const targetDeck = this.#deckLookupMap.get(targetDeckId);
      if (!targetDeck.terms.includes(termId)) {
        if (targetIndex !== null && targetIndex < targetDeck.terms.length) {
          targetDeck.terms.splice(targetIndex, 0, termId);
        } else {
          targetDeck.terms.push(termId);
        }
      }
      if (!this.#termDeckMembershipIndex.has(termId)) {
        this.#termDeckMembershipIndex.set(termId, new Set());
      }
      this.#termDeckMembershipIndex.get(termId).add(targetDeckId);
    }

    this.#modifiedFileKeys.add('levels');
  }

  reorderTermWithinDeck(deckId, termId, newIndex) {
    const deck = this.#deckLookupMap.get(deckId);
    if (!deck) return;
    const currentIndex = deck.terms.indexOf(termId);
    if (currentIndex === -1) return;
    deck.terms.splice(currentIndex, 1);
    deck.terms.splice(newIndex, 0, termId);
    this.#modifiedFileKeys.add('levels');
  }

  updateTranslationText(languageCode, termId, value) {
    if (!this.#translationsByLanguage[languageCode]) return;
    if (!this.#translationsByLanguage[languageCode][termId]) {
      this.#translationsByLanguage[languageCode][termId] = {};
    }
    this.#translationsByLanguage[languageCode][termId].text = value;
    this.#modifiedFileKeys.add('translation:' + languageCode);
  }

  updateTranslationNote(languageCode, termId, value) {
    if (!this.#translationsByLanguage[languageCode]) return;
    if (!this.#translationsByLanguage[languageCode][termId]) {
      this.#translationsByLanguage[languageCode][termId] = {};
    }
    const entry = this.#translationsByLanguage[languageCode][termId];
    if (value === '') {
      delete entry.note;
    } else {
      entry.note = value;
    }
    this.#modifiedFileKeys.add('translation:' + languageCode);
  }

  #buildDeckLookupMap() {
    this.#deckLookupMap = new Map();
    for (const deck of this.#levelsData.decks) {
      this.#deckLookupMap.set(deck.id, deck);
    }
  }

  #buildTermDeckMembershipIndex() {
    this.#termDeckMembershipIndex = new Map();
    for (const deck of this.#levelsData.decks) {
      for (const termId of deck.terms) {
        if (!this.#termDeckMembershipIndex.has(termId)) {
          this.#termDeckMembershipIndex.set(termId, new Set());
        }
        this.#termDeckMembershipIndex.get(termId).add(deck.id);
      }
    }
  }

  #openIndexedDatabase() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open('langwij-admin', 1);
      request.onupgradeneeded = () => {
        request.result.createObjectStore('handles');
      };
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  async #saveHandleToDatabase(handle) {
    const db = await this.#openIndexedDatabase();
    return new Promise((resolve, reject) => {
      const tx = db.transaction('handles', 'readwrite');
      tx.objectStore('handles').put(handle, 'data-folder');
      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error);
    });
  }

  async #loadHandleFromDatabase() {
    const db = await this.#openIndexedDatabase();
    return new Promise((resolve, reject) => {
      const tx = db.transaction('handles', 'readonly');
      const request = tx.objectStore('handles').get('data-folder');
      request.onsuccess = () => resolve(request.result || null);
      request.onerror = () => reject(request.error);
    });
  }

  async #readJsonFromHandle(parentHandle, fileName) {
    const fileHandle = await parentHandle.getFileHandle(fileName);
    const file = await fileHandle.getFile();
    const text = await file.text();
    return JSON.parse(text);
  }

  async #writeJsonToHandle(parentHandle, fileName, data) {
    const fileHandle = await parentHandle.getFileHandle(fileName);
    const writable = await fileHandle.createWritable();
    await writable.write(JSON.stringify(data, null, 2) + '\n');
    await writable.close();
  }
}
