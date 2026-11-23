// The two kinds of things dragged on the structure page. Each travels under
// its own type, so a drop zone can tell them apart and ignore the other kind.
const DragPayloadType = Object.freeze({
  term: 'application/x-langwij-term',
  deck: 'application/x-langwij-deck',
});
const InsertionMarkerClass = Object.freeze({ before: 'insert-before', after: 'insert-after' });
const DRAGGED_ITEM_CLASS = 'dragging';
const DECK_AUTO_EXPAND_DELAY_MS = 800;

function isDragOfPayloadType(event, payloadType) {
  return Array.from(event.dataTransfer.types).includes(payloadType);
}

function readDragPayload(event, payloadType) {
  return JSON.parse(event.dataTransfer.getData(payloadType));
}

// The place a moved item takes in its list once it is taken out of it and put
// before or after the target item. Both indexes count the list as it stands
// before the move.
function computeIndexAfterRemoval(movedIndex, targetIndex, isPlacedAfterTarget) {
  const insertionIndex = isPlacedAfterTarget ? targetIndex + 1 : targetIndex;
  return movedIndex < insertionIndex ? insertionIndex - 1 : insertionIndex;
}

// The level whose decks stand in a grid under the columns of the general levels.
const SPECIALIZED_LEVEL_ID = 'specialized';
// The CSS property that tells a segment marker how many level columns it spans.
const SEGMENT_COLUMN_COUNT_PROPERTY = '--segment-column-count';

// Groups the level columns, in their order, into runs of neighbours that belong
// to the same segment. A run of levels outside every segment has a null segmentId.
function groupLevelIdsIntoSegmentRuns(levelIds, segmentDefinitions) {
  const segmentIdByLevelId = new Map();
  for (const segmentDefinition of segmentDefinitions) {
    for (const levelId of segmentDefinition.levels) {
      segmentIdByLevelId.set(levelId, segmentDefinition.id);
    }
  }

  const segmentRuns = [];
  for (const levelId of levelIds) {
    const segmentId = segmentIdByLevelId.has(levelId) ? segmentIdByLevelId.get(levelId) : null;
    const lastRun = segmentRuns[segmentRuns.length - 1];
    if (lastRun && lastRun.segmentId === segmentId) {
      lastRun.columnCount += 1;
    } else {
      segmentRuns.push({ segmentId, columnCount: 1 });
    }
  }
  return segmentRuns;
}

class DraggableTermChip {
  #termId;
  #partOfSpeech;
  #currentDeckId;
  #element;
  #multiDeckCount;
  #numberElement;
  #badgeElement;
  #coca;
  #onRemoveCallback;

  constructor(termId, partOfSpeech, deckId, multiDeckCount, coca, onRemoveCallback) {
    this.#termId = termId;
    this.#partOfSpeech = partOfSpeech;
    this.#currentDeckId = deckId;
    this.#multiDeckCount = multiDeckCount;
    this.#coca = coca;
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

    const cocaSpan = document.createElement('span');
    cocaSpan.className = 'term-coca';
    if (this.#coca != null) cocaSpan.textContent = this.#coca;
    chip.appendChild(cocaSpan);

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
    event.dataTransfer.setData(DragPayloadType.term, JSON.stringify({
      termId: this.#termId,
      sourceDeckId: this.#currentDeckId || ''
    }));
    event.dataTransfer.effectAllowed = 'move';
    this.#element.classList.add(DRAGGED_ITEM_CLASS);
  }

  #handleDragEnd() {
    this.#element.classList.remove(DRAGGED_ITEM_CLASS);
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
  #isBeingDragged = false;
  #onTermDroppedCallback;
  #dropZoneDragCounter = 0;
  #autoExpandTimeout = null;
  #sectionDragCounter = 0;

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
  get isBeingDragged() { return this.#isBeingDragged; }

  setInsertionMarker(markerClass) {
    this.clearInsertionMarker();
    this.#sectionElement.classList.add(markerClass);
  }

  clearInsertionMarker() {
    this.#sectionElement.classList.remove(InsertionMarkerClass.before, InsertionMarkerClass.after);
  }

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
    header.draggable = true;
    header.addEventListener('dragstart', (e) => this.#handleDeckDragStart(e));
    header.addEventListener('dragend', () => this.#handleDeckDragEnd());

    this.#bodyElement = document.createElement('div');
    this.#bodyElement.className = 'deck-body';

    section.appendChild(header);
    section.appendChild(this.#bodyElement);
    return section;
  }

  // The deck itself is dragged by its header, to a new place inside its level.
  #handleDeckDragStart(event) {
    event.dataTransfer.setData(DragPayloadType.deck, JSON.stringify({ deckId: this.#deckId }));
    event.dataTransfer.effectAllowed = 'move';
    this.#isBeingDragged = true;
    this.#sectionElement.classList.add(DRAGGED_ITEM_CLASS);
  }

  #handleDeckDragEnd() {
    this.#isBeingDragged = false;
    this.#sectionElement.classList.remove(DRAGGED_ITEM_CLASS);
  }

  // The deck is a drop zone for terms only; a dragged deck passes through to its level.
  #setupDropZoneListeners() {
    this.#bodyElement.addEventListener('dragenter', (e) => this.#handleDragEnter(e));
    this.#bodyElement.addEventListener('dragleave', (e) => this.#handleDragLeave(e));
    this.#bodyElement.addEventListener('dragover', (e) => this.#handleDragOver(e));
    this.#bodyElement.addEventListener('drop', (e) => this.#handleDrop(e));

    this.#sectionElement.addEventListener('dragenter', (e) => {
      if (!isDragOfPayloadType(e, DragPayloadType.term)) return;
      e.preventDefault();
      this.#sectionDragCounter++;
      if (!this.#isExpanded && !this.#autoExpandTimeout) {
        this.#autoExpandTimeout = setTimeout(() => {
          this.setExpanded(true);
          this.#autoExpandTimeout = null;
        }, DECK_AUTO_EXPAND_DELAY_MS);
      }
    });

    this.#sectionElement.addEventListener('dragleave', (e) => {
      if (!isDragOfPayloadType(e, DragPayloadType.term)) return;
      this.#sectionDragCounter--;
      if (this.#sectionDragCounter === 0) {
        clearTimeout(this.#autoExpandTimeout);
        this.#autoExpandTimeout = null;
      }
    });
  }

  #handleDragEnter(event) {
    if (!isDragOfPayloadType(event, DragPayloadType.term)) return;
    event.preventDefault();
    this.#dropZoneDragCounter++;
    this.#bodyElement.classList.add('drop-target');
  }

  #handleDragLeave(event) {
    if (!isDragOfPayloadType(event, DragPayloadType.term)) return;
    this.#dropZoneDragCounter--;
    if (this.#dropZoneDragCounter === 0) {
      this.#bodyElement.classList.remove('drop-target');
      this.#clearInsertionIndicator();
    }
  }

  #handleDragOver(event) {
    if (!isDragOfPayloadType(event, DragPayloadType.term)) return;
    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
    this.#showInsertionIndicator(
      this.#computeInsertionIndexFromDropPosition(event)
    );
  }

  #handleDrop(event) {
    if (!isDragOfPayloadType(event, DragPayloadType.term)) return;
    event.preventDefault();
    this.#dropZoneDragCounter = 0;
    this.#sectionDragCounter = 0;
    clearTimeout(this.#autoExpandTimeout);
    this.#autoExpandTimeout = null;
    this.#bodyElement.classList.remove('drop-target');
    this.#clearInsertionIndicator();
    const insertionIndex = this.#computeInsertionIndexFromDropPosition(event);
    const payload = readDragPayload(event, DragPayloadType.term);
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
      this.#termChips[index].element.classList.add(InsertionMarkerClass.before);
    }
  }

  #clearInsertionIndicator() {
    for (const chip of this.#termChips) {
      chip.element.classList.remove(InsertionMarkerClass.before);
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
  #onDeckReorderedCallback;

  constructor(levelId, displayName, onDeckReorderedCallback) {
    this.#levelId = levelId;
    this.#displayName = displayName;
    this.#onDeckReorderedCallback = onDeckReorderedCallback;
    this.#sectionElement = this.#buildSectionElement();
    this.#setupDeckDropZoneListeners();
  }

  get element() { return this.#sectionElement; }
  get levelId() { return this.#levelId; }
  get deckPanels() { return this.#deckPanels; }

  // The level is a drop zone for its own decks only: a deck dragged here from
  // another level is not accepted.
  #setupDeckDropZoneListeners() {
    this.#bodyElement.addEventListener('dragover', (e) => this.#handleDeckDragOver(e));
    this.#bodyElement.addEventListener('dragleave', (e) => this.#handleDeckDragLeave(e));
    this.#bodyElement.addEventListener('drop', (e) => this.#handleDeckDrop(e));
    this.#bodyElement.addEventListener('dragend', () => this.#clearDeckInsertionMarkers());
  }

  #findDeckPanelBeingDragged(event) {
    if (!isDragOfPayloadType(event, DragPayloadType.deck)) return undefined;
    return this.#deckPanels.find(deckPanel => deckPanel.isBeingDragged);
  }

  // The deck under the pointer and the half of it the pointer is in. Over an
  // empty spot of the level the place is after the last deck.
  #findDeckPlacementFromPointer(event) {
    const targetIndex = this.#deckPanels.findIndex(deckPanel => deckPanel.element.contains(event.target));
    if (targetIndex === -1) {
      return { targetIndex: this.#deckPanels.length - 1, isPlacedAfterTarget: true };
    }
    const targetRect = this.#deckPanels[targetIndex].element.getBoundingClientRect();
    const isPlacedAfterTarget = event.clientY >= targetRect.top + targetRect.height / 2;
    return { targetIndex, isPlacedAfterTarget };
  }

  #handleDeckDragOver(event) {
    const movedDeckPanel = this.#findDeckPanelBeingDragged(event);
    if (!movedDeckPanel) return;
    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
    const placement = this.#findDeckPlacementFromPointer(event);
    const targetDeckPanel = this.#deckPanels[placement.targetIndex];
    this.#clearDeckInsertionMarkers();
    if (targetDeckPanel !== movedDeckPanel) {
      targetDeckPanel.setInsertionMarker(
        placement.isPlacedAfterTarget ? InsertionMarkerClass.after : InsertionMarkerClass.before
      );
    }
  }

  #handleDeckDragLeave(event) {
    if (!this.#bodyElement.contains(event.relatedTarget)) this.#clearDeckInsertionMarkers();
  }

  #handleDeckDrop(event) {
    const movedDeckPanel = this.#findDeckPanelBeingDragged(event);
    if (!movedDeckPanel) return;
    event.preventDefault();
    this.#clearDeckInsertionMarkers();
    const placement = this.#findDeckPlacementFromPointer(event);
    const movedIndex = this.#deckPanels.indexOf(movedDeckPanel);
    const newIndex = computeIndexAfterRemoval(movedIndex, placement.targetIndex, placement.isPlacedAfterTarget);
    if (newIndex === movedIndex) return;
    this.#moveDeckPanelToIndex(movedDeckPanel, newIndex);
    this.#onDeckReorderedCallback(this.#levelId, movedDeckPanel.deckId, newIndex);
  }

  #moveDeckPanelToIndex(deckPanel, newIndex) {
    this.#deckPanels.splice(this.#deckPanels.indexOf(deckPanel), 1);
    this.#deckPanels.splice(newIndex, 0, deckPanel);
    const followingDeckPanel = this.#deckPanels[newIndex + 1];
    this.#bodyElement.insertBefore(deckPanel.element, followingDeckPanel ? followingDeckPanel.element : null);
  }

  #clearDeckInsertionMarkers() {
    for (const deckPanel of this.#deckPanels) deckPanel.clearInsertionMarker();
  }

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

    const names = this.#dataStore.displayNames;

    const mainRow = document.createElement('div');
    mainRow.className = 'level-columns-container';

    const secondaryRow = document.createElement('div');
    secondaryRow.className = 'level-columns-container';

    const levelIdsOfMainRow = [];
    for (const levelDef of this.#dataStore.levelDefinitions) {
      const levelPanel = this.#buildLevelPanel(levelDef, names);
      levelPanel.setExpanded(true);
      this.#levelPanels.push(levelPanel);

      if (levelDef.id === SPECIALIZED_LEVEL_ID) {
        levelPanel.element.classList.add('columned');
        secondaryRow.appendChild(levelPanel.element);
      } else {
        mainRow.appendChild(levelPanel.element);
        levelIdsOfMainRow.push(levelDef.id);
      }
    }

    this.#buildUnassignedSection();
    secondaryRow.insertBefore(this.#unassignedSectionElement, secondaryRow.firstChild);

    const wrapper = document.createElement('div');
    wrapper.className = 'level-rows-wrapper';
    const segmentMarkerRow = this.#buildSegmentMarkerRow(levelIdsOfMainRow, names);
    if (segmentMarkerRow) wrapper.appendChild(segmentMarkerRow);
    wrapper.appendChild(mainRow);
    wrapper.appendChild(secondaryRow);
    this.#containerElement.appendChild(wrapper);
  }

  // One named line per segment above the level columns, as wide as the
  // segment's columns. Returns null when the data names no segments.
  #buildSegmentMarkerRow(levelIdsOfMainRow, names) {
    const segmentDefinitions = this.#dataStore.segmentDefinitions;
    if (segmentDefinitions.length === 0) return null;

    const markerRow = document.createElement('div');
    markerRow.className = 'segment-marker-row';
    for (const segmentRun of groupLevelIdsIntoSegmentRuns(levelIdsOfMainRow, segmentDefinitions)) {
      markerRow.appendChild(this.#buildSegmentMarker(segmentRun, names));
    }
    return markerRow;
  }

  // A run of levels outside every segment gets an empty spot of the same
  // width, so the lines after it still stand over their own columns.
  #buildSegmentMarker(segmentRun, names) {
    const marker = document.createElement('div');
    marker.className = 'segment-marker';
    marker.style.setProperty(SEGMENT_COLUMN_COUNT_PROPERTY, String(segmentRun.columnCount));

    if (segmentRun.segmentId === null) {
      marker.classList.add('without-segment');
      return marker;
    }

    const segmentNames = names.segments[segmentRun.segmentId];
    marker.textContent = (segmentNames && segmentNames.name) || segmentRun.segmentId;
    return marker;
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
    const levelPanel = new LevelAccordionPanel(
      levelDef.id,
      levelDisplayName,
      (levelId, deckId, newIndex) => this.#handleDeckReordered(levelId, deckId, newIndex)
    );

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
      if (!isDragOfPayloadType(e, DragPayloadType.term)) return;
      e.preventDefault();
      dragCounter++;
      this.#unassignedBodyElement.classList.add('drop-target');
    });

    this.#unassignedBodyElement.addEventListener('dragleave', (e) => {
      if (!isDragOfPayloadType(e, DragPayloadType.term)) return;
      dragCounter--;
      if (dragCounter === 0) {
        this.#unassignedBodyElement.classList.remove('drop-target');
      }
    });

    this.#unassignedBodyElement.addEventListener('dragover', (e) => {
      if (!isDragOfPayloadType(e, DragPayloadType.term)) return;
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
    });

    this.#unassignedBodyElement.addEventListener('drop', (e) => {
      if (!isDragOfPayloadType(e, DragPayloadType.term)) return;
      e.preventDefault();
      dragCounter = 0;
      this.#unassignedBodyElement.classList.remove('drop-target');
      const payload = readDragPayload(e, DragPayloadType.term);
      this.#handleTermDropped(null, payload.termId, payload.sourceDeckId || null);
    });
  }

  #createTermChip(termId, deckId) {
    const terms = this.#dataStore.dictionaryTerms;
    const partOfSpeech = terms[termId] ? terms[termId].pos : '?';
    const multiDeckCount = this.#dataStore.getDeckIdsForTerm(termId).size;
    const coca = terms[termId] ? terms[termId].coca : null;
    const removeCallback = deckId
      ? (chip) => this.#handleTermDropped(null, chip.termId, chip.currentDeckId)
      : null;
    const chip = new DraggableTermChip(termId, partOfSpeech, deckId, multiDeckCount, coca, removeCallback);

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
    this.#announceUnsavedChange();
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
    this.#announceUnsavedChange();
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
    this.#announceUnsavedChange();
  }

  #handleDeckReordered(levelId, deckId, newIndex) {
    this.#dataStore.reorderDeckWithinLevel(levelId, deckId, newIndex);
    this.#announceUnsavedChange();
  }

  // Tells the application that something waits to be saved.
  #announceUnsavedChange() {
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
