class DraggableTermChip {
  #termId;
  #partOfSpeech;
  #currentDeckId;
  #element;
  #multiDeckCount;
  #numberElement;
  #badgeElement;
  #onRemoveCallback;

  constructor(termId, partOfSpeech, deckId, multiDeckCount, onRemoveCallback) {
    this.#termId = termId;
    this.#partOfSpeech = partOfSpeech;
    this.#currentDeckId = deckId;
    this.#multiDeckCount = multiDeckCount;
    this.#onRemoveCallback = onRemoveCallback;
    this.#element = this.#buildElement();
  }

  get element() { return this.#element; }
  get termId() { return this.#termId; }
  get currentDeckId() { return this.#currentDeckId; }

  setCurrentDeckId(deckId) {
    this.#currentDeckId = deckId;
  }

  setHighlighted(isHighlighted) {
    this.#element.classList.toggle('highlighted', isHighlighted);
  }

  setVisible(isVisible) {
    this.#element.hidden = !isVisible;
  }

  setListNumber(number) {
    this.#numberElement.textContent = number;
  }

  updateMultiDeckCount(count) {
    this.#multiDeckCount = count;
    this.#element.classList.toggle('multi-deck', count > 1);
    if (count > 1) {
      this.#badgeElement.textContent = count;
      this.#badgeElement.classList.remove('bare');
    } else {
      this.#badgeElement.textContent = '0';
      this.#badgeElement.classList.add('bare');
    }
  }

  #buildElement() {
    const chip = document.createElement('div');
    chip.className = 'term-chip';
    chip.draggable = true;
    chip.dataset.pos = this.#partOfSpeech || '';
    if (this.#multiDeckCount > 1) chip.classList.add('multi-deck');

    this.#numberElement = document.createElement('span');
    this.#numberElement.className = 'term-number';

    this.#badgeElement = document.createElement('span');
    this.#badgeElement.className = 'term-badge';
    if (this.#multiDeckCount > 1) {
      this.#badgeElement.textContent = this.#multiDeckCount;
    } else {
      this.#badgeElement.textContent = '0';
      this.#badgeElement.classList.add('bare');
    }

    const idSpan = document.createElement('span');
    idSpan.className = 'term-id';
    idSpan.textContent = this.#termId;

    const posSpan = document.createElement('span');
    posSpan.className = 'term-pos';
    posSpan.textContent = this.#partOfSpeech || '?';

    chip.appendChild(this.#numberElement);
    chip.appendChild(this.#badgeElement);
    chip.appendChild(idSpan);
    chip.appendChild(posSpan);

    if (this.#onRemoveCallback) {
      const removeBtn = document.createElement('span');
      removeBtn.className = 'term-remove';
      removeBtn.textContent = '×';
      removeBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        this.#onRemoveCallback(this);
      });
      chip.appendChild(removeBtn);
    }

    chip.addEventListener('dragstart', (e) => this.#handleDragStart(e));
    chip.addEventListener('dragend', () => this.#handleDragEnd());
    return chip;
  }

  #handleDragStart(event) {
    event.dataTransfer.setData('text/plain', JSON.stringify({
      termId: this.#termId,
      sourceDeckId: this.#currentDeckId || ''
    }));
    event.dataTransfer.effectAllowed = 'move';
    this.#element.classList.add('dragging');
  }

  #handleDragEnd() {
    this.#element.classList.remove('dragging');
  }
}


class DeckAccordionPanel {
  #deckId;
  #displayName;
  #sectionElement;
  #bodyElement;
  #collapseIconElement;
  #termCountElement;
  #termChips = [];
  #isExpanded = false;
  #onTermDroppedCallback;
  #dropZoneDragCounter = 0;

  constructor(deckId, displayName, onTermDroppedCallback) {
    this.#deckId = deckId;
    this.#displayName = displayName;
    this.#onTermDroppedCallback = onTermDroppedCallback;
    this.#sectionElement = this.#buildSectionElement();
    this.#setupDropZoneListeners();
  }

  get element() { return this.#sectionElement; }
  get deckId() { return this.#deckId; }
  get termCount() { return this.#termChips.length; }

  appendTermChip(chip) {
    this.#termChips.push(chip);
    this.#bodyElement.appendChild(chip.element);
    this.updateTermCountDisplay();
    this.#refreshListNumbers();
  }

  insertTermChipAtIndex(chip, index) {
    const clampedIndex = Math.min(index, this.#termChips.length);
    this.#termChips.splice(clampedIndex, 0, chip);
    const referenceNode = this.#bodyElement.children[clampedIndex] || null;
    this.#bodyElement.insertBefore(chip.element, referenceNode);
    this.updateTermCountDisplay();
    this.#refreshListNumbers();
  }

  removeTermChip(chip) {
    const index = this.#termChips.indexOf(chip);
    if (index !== -1) this.#termChips.splice(index, 1);
    chip.element.remove();
    this.updateTermCountDisplay();
    this.#refreshListNumbers();
  }

  #refreshListNumbers() {
    for (let i = 0; i < this.#termChips.length; i++) {
      this.#termChips[i].setListNumber(i + 1);
    }
  }

  setExpanded(isExpanded) {
    this.#isExpanded = isExpanded;
    this.#bodyElement.classList.toggle('expanded', isExpanded);
    this.#collapseIconElement.textContent = isExpanded ? '▾' : '▸';
  }

  toggleExpanded() {
    this.setExpanded(!this.#isExpanded);
  }

  setVisible(isVisible) {
    this.#sectionElement.classList.toggle('no-match', !isVisible);
  }

  updateTermCountDisplay() {
    this.#termCountElement.textContent = this.#termChips.length;
  }

  hasVisibleChips() {
    return this.#termChips.some(chip => !chip.element.hidden);
  }

  #buildSectionElement() {
    const section = document.createElement('div');
    section.className = 'deck-section';

    const header = document.createElement('div');
    header.className = 'deck-header';

    this.#collapseIconElement = document.createElement('span');
    this.#collapseIconElement.className = 'collapse-icon';
    this.#collapseIconElement.textContent = '▸';

    const nameSpan = document.createElement('span');
    nameSpan.className = 'deck-name';
    nameSpan.textContent = this.#displayName;

    const idSpan = document.createElement('span');
    idSpan.className = 'deck-id';
    idSpan.textContent = this.#deckId;

    this.#termCountElement = document.createElement('span');
    this.#termCountElement.className = 'deck-count';
    this.#termCountElement.textContent = '0';

    header.appendChild(this.#collapseIconElement);
    header.appendChild(idSpan);
    header.appendChild(this.#termCountElement);
    header.appendChild(nameSpan);
    header.addEventListener('click', () => this.toggleExpanded());

    this.#bodyElement = document.createElement('div');
    this.#bodyElement.className = 'deck-body';

    section.appendChild(header);
    section.appendChild(this.#bodyElement);
    return section;
  }

  #setupDropZoneListeners() {
    this.#bodyElement.addEventListener('dragenter', (e) => this.#handleDragEnter(e));
    this.#bodyElement.addEventListener('dragleave', () => this.#handleDragLeave());
    this.#bodyElement.addEventListener('dragover', (e) => this.#handleDragOver(e));
    this.#bodyElement.addEventListener('drop', (e) => this.#handleDrop(e));
  }

  #handleDragEnter(event) {
    event.preventDefault();
    this.#dropZoneDragCounter++;
    this.#bodyElement.classList.add('drop-target');
  }

  #handleDragLeave() {
    this.#dropZoneDragCounter--;
    if (this.#dropZoneDragCounter === 0) {
      this.#bodyElement.classList.remove('drop-target');
      this.#clearInsertionIndicator();
    }
  }

  #handleDragOver(event) {
    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
    this.#showInsertionIndicator(
      this.#computeInsertionIndexFromDropPosition(event)
    );
  }

  #handleDrop(event) {
    event.preventDefault();
    this.#dropZoneDragCounter = 0;
    this.#bodyElement.classList.remove('drop-target');
    this.#clearInsertionIndicator();
    const insertionIndex = this.#computeInsertionIndexFromDropPosition(event);
    const payload = JSON.parse(event.dataTransfer.getData('text/plain'));
    this.#onTermDroppedCallback(payload.termId, payload.sourceDeckId || null, insertionIndex, event.shiftKey);
  }

  #computeInsertionIndexFromDropPosition(event) {
    for (let i = 0; i < this.#termChips.length; i++) {
      const rect = this.#termChips[i].element.getBoundingClientRect();
      const midY = rect.top + rect.height / 2;
      if (event.clientY < midY) return i;
    }
    return this.#termChips.length;
  }

  #showInsertionIndicator(index) {
    this.#clearInsertionIndicator();
    if (index < this.#termChips.length) {
      this.#termChips[index].element.classList.add('insert-before');
    }
  }

  #clearInsertionIndicator() {
    for (const chip of this.#termChips) {
      chip.element.classList.remove('insert-before');
    }
  }
}


class LevelAccordionPanel {
  #levelId;
  #displayName;
  #sectionElement;
  #bodyElement;
  #collapseIconElement;
  #termCountElement;
  #deckPanels = [];
  #isExpanded = false;

  constructor(levelId, displayName) {
    this.#levelId = levelId;
    this.#displayName = displayName;
    this.#sectionElement = this.#buildSectionElement();
  }

  get element() { return this.#sectionElement; }
  get levelId() { return this.#levelId; }
  get deckPanels() { return this.#deckPanels; }

  appendDeckPanel(deckPanel) {
    this.#deckPanels.push(deckPanel);
    this.#bodyElement.appendChild(deckPanel.element);
    this.updateTermCountDisplay();
  }

  setExpanded(isExpanded) {
    this.#isExpanded = isExpanded;
    this.#bodyElement.classList.toggle('expanded', isExpanded);
    this.#collapseIconElement.textContent = isExpanded ? '▾' : '▸';
  }

  toggleExpanded() {
    this.setExpanded(!this.#isExpanded);
  }

  setVisible(isVisible) {
    this.#sectionElement.classList.toggle('no-match', !isVisible);
  }

  updateTermCountDisplay() {
    const total = this.#deckPanels.reduce((sum, dp) => sum + dp.termCount, 0);
    this.#termCountElement.textContent = total + ' terms';
  }

  hasVisibleDecks() {
    return this.#deckPanels.some(dp => dp.hasVisibleChips());
  }

  #buildSectionElement() {
    const section = document.createElement('div');
    section.className = 'level-section';

    const header = document.createElement('div');
    header.className = 'level-header';

    this.#collapseIconElement = document.createElement('span');
    this.#collapseIconElement.className = 'collapse-icon';
    this.#collapseIconElement.textContent = '▸';

    const nameSpan = document.createElement('span');
    nameSpan.className = 'level-name';
    nameSpan.textContent = this.#displayName;

    this.#termCountElement = document.createElement('span');
    this.#termCountElement.className = 'level-count';
    this.#termCountElement.textContent = '0 terms';

    header.appendChild(this.#collapseIconElement);
    header.appendChild(nameSpan);
    header.appendChild(this.#termCountElement);
    header.addEventListener('click', () => this.toggleExpanded());

    this.#bodyElement = document.createElement('div');
    this.#bodyElement.className = 'level-body';

    section.appendChild(header);
    section.appendChild(this.#bodyElement);
    return section;
  }
}


class StructureEditorPage {
  #dataStore;
  #containerElement;
  #isRendered = false;
  #currentFilterValue = '';
  #levelPanels = [];
  #unassignedSectionElement = null;
  #unassignedBodyElement = null;
  #unassignedCountElement = null;
  #deckPanelsByDeckId = new Map();
  #termChipsByTermId = new Map();

  constructor(containerElement, dataStore) {
    this.#containerElement = containerElement;
    this.#dataStore = dataStore;
  }

  render() {
    if (this.#isRendered) return;
    this.#buildPageContent();
    this.#isRendered = true;
  }

  #buildPageContent() {
    this.#containerElement.innerHTML = '';
    this.#wireHeaderControls();

    const columnsContainer = document.createElement('div');
    columnsContainer.className = 'level-columns-container';

    const names = this.#dataStore.displayNames;

    for (const levelDef of this.#dataStore.levelDefinitions) {
      const levelPanel = this.#buildLevelPanel(levelDef, names);
      levelPanel.setExpanded(true);
      this.#levelPanels.push(levelPanel);
      columnsContainer.appendChild(levelPanel.element);
    }

    this.#buildUnassignedSection();
    columnsContainer.appendChild(this.#unassignedSectionElement);
    this.#containerElement.appendChild(columnsContainer);
  }

  #wireHeaderControls() {
    const filterInput = document.getElementById('structure-filter');
    filterInput.addEventListener('input', (e) => {
      this.#applyTermFilter(e.target.value.toLowerCase());
    });

    document.getElementById('filter-clear-btn').addEventListener('click', () => {
      filterInput.value = '';
      this.#applyTermFilter('');
    });

    document.getElementById('fold-all-btn').addEventListener('click', () => {
      for (const levelPanel of this.#levelPanels) {
        for (const deckPanel of levelPanel.deckPanels) {
          deckPanel.setExpanded(false);
        }
      }
    });

    document.getElementById('unfold-all-btn').addEventListener('click', () => {
      for (const levelPanel of this.#levelPanels) {
        for (const deckPanel of levelPanel.deckPanels) {
          deckPanel.setExpanded(true);
        }
      }
    });
  }

  #buildLevelPanel(levelDef, names) {
    const levelDisplayName =
      (names.levels[levelDef.id] && names.levels[levelDef.id].name) || levelDef.id;
    const levelPanel = new LevelAccordionPanel(levelDef.id, levelDisplayName);

    for (const deckId of levelDef.decks) {
      const deckDef = this.#dataStore.getDeckDefinition(deckId);
      if (!deckDef) continue;
      const deckPanel = this.#buildDeckPanel(deckDef, names);
      levelPanel.appendDeckPanel(deckPanel);
    }

    return levelPanel;
  }

  #buildDeckPanel(deckDef, names) {
    const deckDisplayName =
      (names.decks[deckDef.id] && names.decks[deckDef.id].name) || deckDef.id;

    const deckPanel = new DeckAccordionPanel(
      deckDef.id,
      deckDisplayName,
      (termId, sourceDeckId, insertionIndex, isCopy) => this.#handleTermDropped(deckDef.id, termId, sourceDeckId, insertionIndex, isCopy)
    );

    for (const termId of deckDef.terms) {
      const chip = this.#createTermChip(termId, deckDef.id);
      deckPanel.appendTermChip(chip);
    }

    this.#deckPanelsByDeckId.set(deckDef.id, deckPanel);
    return deckPanel;
  }

  #buildUnassignedSection() {
    const unassignedTermIds = this.#dataStore.getUnassignedTermIds();

    this.#unassignedSectionElement = document.createElement('div');
    this.#unassignedSectionElement.className = 'level-section unassigned-section';

    const header = document.createElement('div');
    header.className = 'level-header unassigned-header';

    const collapseIcon = document.createElement('span');
    collapseIcon.className = 'collapse-icon';
    collapseIcon.textContent = '▾';

    const nameSpan = document.createElement('span');
    nameSpan.className = 'level-name';
    nameSpan.textContent = 'Unassigned';

    this.#unassignedCountElement = document.createElement('span');
    this.#unassignedCountElement.className = 'level-count';
    this.#unassignedCountElement.textContent = unassignedTermIds.length + ' terms';

    header.appendChild(collapseIcon);
    header.appendChild(nameSpan);
    header.appendChild(this.#unassignedCountElement);

    const body = document.createElement('div');
    body.className = 'level-body expanded';

    this.#unassignedBodyElement = document.createElement('div');
    this.#unassignedBodyElement.className = 'deck-body expanded';

    for (const termId of unassignedTermIds) {
      const chip = this.#createTermChip(termId, null);
      this.#unassignedBodyElement.appendChild(chip.element);
    }

    this.#setupUnassignedDropZone();

    header.addEventListener('click', () => {
      const expanded = body.classList.toggle('expanded');
      collapseIcon.textContent = expanded ? '▾' : '▸';
    });

    body.appendChild(this.#unassignedBodyElement);
    this.#unassignedSectionElement.appendChild(header);
    this.#unassignedSectionElement.appendChild(body);
  }

  #setupUnassignedDropZone() {
    let dragCounter = 0;

    this.#unassignedBodyElement.addEventListener('dragenter', (e) => {
      e.preventDefault();
      dragCounter++;
      this.#unassignedBodyElement.classList.add('drop-target');
    });

    this.#unassignedBodyElement.addEventListener('dragleave', () => {
      dragCounter--;
      if (dragCounter === 0) {
        this.#unassignedBodyElement.classList.remove('drop-target');
      }
    });

    this.#unassignedBodyElement.addEventListener('dragover', (e) => {
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
    });

    this.#unassignedBodyElement.addEventListener('drop', (e) => {
      e.preventDefault();
      dragCounter = 0;
      this.#unassignedBodyElement.classList.remove('drop-target');
      const payload = JSON.parse(e.dataTransfer.getData('text/plain'));
      this.#handleTermDropped(null, payload.termId, payload.sourceDeckId || null);
    });
  }

  #createTermChip(termId, deckId) {
    const terms = this.#dataStore.dictionaryTerms;
    const partOfSpeech = terms[termId] ? terms[termId].pos : '?';
    const multiDeckCount = this.#dataStore.getDeckIdsForTerm(termId).size;
    const removeCallback = deckId
      ? (chip) => this.#handleTermDropped(null, chip.termId, chip.currentDeckId)
      : null;
    const chip = new DraggableTermChip(termId, partOfSpeech, deckId, multiDeckCount, removeCallback);

    if (!this.#termChipsByTermId.has(termId)) {
      this.#termChipsByTermId.set(termId, []);
    }
    this.#termChipsByTermId.get(termId).push(chip);

    return chip;
  }

  #handleTermDropped(targetDeckId, termId, sourceDeckId, insertionIndex, isCopy) {
    if (sourceDeckId === targetDeckId && sourceDeckId !== null) {
      this.#handleSameDeckReorder(sourceDeckId, termId, insertionIndex);
      return;
    }

    if (isCopy && targetDeckId && sourceDeckId) {
      this.#handleCopyToDeck(targetDeckId, termId, insertionIndex);
      return;
    }

    this.#dataStore.moveTermBetweenDecks(termId, sourceDeckId, targetDeckId, insertionIndex);

    const chips = this.#termChipsByTermId.get(termId) || [];
    const sourceChip = chips.find(c => c.currentDeckId === sourceDeckId);

    if (sourceChip) {
      const targetAlreadyHasTerm = targetDeckId &&
        chips.some(c => c.currentDeckId === targetDeckId);

      if (sourceDeckId) {
        this.#deckPanelsByDeckId.get(sourceDeckId).removeTermChip(sourceChip);
      } else {
        sourceChip.element.remove();
      }

      if (targetAlreadyHasTerm) {
        const chipIndex = chips.indexOf(sourceChip);
        if (chipIndex !== -1) chips.splice(chipIndex, 1);
      } else {
        sourceChip.setCurrentDeckId(targetDeckId);
        if (targetDeckId) {
          this.#deckPanelsByDeckId.get(targetDeckId).insertTermChipAtIndex(sourceChip, insertionIndex);
        } else {
          this.#unassignedBodyElement.appendChild(sourceChip.element);
        }
      }
    }

    const deckIds = this.#dataStore.getDeckIdsForTerm(termId);
    const updatedChips = this.#termChipsByTermId.get(termId) || [];
    for (const chip of updatedChips) {
      chip.updateMultiDeckCount(deckIds.size);
    }

    this.#updateCountsAfterMove(sourceDeckId, targetDeckId);
    window.dispatchEvent(new CustomEvent('dirty-change'));
  }

  #handleCopyToDeck(targetDeckId, termId, insertionIndex) {
    const chips = this.#termChipsByTermId.get(termId) || [];
    if (chips.some(c => c.currentDeckId === targetDeckId)) return;

    this.#dataStore.moveTermBetweenDecks(termId, null, targetDeckId, insertionIndex);

    const newChip = this.#createTermChip(termId, targetDeckId);
    this.#deckPanelsByDeckId.get(targetDeckId).insertTermChipAtIndex(newChip, insertionIndex);

    const deckIds = this.#dataStore.getDeckIdsForTerm(termId);
    const updatedChips = this.#termChipsByTermId.get(termId) || [];
    for (const chip of updatedChips) {
      chip.updateMultiDeckCount(deckIds.size);
    }

    this.#updateCountsAfterMove(null, targetDeckId);
    window.dispatchEvent(new CustomEvent('dirty-change'));
  }

  #handleSameDeckReorder(deckId, termId, insertionIndex) {
    const deckPanel = this.#deckPanelsByDeckId.get(deckId);
    const chips = this.#termChipsByTermId.get(termId) || [];
    const chip = chips.find(c => c.currentDeckId === deckId);
    if (!chip) return;

    deckPanel.removeTermChip(chip);
    const adjustedIndex = Math.min(insertionIndex, deckPanel.termCount);
    deckPanel.insertTermChipAtIndex(chip, adjustedIndex);

    this.#dataStore.reorderTermWithinDeck(deckId, termId, adjustedIndex);
    window.dispatchEvent(new CustomEvent('dirty-change'));
  }

  #applyTermFilter(filterValue) {
    this.#currentFilterValue = filterValue;

    for (const [termId, chips] of this.#termChipsByTermId) {
      const isMatch = !filterValue || termId.includes(filterValue);
      for (const chip of chips) {
        chip.setVisible(isMatch);
        chip.setHighlighted(filterValue !== '' && isMatch);
      }
    }

    for (const levelPanel of this.#levelPanels) {
      for (const deckPanel of levelPanel.deckPanels) {
        const hasVisible = deckPanel.hasVisibleChips();
        if (filterValue) deckPanel.setExpanded(hasVisible);
      }
    }

    const unassignedHasVisible = Array.from(this.#unassignedBodyElement.children)
      .some(el => !el.hidden);
    this.#unassignedSectionElement.classList.toggle(
      'no-match',
      filterValue && !unassignedHasVisible
    );
  }

  #updateCountsAfterMove(sourceDeckId, targetDeckId) {
    if (sourceDeckId) {
      this.#deckPanelsByDeckId.get(sourceDeckId).updateTermCountDisplay();
      for (const levelPanel of this.#levelPanels) {
        if (levelPanel.deckPanels.some(dp => dp.deckId === sourceDeckId)) {
          levelPanel.updateTermCountDisplay();
          break;
        }
      }
    } else {
      this.#updateUnassignedCountDisplay();
    }

    if (targetDeckId) {
      this.#deckPanelsByDeckId.get(targetDeckId).updateTermCountDisplay();
      for (const levelPanel of this.#levelPanels) {
        if (levelPanel.deckPanels.some(dp => dp.deckId === targetDeckId)) {
          levelPanel.updateTermCountDisplay();
          break;
        }
      }
    } else {
      this.#updateUnassignedCountDisplay();
    }
  }

  #updateUnassignedCountDisplay() {
    const count = this.#unassignedBodyElement.children.length;
    this.#unassignedCountElement.textContent = count + ' terms';
  }
}
