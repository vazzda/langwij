'use strict';

// Prints the present state of the vocabulary data: words per deck and level,
// repeats, entry shapes per language, and each term's stored COCA rank beside
// the lemma on that row of the frequency file. Reads only; writes nothing.
//
// Usage: node print-level-inventory.js [dataDirectory]

const fs = require('fs');
const path = require('path');

const DEFAULT_DATA_DIRECTORY = path.resolve(__dirname, '..', '..', 'front', 'assets', 'data');
const DICTIONARY_FILE_NAME = 'dictionary.json';
const LEVELS_FILE_NAME = 'levels.json';
const FREQUENCY_FILE_NAME = 'coca_frequency.csv';
const TRANSLATIONS_DIRECTORY_NAME = 'translations';
const TRANSLATION_FILE_EXTENSION = '.json';
const TRANSLATION_META_KEY = 'meta';
const TRANSLATION_NOTE_KEY = 'note';
const SPECIALIZED_LEVEL_ID = 'specialized';
const FIRST_GENERAL_LEVEL_ID = 'top100';
const TERM_ID_TOKEN_SEPARATOR = '_';
const FREQUENCY_FIELD_SEPARATOR = ',';
const FREQUENCY_HEADER_LINE_COUNT = 1;
const ENTRY_SHAPE_KEY_SEPARATOR = '+';
const MISSING_ENTRY_SHAPE_LABEL = '(missing)';

function readJsonFile(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function loadDictionaryTermsById(dataDirectory) {
  const dictionaryData = readJsonFile(path.join(dataDirectory, DICTIONARY_FILE_NAME));
  const termsById = new Map();
  for (const [termId, termData] of Object.entries(dictionaryData.terms)) {
    termsById.set(termId, {
      id: termId,
      pos: termData.pos,
      cocaRank: termData.coca === undefined ? null : termData.coca,
    });
  }
  return termsById;
}

function loadLevelDeckStructure(dataDirectory) {
  const levelsData = readJsonFile(path.join(dataDirectory, LEVELS_FILE_NAME));
  const decksById = new Map();
  for (const deckData of levelsData.decks) {
    decksById.set(deckData.id, {
      id: deckData.id,
      icon: deckData.icon === undefined ? null : deckData.icon,
      termIds: deckData.terms,
    });
  }
  const levels = levelsData.levels.map((levelData) => ({
    id: levelData.id,
    deckIds: levelData.decks,
  }));
  return { levels, decksById };
}

function loadFrequencyRowsInRankOrder(dataDirectory) {
  const fileText = fs.readFileSync(path.join(dataDirectory, FREQUENCY_FILE_NAME), 'utf8');
  const dataLines = fileText
    .split(/\r?\n/)
    .filter((line) => line.length > 0)
    .slice(FREQUENCY_HEADER_LINE_COUNT);
  return dataLines.map((line) => {
    const [rankText, lemma, posCode] = line.split(FREQUENCY_FIELD_SEPARATOR);
    return { rank: Number(rankText), lemma, posCode };
  });
}

function loadTranslationEntriesByLanguage(dataDirectory) {
  const translationsDirectory = path.join(dataDirectory, TRANSLATIONS_DIRECTORY_NAME);
  const entriesByLanguage = new Map();
  const fileNames = fs
    .readdirSync(translationsDirectory)
    .filter((fileName) => fileName.endsWith(TRANSLATION_FILE_EXTENSION))
    .sort();
  for (const fileName of fileNames) {
    const languageCode = path.basename(fileName, TRANSLATION_FILE_EXTENSION);
    entriesByLanguage.set(languageCode, readJsonFile(path.join(translationsDirectory, fileName)));
  }
  return entriesByLanguage;
}

// Which decks hold each term, split into the general levels and Specialized.
function collectLevelTermMembership(levelDeckStructure) {
  const generalDeckIdsByTermId = new Map();
  const specializedDeckIdsByTermId = new Map();
  const firstLevelTermIds = new Set();
  for (const level of levelDeckStructure.levels) {
    const deckIdsByTermId =
      level.id === SPECIALIZED_LEVEL_ID ? specializedDeckIdsByTermId : generalDeckIdsByTermId;
    for (const deckId of level.deckIds) {
      for (const termId of levelDeckStructure.decksById.get(deckId).termIds) {
        if (!deckIdsByTermId.has(termId)) deckIdsByTermId.set(termId, []);
        deckIdsByTermId.get(termId).push(deckId);
        if (level.id === FIRST_GENERAL_LEVEL_ID) firstLevelTermIds.add(termId);
      }
    }
  }
  return { generalDeckIdsByTermId, specializedDeckIdsByTermId, firstLevelTermIds };
}

function printLevelDeckCounts(levelDeckStructure) {
  console.log('LEVELS AND DECKS');
  for (const level of levelDeckStructure.levels) {
    const levelTermIds = [];
    const deckCountLabels = [];
    for (const deckId of level.deckIds) {
      const deckTermIds = levelDeckStructure.decksById.get(deckId).termIds;
      levelTermIds.push(...deckTermIds);
      deckCountLabels.push(`${deckId} ${deckTermIds.length}`);
    }
    const distinctCount = new Set(levelTermIds).size;
    console.log(
      `${level.id}: ${level.deckIds.length} decks, ${levelTermIds.length} slots, ${distinctCount} distinct`,
    );
    console.log(`  ${deckCountLabels.join(' | ')}`);
  }
}

function countDeckSlots(deckIdsByTermId) {
  let slotCount = 0;
  for (const deckIds of deckIdsByTermId.values()) slotCount += deckIds.length;
  return slotCount;
}

function printTermTotals(termsById, levelTermMembership) {
  const { generalDeckIdsByTermId, specializedDeckIdsByTermId } = levelTermMembership;
  const generalSlotCount = countDeckSlots(generalDeckIdsByTermId);
  const specializedSlotCount = countDeckSlots(specializedDeckIdsByTermId);
  const termIdsInBothParts = [...generalDeckIdsByTermId.keys()].filter((termId) =>
    specializedDeckIdsByTermId.has(termId),
  );
  const termIdsInNoDeck = [...termsById.keys()].filter(
    (termId) => !generalDeckIdsByTermId.has(termId) && !specializedDeckIdsByTermId.has(termId),
  );

  console.log('\nTOTALS');
  console.log(
    `general: ${generalSlotCount} slots, ${generalDeckIdsByTermId.size} distinct, ` +
      `${generalSlotCount - generalDeckIdsByTermId.size} repeats`,
  );
  console.log(
    `specialized: ${specializedSlotCount} slots, ${specializedDeckIdsByTermId.size} distinct`,
  );
  console.log(`dictionary terms: ${termsById.size}`);
  console.log(`terms in both general and specialized: ${termIdsInBothParts.length}`);
  console.log(`terms in no deck: ${termIdsInNoDeck.length} ${termIdsInNoDeck.join(' ')}`);
}

function describeEntryShape(translationEntry) {
  if (translationEntry === undefined) return MISSING_ENTRY_SHAPE_LABEL;
  return Object.keys(translationEntry)
    .filter((entryKey) => entryKey !== TRANSLATION_NOTE_KEY)
    .sort()
    .join(ENTRY_SHAPE_KEY_SEPARATOR);
}

function printEntryShapeCounts(termsById, entriesByLanguage) {
  console.log('\nENTRY SHAPES (language, part of speech: shape=count)');
  for (const [languageCode, languageEntries] of entriesByLanguage) {
    const shapeCountsByPos = new Map();
    for (const term of termsById.values()) {
      const entryShape = describeEntryShape(languageEntries[term.id]);
      if (!shapeCountsByPos.has(term.pos)) shapeCountsByPos.set(term.pos, new Map());
      const shapeCounts = shapeCountsByPos.get(term.pos);
      shapeCounts.set(entryShape, (shapeCounts.get(entryShape) || 0) + 1);
    }
    const entryKeyCount = Object.keys(languageEntries).filter(
      (entryKey) => entryKey !== TRANSLATION_META_KEY,
    ).length;
    console.log(`${languageCode} (${entryKeyCount} entries)`);
    for (const [pos, shapeCounts] of [...shapeCountsByPos].sort()) {
      const shapeLabels = [...shapeCounts]
        .sort()
        .map(([entryShape, count]) => `${entryShape}=${count}`);
      console.log(`  ${pos}: ${shapeLabels.join(', ')}`);
    }
  }
}

// A stored rank agrees with its row when the row's lemma is one of the words
// of the term id (to_look_for / look, fish_animal / fish, how_much / much).
function doesTermIdContainLemma(termId, lemma) {
  return termId.split(TERM_ID_TOKEN_SEPARATOR).includes(lemma.toLowerCase());
}

function printRankRowComparison(termsById, frequencyRows) {
  const frequencyRowsByRank = new Map(frequencyRows.map((row) => [row.rank, row]));
  const rankedTerms = [...termsById.values()].filter((term) => term.cocaRank !== null);
  const differingLines = [];
  const rankedTermIdsByRank = new Map();
  for (const term of rankedTerms) {
    if (!rankedTermIdsByRank.has(term.cocaRank)) rankedTermIdsByRank.set(term.cocaRank, []);
    rankedTermIdsByRank.get(term.cocaRank).push(term.id);
    const frequencyRow = frequencyRowsByRank.get(term.cocaRank);
    if (frequencyRow === undefined) {
      differingLines.push(`${term.id} (${term.pos}) ${term.cocaRank} -> no such row`);
    } else if (!doesTermIdContainLemma(term.id, frequencyRow.lemma)) {
      differingLines.push(
        `${term.id} (${term.pos}) ${term.cocaRank} -> ${frequencyRow.lemma}/${frequencyRow.posCode}`,
      );
    }
  }
  const sharedRankLines = [...rankedTermIdsByRank]
    .filter(([, termIds]) => termIds.length > 1)
    .sort(([firstRank], [secondRank]) => firstRank - secondRank)
    .map(([rank, termIds]) => `${rank}: ${termIds.join(' ')}`);

  console.log('\nRANKS');
  console.log(`frequency rows: ${frequencyRows.length}`);
  console.log(`terms with rank: ${rankedTerms.length}, without: ${termsById.size - rankedTerms.length}`);
  console.log(`stored ranks whose row holds another lemma: ${differingLines.length}`);
  for (const differingLine of differingLines) console.log(`  ${differingLine}`);
  console.log(`ranks stored on more than one term: ${sharedRankLines.length}`);
  for (const sharedRankLine of sharedRankLines) console.log(`  ${sharedRankLine}`);
}

function printLevelInventory(dataDirectory) {
  const termsById = loadDictionaryTermsById(dataDirectory);
  const levelDeckStructure = loadLevelDeckStructure(dataDirectory);
  const levelTermMembership = collectLevelTermMembership(levelDeckStructure);
  printLevelDeckCounts(levelDeckStructure);
  printTermTotals(termsById, levelTermMembership);
  printEntryShapeCounts(termsById, loadTranslationEntriesByLanguage(dataDirectory));
  printRankRowComparison(termsById, loadFrequencyRowsInRankOrder(dataDirectory));
}

if (require.main === module) {
  printLevelInventory(process.argv[2] || DEFAULT_DATA_DIRECTORY);
}

module.exports = {
  DEFAULT_DATA_DIRECTORY,
  SPECIALIZED_LEVEL_ID,
  FIRST_GENERAL_LEVEL_ID,
  TERM_ID_TOKEN_SEPARATOR,
  TRANSLATION_META_KEY,
  loadDictionaryTermsById,
  loadLevelDeckStructure,
  loadFrequencyRowsInRankOrder,
  loadTranslationEntriesByLanguage,
  collectLevelTermMembership,
};
