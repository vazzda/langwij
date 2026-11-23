'use strict';

// Checks the review lists of this folder against the rules of the word list
// and prints PASS or FAIL per rule. Reads only; writes nothing.
// Exit code 1 when a rule fails.
//
// "The present app" of the rules is the app as it stood before the list was
// written into it: the stored copy the list tool reads as well.
//
// Usage: node check-word-list-rules.js [earlierAppDirectory] [listsDirectory]

const path = require('path');
const inventory = require('./print-level-inventory.js');
const join = require('./join-coca-with-dictionary.js');

const { ListColumn, RowMark, WordStatus, AdditionDecision } = join;

const FIRST_LEVEL_DECK_COUNT = 5;
const FIRST_LEVEL_DECK_WORD_COUNT = 20;
const LATER_LEVEL_DECK_COUNT_RANGE = Object.freeze({ min: 5, max: 10 });
const DECK_WORD_COUNT_RANGE = Object.freeze({ min: 10, max: 20 });
const AGREED_REPEAT_COUNT = 24;
const FAILED_RULE_EXIT_CODE = 1;
const MISSING_DECK_LABEL = '(no deck)';

class RuleCheckReport {
  #failedRuleCount = 0;

  recordRuleResult(ruleName, failureMessages) {
    if (failureMessages.length === 0) {
      console.log(`PASS  ${ruleName}`);
      return;
    }
    this.#failedRuleCount += 1;
    console.log(`FAIL  ${ruleName}`);
    for (const failureMessage of failureMessages) console.log(`        ${failureMessage}`);
  }

  get hasFailedRules() {
    return this.#failedRuleCount > 0;
  }
}

function groupRecordsByColumn(records, columnName) {
  const recordsByValue = new Map();
  for (const record of records) {
    const value = record[columnName];
    if (!recordsByValue.has(value)) recordsByValue.set(value, []);
    recordsByValue.get(value).push(record);
  }
  return recordsByValue;
}

function isWithinRange(value, range) {
  return value >= range.min && value <= range.max;
}

// The second row of a Top 100 word, in the deck of its set.
function isRepeatRow(wordListRecord) {
  return wordListRecord.status === WordStatus.repeated;
}

// A row that a named set gathers into its deck.
function isSetRow(wordListRecord) {
  return wordListRecord.set !== '';
}

function collectTermIdsOfWordList(wordListRecords) {
  return new Set(wordListRecords.map((record) => record.term_id));
}

// ------------------------------------------------------------ shape of levels

function checkCardCountOfEveryLevel(wordListRecords, generalLevelIds) {
  const failureMessages = [];
  const recordsByLevel = groupRecordsByColumn(wordListRecords, ListColumn.level);
  for (const levelId of generalLevelIds) {
    const levelCardCount = (recordsByLevel.get(levelId) || []).length;
    if (levelCardCount !== join.LEVEL_WORD_COUNT) {
      failureMessages.push(`${levelId} holds ${levelCardCount} cards`);
    }
  }
  for (const levelId of recordsByLevel.keys()) {
    if (!generalLevelIds.includes(levelId)) failureMessages.push(`unknown level "${levelId}"`);
  }
  return failureMessages;
}

// A word has one row. A Top 100 word repeated inside a set has a second one,
// in a later level.
function checkEveryWordIsUsedOnceOrRepeated(wordListRecords, firstLevelId) {
  const failureMessages = [];
  for (const [termId, termRecords] of groupRecordsByColumn(wordListRecords, ListColumn.termId)) {
    const homeRecords = termRecords.filter((record) => !isRepeatRow(record));
    const repeatRecords = termRecords.filter(isRepeatRow);
    if (homeRecords.length !== 1) {
      failureMessages.push(`"${termId}" appears ${homeRecords.length} times outside a repeat`);
      continue;
    }
    if (repeatRecords.length > join.MAX_REPEATS_PER_WORD) {
      failureMessages.push(`"${termId}" is repeated ${repeatRecords.length} times`);
    }
    for (const repeatRecord of repeatRecords) {
      const isRepeatOfFirstLevelWord =
        homeRecords[0].level === firstLevelId && repeatRecord.level !== firstLevelId;
      if (!isRepeatOfFirstLevelWord) {
        failureMessages.push(`"${termId}" is repeated, but not from ${firstLevelId} into a later level`);
      }
      if (!isSetRow(repeatRecord)) failureMessages.push(`"${termId}" is repeated outside a set`);
    }
  }
  return failureMessages;
}

function checkEveryWordHasDeck(wordListRecords) {
  return wordListRecords
    .filter((record) => record.deck_id === '' || record.deck_name === '')
    .map((record) => `"${record.term_id}" has no deck`);
}

function checkEveryDeckHasOneNameAndOneLevel(wordListRecords) {
  const failureMessages = [];
  for (const [deckId, deckRecords] of groupRecordsByColumn(wordListRecords, ListColumn.deckId)) {
    if (deckId === '') continue;
    const deckNames = new Set(deckRecords.map((record) => record.deck_name));
    const deckLevels = new Set(deckRecords.map((record) => record.level));
    if (deckNames.size > 1) failureMessages.push(`deck "${deckId}" has ${deckNames.size} names`);
    if (deckLevels.size > 1) failureMessages.push(`deck "${deckId}" sits in ${deckLevels.size} levels`);
  }
  return failureMessages;
}

function checkDeckSizesOfEveryLevel(wordListRecords, generalLevelIds) {
  const failureMessages = [];
  const recordsByLevel = groupRecordsByColumn(wordListRecords, ListColumn.level);
  generalLevelIds.forEach((levelId, levelIndex) => {
    const recordsByDeck = groupRecordsByColumn(recordsByLevel.get(levelId) || [], ListColumn.deckId);
    recordsByDeck.delete('');
    const isFirstLevel = levelIndex === 0;
    const hasAllowedDeckCount = isFirstLevel
      ? recordsByDeck.size === FIRST_LEVEL_DECK_COUNT
      : isWithinRange(recordsByDeck.size, LATER_LEVEL_DECK_COUNT_RANGE);
    if (!hasAllowedDeckCount) failureMessages.push(`${levelId} has ${recordsByDeck.size} decks`);
    for (const [deckId, deckRecords] of recordsByDeck) {
      const hasAllowedWordCount = isFirstLevel
        ? deckRecords.length === FIRST_LEVEL_DECK_WORD_COUNT
        : isWithinRange(deckRecords.length, DECK_WORD_COUNT_RANGE);
      if (!hasAllowedWordCount) {
        failureMessages.push(`${levelId} deck "${deckId}" holds ${deckRecords.length} words`);
      }
    }
  });
  return failureMessages;
}

// A word that holds a frequency row is the card of that row in the ranking
// list, in the same level; and the ranking list places no word the word list lacks.
function checkAgreementWithRankingList(wordListRecords, rankingRecords) {
  const failureMessages = [];
  const cardRecordsByTermId = new Map(
    rankingRecords.filter((record) => record.mark === RowMark.card).map((record) => [record.term_id, record]),
  );
  const homeRecords = wordListRecords.filter((record) => !isRepeatRow(record));
  for (const record of homeRecords) {
    if (record.rank === '') continue;
    const cardRecord = cardRecordsByTermId.get(record.term_id);
    if (cardRecord === undefined || cardRecord.rank !== record.rank) {
      failureMessages.push(`"${record.term_id}" is not the card of row ${record.rank} in the ranking list`);
    } else if (cardRecord.level !== record.level) {
      failureMessages.push(
        `"${record.term_id}" sits in ${record.level} here, in "${cardRecord.level}" in the ranking list`,
      );
    }
  }
  const homeLevelByTermId = new Map(homeRecords.map((record) => [record.term_id, record.level]));
  for (const cardRecord of cardRecordsByTermId.values()) {
    if (cardRecord.level !== '' && homeLevelByTermId.get(cardRecord.term_id) !== cardRecord.level) {
      failureMessages.push(`"${cardRecord.term_id}" is placed by the ranking list only`);
    }
  }
  return failureMessages;
}

// A set is gathered into one deck of a later level.
function checkRowsOfEverySetShareOneDeck(wordListRecords, firstLevelId) {
  const failureMessages = [];
  const setRecordsBySetName = groupRecordsByColumn(wordListRecords.filter(isSetRow), ListColumn.setName);
  for (const [setName, setRecords] of setRecordsBySetName) {
    const deckIds = new Set(setRecords.map((record) => record.deck_id));
    if (deckIds.size > 1 || deckIds.has('')) {
      const deckLabels = [...deckIds].map((deckId) => deckId || MISSING_DECK_LABEL);
      failureMessages.push(`set "${setName}" is spread over ${deckLabels.join(', ')}`);
    }
    if (setRecords.some((record) => record.level === firstLevelId)) {
      failureMessages.push(`set "${setName}" has rows in ${firstLevelId}`);
    }
  }
  return failureMessages;
}

// --------------------------------------------------------- the three sources

// No present general word may fall out, and a present Top 100 word stays in Top 100.
function checkEveryPresentWordIsKept(wordListRecords, levelTermMembership, firstLevelId) {
  const failureMessages = [];
  const termIdsOfWordList = collectTermIdsOfWordList(wordListRecords);
  const termIdsOfFirstLevel = collectTermIdsOfWordList(
    wordListRecords.filter((record) => record.level === firstLevelId),
  );
  for (const termId of levelTermMembership.generalDeckIdsByTermId.keys()) {
    if (!termIdsOfWordList.has(termId)) failureMessages.push(`"${termId}" fell out of the word list`);
  }
  for (const termId of levelTermMembership.firstLevelTermIds) {
    if (termIdsOfWordList.has(termId) && !termIdsOfFirstLevel.has(termId)) {
      failureMessages.push(`"${termId}" left ${firstLevelId}`);
    }
  }
  return failureMessages;
}

// A word that the app's general levels do not hold must be named by the additions list.
function checkEveryOtherWordIsNamedByAdditions(wordListRecords, presentGeneralTermIds, additionRecords) {
  const additionTermIds = new Set(additionRecords.map((additionRecord) => additionRecord.termId));
  return [...collectTermIdsOfWordList(wordListRecords)]
    .filter((termId) => !presentGeneralTermIds.has(termId) && !additionTermIds.has(termId))
    .map((termId) => `"${termId}" comes from neither the app nor the additions list`);
}

function checkAdditionDecisionsAreFollowed(wordListRecords, additionRecords) {
  const failureMessages = [];
  const termIdsOfWordList = collectTermIdsOfWordList(wordListRecords);
  for (const additionRecord of additionRecords) {
    const isPlaced = termIdsOfWordList.has(additionRecord.termId);
    const isEntering = additionRecord.decision === AdditionDecision.enter;
    if (isEntering && !isPlaced) failureMessages.push(`"${additionRecord.termId}" enters but is not placed`);
    if (!isEntering && isPlaced) failureMessages.push(`"${additionRecord.termId}" waits but is placed`);
  }
  return failureMessages;
}

function checkRepeatCountIsTheAgreedOne(wordListRecords) {
  const repeatCount = wordListRecords.filter(isRepeatRow).length;
  return repeatCount === AGREED_REPEAT_COUNT ? [] : [`the list holds ${repeatCount} repeats`];
}

// --------------------------------------------------------------- deck id rule

function collectTermIdsByDeckId(wordListRecords) {
  const termIdsByDeckId = new Map();
  for (const record of wordListRecords) {
    if (record.deck_id === '') continue;
    if (!termIdsByDeckId.has(record.deck_id)) termIdsByDeckId.set(record.deck_id, new Set());
    termIdsByDeckId.get(record.deck_id).add(record.term_id);
  }
  return termIdsByDeckId;
}

// A deck keeps a present id only when no word leaves it; every other deck
// needs a new id.
function findDecksKeepingPresentId(termIdsByDeckId, presentDecksById) {
  const keptDeckIds = [];
  const failureMessages = [];
  for (const [deckId, newTermIds] of termIdsByDeckId) {
    const presentDeck = presentDecksById.get(deckId);
    if (presentDeck === undefined) continue;
    const lostTermIds = presentDeck.termIds.filter((termId) => !newTermIds.has(termId));
    if (lostTermIds.length === 0) {
      keptDeckIds.push(deckId);
    } else {
      failureMessages.push(`deck "${deckId}" keeps a present id but loses ${lostTermIds.join(' ')}`);
    }
  }
  return { keptDeckIds, failureMessages };
}

// -------------------------------------------------------------------- summary

// A present word shows its present level as its source; counts those that now sit elsewhere.
function countPresentWordsThatChangedLevel(wordListRecords) {
  return wordListRecords.filter(
    (record) => record.status === WordStatus.kept && record.source !== record.level,
  ).length;
}

function printListSummary(wordListRecords, keptDeckIds) {
  const countByStatus = new Map();
  for (const record of wordListRecords) {
    countByStatus.set(record.status, (countByStatus.get(record.status) || 0) + 1);
  }
  const statusLabels = [...countByStatus].sort().map(([status, count]) => `${status} ${count}`);
  const setRecords = wordListRecords.filter(isSetRow);
  const setCount = new Set(setRecords.map((record) => record.set)).size;
  const gatheredWordCount = setRecords.filter((record) => !isRepeatRow(record)).length;
  const deckCount = new Set(wordListRecords.map((record) => record.deck_id)).size;
  console.log('\nSUMMARY');
  console.log(`cards in the list: ${wordListRecords.length} (${statusLabels.join(', ')})`);
  console.log(
    `distinct words: ${collectTermIdsOfWordList(wordListRecords).size}; sets: ${setCount}; ` +
      `words gathered by sets: ${gatheredWordCount}`,
  );
  console.log(
    `present words that changed level: ${countPresentWordsThatChangedLevel(wordListRecords)} of ` +
      `${countByStatus.get(WordStatus.kept) || 0}`,
  );
  console.log(`decks: ${deckCount}`);
  console.log(`decks that keep their id: ${keptDeckIds.length} ${keptDeckIds.join(' ')}`);
}

function checkWordListRules(earlierAppDirectory, listsDirectory) {
  const levelDeckStructure = inventory.loadLevelDeckStructure(earlierAppDirectory);
  const levelTermMembership = inventory.collectLevelTermMembership(levelDeckStructure);
  const presentGeneralTermIds = new Set(levelTermMembership.generalDeckIdsByTermId.keys());
  const generalLevelIds = join.buildGeneralLevelIds();
  const firstLevelId = generalLevelIds[0];
  const wordListRecords = join.readCsvRecords(path.join(listsDirectory, join.WORD_LIST_FILE_NAME));
  const rankingRecords = join.readCsvRecords(path.join(listsDirectory, join.RANKING_LIST_FILE_NAME));
  const additionRecords = join.loadAdditionRecords(path.join(listsDirectory, join.ADDITIONS_LIST_FILE_NAME));
  const keptDeckFindings = findDecksKeepingPresentId(
    collectTermIdsByDeckId(wordListRecords),
    levelDeckStructure.decksById,
  );

  const report = new RuleCheckReport();
  report.recordRuleResult(
    `every level holds ${join.LEVEL_WORD_COUNT} cards`,
    checkCardCountOfEveryLevel(wordListRecords, generalLevelIds),
  );
  report.recordRuleResult(
    'every word is used once, or twice when a set repeats a Top 100 word',
    checkEveryWordIsUsedOnceOrRepeated(wordListRecords, firstLevelId),
  );
  report.recordRuleResult('every word has a deck', checkEveryWordHasDeck(wordListRecords));
  report.recordRuleResult(
    'every deck has one name and one level',
    checkEveryDeckHasOneNameAndOneLevel(wordListRecords),
  );
  report.recordRuleResult(
    `Top 100 is ${FIRST_LEVEL_DECK_COUNT} decks of ${FIRST_LEVEL_DECK_WORD_COUNT}; other levels are ` +
      `${LATER_LEVEL_DECK_COUNT_RANGE.min}-${LATER_LEVEL_DECK_COUNT_RANGE.max} decks of ` +
      `${DECK_WORD_COUNT_RANGE.min}-${DECK_WORD_COUNT_RANGE.max}`,
    checkDeckSizesOfEveryLevel(wordListRecords, generalLevelIds),
  );
  report.recordRuleResult(
    'the word list agrees with the ranking list',
    checkAgreementWithRankingList(wordListRecords, rankingRecords),
  );
  report.recordRuleResult(
    'the rows of every set share one deck of a later level',
    checkRowsOfEverySetShareOneDeck(wordListRecords, firstLevelId),
  );
  report.recordRuleResult(
    'every present general word is in the word list, the present Top 100 words in Top 100',
    checkEveryPresentWordIsKept(wordListRecords, levelTermMembership, firstLevelId),
  );
  report.recordRuleResult(
    'every other word is named by the additions list',
    checkEveryOtherWordIsNamedByAdditions(wordListRecords, presentGeneralTermIds, additionRecords),
  );
  report.recordRuleResult(
    'every entering word of the additions list is placed, and no waiting word is',
    checkAdditionDecisionsAreFollowed(wordListRecords, additionRecords),
  );
  report.recordRuleResult(
    `exactly ${AGREED_REPEAT_COUNT} Top 100 words are repeated`,
    checkRepeatCountIsTheAgreedOne(wordListRecords),
  );
  report.recordRuleResult(
    'a deck keeps a present id only when no word leaves it',
    keptDeckFindings.failureMessages,
  );

  printListSummary(wordListRecords, keptDeckFindings.keptDeckIds);
  if (report.hasFailedRules) process.exitCode = FAILED_RULE_EXIT_CODE;
}

if (require.main === module) {
  checkWordListRules(
    process.argv[2] || join.DEFAULT_EARLIER_APP_DIRECTORY,
    process.argv[3] || join.DEFAULT_LISTS_DIRECTORY,
  );
}
