class AdminApplication {
  static #browseFolderButtonLabel = 'Browse...';
  static #reconnectFolderButtonLabel = 'Reconnect';
  static #errorStatusMessagePrefix = 'Error: ';

  #dataStore;
  #structurePage;
  #translationsPage;
  #browseButtonElement;
  #deleteSavedFolderButtonElement;
  #saveButtonElement;
  #statusMessageElement;
  #tabButtonElements;

  constructor() {
    this.#dataStore = new LanguageDataStore();

    this.#browseButtonElement = document.getElementById('pick-folder-btn');
    this.#deleteSavedFolderButtonElement = document.getElementById('delete-saved-folder-btn');
    this.#saveButtonElement = document.getElementById('save-btn');
    this.#statusMessageElement = document.getElementById('status');
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
    this.#deleteSavedFolderButtonElement.addEventListener('click', () => this.#handleDeleteSavedFolder());
    this.#saveButtonElement.addEventListener('click', () => this.#handleSaveChanges());
    window.addEventListener('dirty-change', () => this.#updateSaveButtonState());
    window.addEventListener('beforeunload', (e) => {
      if (this.#dataStore.hasUnsavedChanges) e.preventDefault();
    });

    this.#showBrowseButtonForNoSavedDirectory();
    this.#refreshFolderButtonsFromSavedDirectoryState();
  }

  async #refreshFolderButtonsFromSavedDirectoryState() {
    const hasSavedDirectory = await this.#checkWhetherDirectoryIsSaved();
    if (hasSavedDirectory) {
      this.#showReconnectAndDeleteButtonsForSavedDirectory();
    } else {
      this.#showBrowseButtonForNoSavedDirectory();
    }
  }

  async #checkWhetherDirectoryIsSaved() {
    try {
      return await this.#dataStore.hasSavedDirectory();
    } catch (_) {
      // IndexedDB unavailable — no directory can be saved
      return false;
    }
  }

  #showBrowseButtonForNoSavedDirectory() {
    this.#browseButtonElement.textContent = AdminApplication.#browseFolderButtonLabel;
    this.#deleteSavedFolderButtonElement.hidden = true;
  }

  #showReconnectAndDeleteButtonsForSavedDirectory() {
    this.#browseButtonElement.textContent = AdminApplication.#reconnectFolderButtonLabel;
    this.#deleteSavedFolderButtonElement.hidden = false;
  }

  #hideFolderButtons() {
    this.#browseButtonElement.hidden = true;
    this.#deleteSavedFolderButtonElement.hidden = true;
  }

  async #handleBrowseFolder() {
    try {
      await this.#connectDataFolderAndLoadFiles();
    } catch (err) {
      await this.#reportFolderConnectFailure(err);
      return;
    }
    try {
      this.#showEditorForLoadedDataFolder();
    } catch (err) {
      this.#showErrorStatusMessage(err);
    }
  }

  async #connectDataFolderAndLoadFiles() {
    const restored = await this.#dataStore.restoreDirectory();
    if (!restored) await this.#dataStore.selectDirectory();
    await this.#dataStore.loadAllDataFiles();
  }

  async #reportFolderConnectFailure(error) {
    if (error.name !== 'AbortError') this.#showErrorStatusMessage(error);
    await this.#refreshFolderButtonsFromSavedDirectoryState();
  }

  #showEditorForLoadedDataFolder() {
    this.#clearStatusMessage();
    this.#hideFolderButtons();
    this.#enableTabButtons();
    this.#switchToTab('structure');
  }

  async #handleDeleteSavedFolder() {
    try {
      await this.#dataStore.deleteSavedDirectory();
      this.#clearStatusMessage();
    } catch (err) {
      this.#showErrorStatusMessage(err);
    }
    await this.#refreshFolderButtonsFromSavedDirectoryState();
  }

  #showErrorStatusMessage(error) {
    this.#statusMessageElement.textContent = AdminApplication.#errorStatusMessagePrefix + error.message;
  }

  #clearStatusMessage() {
    this.#statusMessageElement.textContent = '';
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
