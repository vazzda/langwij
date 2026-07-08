class AdminApplication {
  #dataStore;
  #structurePage;
  #translationsPage;
  #activeTabName = 'structure';
  #browseButtonElement;
  #saveButtonElement;
  #statusMessageElement;
  #pathHintElement;
  #tabButtonElements;

  constructor() {
    this.#dataStore = new LanguageDataStore();

    this.#browseButtonElement = document.getElementById('pick-folder-btn');
    this.#saveButtonElement = document.getElementById('save-btn');
    this.#statusMessageElement = document.getElementById('status');
    this.#pathHintElement = document.querySelector('.path-hint');
    this.#tabButtonElements = document.querySelectorAll('.tab');

    this.#structurePage = new StructureEditorPage(
      document.getElementById('page-structure'),
      this.#dataStore
    );
    this.#translationsPage = new TranslationEditorPage(
      document.getElementById('page-translations'),
      this.#dataStore
    );

    this.#browseButtonElement.addEventListener('click', () => this.#handleBrowseFolder());
    this.#saveButtonElement.addEventListener('click', () => this.#handleSaveChanges());
    window.addEventListener('dirty-change', () => this.#updateSaveButtonState());
    window.addEventListener('beforeunload', (e) => {
      if (this.#dataStore.hasUnsavedChanges) e.preventDefault();
    });

    this.#attemptHandleRestore();
  }

  async #attemptHandleRestore() {
    try {
      const hasSaved = await this.#dataStore.hasSavedDirectory();
      if (hasSaved) this.#browseButtonElement.textContent = 'Reconnect';
    } catch (_) {
      // IndexedDB unavailable — keep default button text
    }
  }

  async #handleBrowseFolder() {
    try {
      const restored = await this.#dataStore.restoreDirectory();
      if (!restored) await this.#dataStore.selectDirectory();
      await this.#dataStore.loadAllDataFiles();
      this.#browseButtonElement.hidden = true;
      this.#enableTabButtons();
      this.#switchToTab('structure');
    } catch (err) {
      if (err.name !== 'AbortError') {
        this.#statusMessageElement.textContent = 'Error: ' + err.message;
      }
    }
  }

  async #handleSaveChanges() {
    if (!this.#dataStore.hasUnsavedChanges) return;
    this.#saveButtonElement.disabled = true;
    this.#statusMessageElement.textContent = 'Saving...';

    try {
      await this.#dataStore.saveModifiedFiles();
      this.#updateSaveButtonState();
      this.#statusMessageElement.textContent = 'Saved';
      setTimeout(() => {
        if (this.#statusMessageElement.textContent === 'Saved') {
          this.#statusMessageElement.textContent = '';
        }
      }, 2000);
    } catch (err) {
      this.#statusMessageElement.textContent = 'Save failed: ' + err.message;
      this.#saveButtonElement.disabled = false;
    }
  }

  #switchToTab(tabName) {
    this.#activeTabName = tabName;

    this.#tabButtonElements.forEach((btn) => {
      btn.classList.toggle('active', btn.dataset.tab === tabName);
    });

    document.getElementById('page-structure').hidden = (tabName !== 'structure');
    document.getElementById('page-translations').hidden = (tabName !== 'translations');
    document.getElementById('structure-controls').hidden = (tabName !== 'structure');

    if (tabName === 'structure') {
      this.#structurePage.render();
    } else {
      this.#translationsPage.render();
    }
  }

  #enableTabButtons() {
    this.#tabButtonElements.forEach((btn) => {
      btn.disabled = false;
      btn.addEventListener('click', () => {
        this.#switchToTab(btn.dataset.tab);
      });
    });
  }

  #updateSaveButtonState() {
    const dirty = this.#dataStore.hasUnsavedChanges;
    this.#saveButtonElement.disabled = !dirty;
    this.#saveButtonElement.classList.toggle('has-changes', dirty);
    if (dirty) this.#statusMessageElement.textContent = 'Unsaved changes';
  }
}

new AdminApplication();
