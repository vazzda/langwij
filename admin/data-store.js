// The key under which a change of levels.json is remembered until it is saved.
const LEVELS_FILE_KEY = 'levels';

class LanguageDataStore {
  #savedDirectoryHandleStorage = new SavedDirectoryHandleStorage();
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
    await this.#savedDirectoryHandleStorage.saveDirectoryHandle(this.#directoryHandle);
  }

  async restoreDirectory() {
    const handle = await this.#savedDirectoryHandleStorage.loadDirectoryHandle();
    if (!handle) return false;
    const permission = await handle.requestPermission({ mode: 'readwrite' });
    if (permission !== 'granted') return false;
    this.#directoryHandle = handle;
    return true;
  }

  async hasSavedDirectory() {
    const handle = await this.#savedDirectoryHandleStorage.loadDirectoryHandle();
    return handle !== null;
  }

  async deleteSavedDirectory() {
    await this.#savedDirectoryHandleStorage.deleteDirectoryHandle();
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
    if (this.#modifiedFileKeys.has(LEVELS_FILE_KEY)) {
      await this.#writeJsonToHandle(this.#directoryHandle, 'levels.json', this.#levelsData);
      this.#modifiedFileKeys.delete(LEVELS_FILE_KEY);
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

    this.#modifiedFileKeys.add(LEVELS_FILE_KEY);
  }

  reorderTermWithinDeck(deckId, termId, newIndex) {
    const deck = this.#deckLookupMap.get(deckId);
    if (!deck) return;
    const currentIndex = deck.terms.indexOf(termId);
    if (currentIndex === -1) return;
    deck.terms.splice(currentIndex, 1);
    deck.terms.splice(newIndex, 0, termId);
    this.#modifiedFileKeys.add(LEVELS_FILE_KEY);
  }

  // Moves a deck to a new place among the decks of its level; the index counts
  // the level's decks without the moved one.
  reorderDeckWithinLevel(levelId, deckId, newIndex) {
    const levelDefinition = this.#levelsData.levels.find(level => level.id === levelId);
    if (!levelDefinition) return;
    const currentIndex = levelDefinition.decks.indexOf(deckId);
    if (currentIndex === -1) return;
    levelDefinition.decks.splice(currentIndex, 1);
    levelDefinition.decks.splice(newIndex, 0, deckId);
    this.#modifiedFileKeys.add(LEVELS_FILE_KEY);
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
