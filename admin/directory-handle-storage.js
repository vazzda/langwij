class SavedDirectoryHandleStorage {
  static #databaseName = 'langwij-admin';
  static #databaseVersion = 1;
  static #handleStoreName = 'handles';
  static #dataFolderHandleKey = 'data-folder';
  static #readOnlyTransactionMode = 'readonly';
  static #readWriteTransactionMode = 'readwrite';

  async saveDirectoryHandle(directoryHandle) {
    await this.#runHandleStoreRequest(
      SavedDirectoryHandleStorage.#readWriteTransactionMode,
      (handleStore) => handleStore.put(directoryHandle, SavedDirectoryHandleStorage.#dataFolderHandleKey)
    );
  }

  async loadDirectoryHandle() {
    const savedDirectoryHandle = await this.#runHandleStoreRequest(
      SavedDirectoryHandleStorage.#readOnlyTransactionMode,
      (handleStore) => handleStore.get(SavedDirectoryHandleStorage.#dataFolderHandleKey)
    );
    return savedDirectoryHandle || null;
  }

  async deleteDirectoryHandle() {
    await this.#runHandleStoreRequest(
      SavedDirectoryHandleStorage.#readWriteTransactionMode,
      (handleStore) => handleStore.delete(SavedDirectoryHandleStorage.#dataFolderHandleKey)
    );
  }

  async #runHandleStoreRequest(transactionMode, createStoreRequest) {
    const database = await this.#openDatabase();
    try {
      return await this.#completeHandleStoreTransaction(database, transactionMode, createStoreRequest);
    } finally {
      database.close();
    }
  }

  #completeHandleStoreTransaction(database, transactionMode, createStoreRequest) {
    return new Promise((resolve, reject) => {
      const transaction = database.transaction(SavedDirectoryHandleStorage.#handleStoreName, transactionMode);
      const storeRequest = createStoreRequest(
        transaction.objectStore(SavedDirectoryHandleStorage.#handleStoreName)
      );
      transaction.oncomplete = () => resolve(storeRequest.result);
      transaction.onerror = () => reject(transaction.error);
      transaction.onabort = () => reject(transaction.error);
    });
  }

  #openDatabase() {
    return new Promise((resolve, reject) => {
      const openRequest = indexedDB.open(
        SavedDirectoryHandleStorage.#databaseName,
        SavedDirectoryHandleStorage.#databaseVersion
      );
      openRequest.onupgradeneeded = () => {
        openRequest.result.createObjectStore(SavedDirectoryHandleStorage.#handleStoreName);
      };
      openRequest.onsuccess = () => resolve(openRequest.result);
      openRequest.onerror = () => reject(openRequest.error);
    });
  }
}
