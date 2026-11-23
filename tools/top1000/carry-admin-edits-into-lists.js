'use strict';

// Brings what was changed in the admin into the hand-kept lists, so that the
// word list and the drafts agree with the app before they are written into it
// again. Without this step write-app-data.js would overwrite the admin's work.
//   the layout    the app's general levels, their decks and the words of each
//                 deck, in the app's order, written as a decks seed for
//                 join-coca-with-dictionary.js (--decks-seed)
//   the entries   an entry of a drafted word that the app holds differently
//                 replaces the drafted one in app_data/words_<language>.json
// The names of the decks and the sets come from the word list: the admin
// changes neither.
//
// Nothing is written when the app holds a deck the word list has no name for,
// or other general levels than the word list. Whether the carried layout obeys
// the rules of the list is judged afterwards, by the list tool and the checker.
//
// Usage: node carry-admin-edits-into-lists.js --seed-out <txt> [--data <dir>]
//          [--lists <dir>]
//        node carry-admin-edits-into-lists.js --check-only [--data <dir>]
//          [--lists <dir>]
// With --check-only the differences are printed and nothing is written.

const fs = require('fs');
const path = require('path');
const inventory = require('./print-level-inventory.js');
const join = require('./join-coca-with-dictionary.js');
const writer = require('./write-app-data.js');

const { ListColumn } = join;

const DECKS_SEED_TERM_ID_SEPARATOR = ' ';
const SEED_LINE_ENDING = '\n';
const PRINTED_LINE_LIMIT = 40;
const REFUSED_EXIT_CODE = 1;
const CHECK_ONLY_FLAG = '--check-only';
const OPTION_KEY_BY_FLAG = Object.freeze({
  '--seed-out': 'seedOutPath',
  '--data': 'dataDirectory',
  '--lists': 'listsDirectory',
});

// ------------------------------------------------------------------- reading

// The general levels of the app, the decks of each and the words of each deck,
// in the order the app holds them.
function readLayoutOfApp(dataDirectory) {
  const structure = inventory.loadLevelDeckStructure(dataDirectory);
  const levels = structure.levels.filter((level) => level.id !== inventory.SPECIALIZED_LEVEL_ID);
  const termIdsByDeckId = new Map();
  for (const level of levels) {
    for (const deckId of level.deckIds) {
      termIdsByDeckId.set(deckId, structure.decksById.get(deckId).termIds);
    }
  }
  return { levels, termIdsByDeckId };
}

// The same layout as the word list holds it, with what only the list knows:
// the name of every deck and the words of every set.
function readLayoutOfWordList(listsDirectory) {
  const levels = [];
  const levelById = new Map();
  const termIdsByDeckId = new Map();
  const deckNameByDeckId = new Map();
  const termIdsBySetName = new Map();
  for (const record of join.readCsvRecords(path.join(listsDirectory, join.WORD_LIST_FILE_NAME))) {
    const levelId = record[ListColumn.level];
    const deckId = record[ListColumn.deckId];
    const setName = record[ListColumn.setName];
    if (!levelById.has(levelId)) {
      levelById.set(levelId, { id: levelId, deckIds: [] });
      levels.push(levelById.get(levelId));
    }
    if (!termIdsByDeckId.has(deckId)) {
      termIdsByDeckId.set(deckId, []);
      deckNameByDeckId.set(deckId, record[ListColumn.deckName]);
      levelById.get(levelId).deckIds.push(deckId);
    }
    termIdsByDeckId.get(deckId).push(record[ListColumn.termId]);
    if (setName !== '') {
      if (!termIdsBySetName.has(setName)) termIdsBySetName.set(setName, []);
      termIdsBySetName.get(setName).push(record[ListColumn.termId]);
    }
  }
  return { levels, termIdsByDeckId, deckNameByDeckId, termIdsBySetName };
}

// ----------------------------------------------------------------- comparing

// Says how the app's run of items differs from the list's: items only one
// side holds, or the same items in another order. Null when they agree.
function describeSequenceDifference(label, appItems, listItems) {
  const itemsOnlyInApp = appItems.filter((item) => !listItems.includes(item));
  const itemsOnlyInList = listItems.filter((item) => !appItems.includes(item));
  if (itemsOnlyInApp.length > 0 || itemsOnlyInList.length > 0) {
    const parts = [];
    if (itemsOnlyInApp.length > 0) parts.push(`the app adds ${itemsOnlyInApp.join(' ')}`);
    if (itemsOnlyInList.length > 0) parts.push(`the app lacks ${itemsOnlyInList.join(' ')}`);
    return `${label}: ${parts.join('; ')}`;
  }
  const standInSameOrder = appItems.every((item, itemIndex) => item === listItems[itemIndex]);
  return standInSameOrder ? null : `${label}: another order in the app (${appItems.join(' ')})`;
}

// What the app's layout holds otherwise than the word list, and what stops the
// layout from being carried at all.
function describeLayoutDifferences(appLayout, listLayout) {
  const differenceLines = [];
  const refusalLines = [];
  const recordDifference = (line) => {
    if (line !== null) differenceLines.push(line);
  };

  const appLevelIds = appLayout.levels.map((level) => level.id);
  const listLevelIds = listLayout.levels.map((level) => level.id);
  if (describeSequenceDifference('levels', appLevelIds, listLevelIds) !== null) {
    refusalLines.push(`the app's general levels are not those of the word list: ${appLevelIds.join(' ')}`);
  }

  const listLevelById = new Map(listLayout.levels.map((level) => [level.id, level]));
  for (const appLevel of appLayout.levels) {
    const listLevel = listLevelById.get(appLevel.id);
    recordDifference(
      describeSequenceDifference(`${appLevel.id} decks`, appLevel.deckIds, listLevel === undefined ? [] : listLevel.deckIds),
    );
    for (const deckId of appLevel.deckIds) {
      if (!listLayout.deckNameByDeckId.has(deckId)) {
        refusalLines.push(`deck "${deckId}" of the app has no name in the word list`);
        continue;
      }
      recordDifference(
        describeSequenceDifference(
          `${appLevel.id} deck ${deckId} words`,
          appLayout.termIdsByDeckId.get(deckId),
          listLayout.termIdsByDeckId.get(deckId),
        ),
      );
    }
  }
  return { differenceLines, refusalLines };
}

// ------------------------------------------------------------------ carrying

// The app's layout as a decks seed: the sets of the word list first, then one
// line per deck in the app's order.
function buildDecksSeedText(appLayout, listLayout) {
  const joinFields = (fields) => fields.join(join.DECKS_SEED_FIELD_SEPARATOR);
  const joinTermIds = (termIds) => termIds.join(DECKS_SEED_TERM_ID_SEPARATOR);
  const lines = [
    `${join.DECKS_SEED_COMMENT_PREFIX} the app's present layout, written by ${path.basename(__filename)}`,
  ];
  for (const [setName, termIds] of listLayout.termIdsBySetName) {
    lines.push(joinFields([join.DECKS_SEED_SET_LINE_TAG, setName, joinTermIds(termIds)]));
  }
  for (const level of appLayout.levels) {
    for (const deckId of level.deckIds) {
      lines.push(
        joinFields([
          level.id,
          deckId,
          listLayout.deckNameByDeckId.get(deckId),
          joinTermIds(appLayout.termIdsByDeckId.get(deckId)),
        ]),
      );
    }
  }
  return lines.join(SEED_LINE_ENDING) + SEED_LINE_ENDING;
}

// An entry as text that does not depend on the order of its keys.
function serializeEntryWithSortedKeys(value) {
  if (Array.isArray(value)) return `[${value.map(serializeEntryWithSortedKeys).join(',')}]`;
  if (value === null || typeof value !== 'object') return JSON.stringify(value);
  const keyedParts = Object.keys(value)
    .sort()
    .map((key) => `${JSON.stringify(key)}:${serializeEntryWithSortedKeys(value[key])}`);
  return `{${keyedParts.join(',')}}`;
}

// Gives every drafted word the entry the app holds, where the two differ.
// Returns the ids of the changed words per language.
function carryChangedEntriesIntoDrafts(dataDirectory, draftsDirectory, isCheckOnly) {
  const changedTermIdsByLanguage = new Map();
  for (const [languageCode, appEntries] of inventory.loadTranslationEntriesByLanguage(dataDirectory)) {
    const draftPath = writer.resolveWordDraftPath(draftsDirectory, languageCode);
    if (!fs.existsSync(draftPath)) continue;
    const draftEntries = writer.readJsonFile(draftPath);
    const changedTermIds = Object.keys(draftEntries).filter(
      (termId) =>
        termId in appEntries &&
        serializeEntryWithSortedKeys(appEntries[termId]) !== serializeEntryWithSortedKeys(draftEntries[termId]),
    );
    for (const termId of changedTermIds) draftEntries[termId] = appEntries[termId];
    if (changedTermIds.length > 0 && !isCheckOnly) writer.writeJsonFileInAppLayout(draftPath, draftEntries);
    changedTermIdsByLanguage.set(languageCode, changedTermIds);
  }
  return changedTermIdsByLanguage;
}

// ---------------------------------------------------------------------- main

function printLinesUpToLimit(lines) {
  for (const line of lines.slice(0, PRINTED_LINE_LIMIT)) console.log(`  ${line}`);
  if (lines.length > PRINTED_LINE_LIMIT) console.log(`  ... and ${lines.length - PRINTED_LINE_LIMIT} more`);
}

function parseCommandLineOptions(argumentList) {
  const options = {
    isCheckOnly: false,
    seedOutPath: null,
    dataDirectory: inventory.DEFAULT_DATA_DIRECTORY,
    listsDirectory: join.DEFAULT_LISTS_DIRECTORY,
  };
  for (let index = 0; index < argumentList.length; index += 1) {
    const flag = argumentList[index];
    if (flag === CHECK_ONLY_FLAG) {
      options.isCheckOnly = true;
      continue;
    }
    const optionKey = OPTION_KEY_BY_FLAG[flag];
    if (optionKey === undefined || argumentList[index + 1] === undefined) {
      throw new Error(`unknown or incomplete option "${flag}"`);
    }
    options[optionKey] = argumentList[index + 1];
    index += 1;
  }
  if (!options.isCheckOnly && options.seedOutPath === null) {
    throw new Error(`a seed file to write is required (--seed-out <txt>) unless ${CHECK_ONLY_FLAG} is given`);
  }
  return options;
}

function carryAdminEditsIntoLists(options) {
  const appLayout = readLayoutOfApp(options.dataDirectory);
  const listLayout = readLayoutOfWordList(options.listsDirectory);
  const { differenceLines, refusalLines } = describeLayoutDifferences(appLayout, listLayout);

  console.log(`layout: ${differenceLines.length} differences between the app and the word list`);
  printLinesUpToLimit(differenceLines);
  if (refusalLines.length > 0) {
    console.log(`CANNOT BE CARRIED (${refusalLines.length}):`);
    printLinesUpToLimit(refusalLines);
    process.exitCode = REFUSED_EXIT_CODE;
    return;
  }

  const changedTermIdsByLanguage = carryChangedEntriesIntoDrafts(
    options.dataDirectory,
    path.join(options.listsDirectory, writer.DRAFTS_DIRECTORY_NAME),
    options.isCheckOnly,
  );
  for (const [languageCode, changedTermIds] of changedTermIdsByLanguage) {
    const shownTermIds = changedTermIds.length === 0 ? '' : ` (${changedTermIds.join(' ')})`;
    console.log(`${languageCode}: entries the app holds otherwise than the drafts: ${changedTermIds.length}${shownTermIds}`);
  }

  if (options.isCheckOnly) {
    console.log('NOTHING WRITTEN (check only)');
    return;
  }
  fs.writeFileSync(options.seedOutPath, buildDecksSeedText(appLayout, listLayout), 'utf8');
  console.log(`layout written as a decks seed: ${options.seedOutPath}`);
}

if (require.main === module) {
  carryAdminEditsIntoLists(parseCommandLineOptions(process.argv.slice(2)));
}
