'use strict';

// Builds the word list of the general levels from three sources only:
//   the app's present general words   every one of them stays in the levels
//   additions.csv                     the new words, kept by hand; a row either
//                                     enters the list or waits in the reserve
//   the repeats                       Top 100 words shown a second time in the
//                                     deck of their set
// The frequency rank admits and refuses nothing; it is shown beside each word.
//
// "The app's present words" are the words the app held before this list was
// written into it. Since then the live data is the list's own output, so they
// are read from a stored copy of the earlier app: app_before_list/ beside this
// script, or --before <dir>. Only the frequency file is read from the live
// data (--data <dir>).
//
// Lists beside this script:
//   additions.csv          read only: source, word id, rank of its frequency
//                          row, "enter" or "reserve", note; a word without a
//                          frequency row carries its English text and part of speech
//   candidate_ranking.csv  the record of how each frequency row maps to a word
//   word_list.csv          the cards, level by level and deck by deck
//   coca_words_outside_app.csv
//                          the words of the commonest frequency rows that hold
//                          no card in the word list, each with the reason;
//                          derived on every run, never read back
//
// Every deck is placed in its level by hand: a word listed in a deck sits in
// that deck's level, in the order the deck lists it. A word no deck lists yet
// fills a free seat in source order. A named set keeps its words in one deck;
// its Top 100 members appear there a second time (status "repeat").
//
// Columns filled by hand are kept on every run: the marks of the ranking list
// (lines whose mark_by is "hand"), and the deck and set columns of the word
// list. A seed file replaces the hand columns in one batch.
//
// Decks seed, one line per deck or per set ("#" starts a comment):
//   <level>|<deck id>|<deck name>|<term ids>
//   set|<set name>|<term ids>
//
// Usage: node join-coca-with-dictionary.js [--data <dir>] [--before <dir>]
//          [--lists <dir>] [--marks-seed <csv>] [--decks-seed <txt>]
//          [--print <section>]

const fs = require('fs');
const path = require('path');
const inventory = require('./print-level-inventory.js');

const DEFAULT_LISTS_DIRECTORY = __dirname;
// The stored copy of the app's data from before the list was written into it.
const DEFAULT_EARLIER_APP_DIRECTORY = path.join(__dirname, 'app_before_list');
const RANKING_LIST_FILE_NAME = 'candidate_ranking.csv';
const WORD_LIST_FILE_NAME = 'word_list.csv';
const ADDITIONS_LIST_FILE_NAME = 'additions.csv';
const OUTSIDE_LIST_FILE_NAME = 'coca_words_outside_app.csv';
const ENGLISH_LANGUAGE_CODE = 'en';

const LEVEL_WORD_COUNT = 100;
// The ladder of the learner's progress: each segment holds a run of levels,
// in this order. The number of general levels is the sum of the ladder.
const SEGMENT_LADDER = Object.freeze([
  Object.freeze({ id: 'survival', levelCount: 1 }),
  Object.freeze({ id: 'baby', levelCount: 3 }),
  Object.freeze({ id: 'kid', levelCount: 7 }),
  Object.freeze({ id: 'adult', levelCount: 14 }),
]);
const GENERAL_LEVEL_COUNT = SEGMENT_LADDER.reduce(
  (levelCount, segment) => levelCount + segment.levelCount,
  0,
);
const GENERAL_LEVEL_ID_PREFIX = 'top';
const MAX_REPEATS_PER_WORD = 1;
// The outside list looks at as many frequency rows as the word list has cards.
const OUTSIDE_LIST_RANK_LIMIT = LEVEL_WORD_COUNT * GENERAL_LEVEL_COUNT;

const RowMark = Object.freeze({
  card: 'card',
  skipped: 'skipped',
  merged: 'merged',
  borrowed: 'borrowed',
});
const MarkSource = Object.freeze({ hand: 'hand', rule: 'rule' });
const WordStatus = Object.freeze({ kept: 'kept', shared: 'shared', added: 'new', repeated: 'repeat' });
const AdditionDecision = Object.freeze({ enter: 'enter', reserve: 'reserve' });
// Why a word of the commonest frequency rows holds no card in the word list.
const OutsideReason = Object.freeze({
  waiting: 'waits in the reserve',
  specializedOnly: 'only in a Specialized deck',
  inNeitherSource: 'in neither the app nor the additions list',
  leftOutByHand: 'left out by hand',
  withoutCardForm: 'no card form',
});
const PrintSection = Object.freeze({
  levels: 'levels',
  sets: 'sets',
  reserve: 'reserve',
});

const DictionaryPos = Object.freeze({
  verb: 'verb',
  noun: 'noun',
  adjective: 'adjective',
  adverb: 'adverb',
  pronoun: 'pronoun',
  conjunction: 'conjunction',
  preposition: 'preposition',
  numeral: 'numeral',
  phrase: 'phrase',
  interrogative: 'interrogative',
});
const DICTIONARY_POS_BY_FREQUENCY_CODE = Object.freeze({
  v: DictionaryPos.verb,
  n: DictionaryPos.noun,
  j: DictionaryPos.adjective,
  r: DictionaryPos.adverb,
  c: DictionaryPos.conjunction,
  i: DictionaryPos.preposition,
  m: DictionaryPos.numeral,
  p: DictionaryPos.pronoun,
  d: DictionaryPos.pronoun,
  a: DictionaryPos.pronoun,
  u: DictionaryPos.phrase,
  x: DictionaryPos.adverb,
  e: DictionaryPos.adverb,
  t: DictionaryPos.preposition,
});
const FUNCTION_WORD_POS_VALUES = new Set([
  DictionaryPos.adverb,
  DictionaryPos.pronoun,
  DictionaryPos.conjunction,
  DictionaryPos.preposition,
  DictionaryPos.numeral,
  DictionaryPos.phrase,
  DictionaryPos.interrogative,
]);
const TERM_ID_SUFFIX_BY_POS = Object.freeze({
  [DictionaryPos.noun]: '_n',
  [DictionaryPos.adjective]: '_a',
  [DictionaryPos.adverb]: '_adv',
  [DictionaryPos.pronoun]: '_pron',
  [DictionaryPos.conjunction]: '_conj',
  [DictionaryPos.preposition]: '_prep',
  [DictionaryPos.numeral]: '_num',
  [DictionaryPos.phrase]: '_phrase',
});
const VERB_TERM_ID_PREFIX = 'to_';
const VERB_ENGLISH_PREFIX = 'to ';

const RULE_DETAIL_UNKNOWN_POS_CODE = 'part-of-speech code has no card form';
const RULE_DETAIL_TIED_BY_NAME = 'no stored rank; tied by name';
const RULE_DETAIL_PLACED_BY_HAND_PREFIX = 'placed by hand at rank ';
const SET_MEMBER_LABEL_OUTSIDE_SET_DECK = 'outside the deck of its set';

// The column names of the three lists, for every place that passes a name on.
const ListColumn = Object.freeze({
  rank: 'rank',
  lemma: 'lemma',
  posCode: 'pos_code',
  mark: 'mark',
  markBy: 'mark_by',
  detail: 'detail',
  termId: 'term_id',
  english: 'english',
  pos: 'pos',
  status: 'status',
  segment: 'segment',
  level: 'level',
  deckId: 'deck_id',
  deckName: 'deck_name',
  source: 'source',
  setName: 'set',
  note: 'note',
  reason: 'reason',
});
const RANKING_LIST_COLUMNS = Object.freeze([
  ListColumn.rank, ListColumn.lemma, ListColumn.posCode, ListColumn.mark, ListColumn.markBy,
  ListColumn.detail, ListColumn.termId, ListColumn.english, ListColumn.pos, ListColumn.status,
  ListColumn.level,
]);
const WORD_LIST_COLUMNS = Object.freeze([
  ListColumn.segment, ListColumn.level, ListColumn.deckId, ListColumn.deckName, ListColumn.termId, ListColumn.english,
  ListColumn.pos, ListColumn.rank, ListColumn.source, ListColumn.status, ListColumn.setName,
  ListColumn.note,
]);
const OUTSIDE_LIST_COLUMNS = Object.freeze([
  ListColumn.rank, ListColumn.lemma, ListColumn.posCode, ListColumn.termId, ListColumn.english,
  ListColumn.pos, ListColumn.reason, ListColumn.note,
]);
const DECKS_SEED_FIELD_SEPARATOR = '|';
const DECKS_SEED_DECK_FIELD_COUNT = 4;
const DECKS_SEED_SET_FIELD_COUNT = 3;
const DECKS_SEED_SET_LINE_TAG = 'set';
const DECKS_SEED_COMMENT_PREFIX = '#';
const COMPACT_PRINT_SEPARATOR = '  ';

// ---------------------------------------------------------------- CSV files

function formatCsvField(value) {
  const text = value === null || value === undefined ? '' : String(value);
  return /[",\r\n]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
}

function writeCsvRecords(filePath, columnNames, records) {
  const lines = [columnNames.join(',')];
  for (const record of records) {
    lines.push(columnNames.map((columnName) => formatCsvField(record[columnName])).join(','));
  }
  fs.writeFileSync(filePath, `${lines.join('\n')}\n`, 'utf8');
}

function parseCsvLine(line) {
  const fields = [];
  let field = '';
  let isInsideQuotes = false;
  for (let index = 0; index < line.length; index += 1) {
    const character = line[index];
    if (isInsideQuotes) {
      if (character === '"' && line[index + 1] === '"') {
        field += '"';
        index += 1;
      } else if (character === '"') {
        isInsideQuotes = false;
      } else {
        field += character;
      }
    } else if (character === '"') {
      isInsideQuotes = true;
    } else if (character === ',') {
      fields.push(field);
      field = '';
    } else {
      field += character;
    }
  }
  fields.push(field);
  return fields;
}

// Returns the rows of a CSV file as objects keyed by column name; an absent file has no rows.
function readCsvRecords(filePath) {
  if (!fs.existsSync(filePath)) return [];
  const lines = fs
    .readFileSync(filePath, 'utf8')
    .split(/\r?\n/)
    .filter((line) => line.length > 0);
  if (lines.length === 0) return [];
  const columnNames = parseCsvLine(lines[0]);
  return lines.slice(1).map((line) => {
    const fields = parseCsvLine(line);
    const record = {};
    columnNames.forEach((columnName, index) => {
      record[columnName] = fields[index] === undefined ? '' : fields[index];
    });
    return record;
  });
}

// ------------------------------------------------------------ level helpers

function buildGeneralLevelIds() {
  return Array.from(
    { length: GENERAL_LEVEL_COUNT },
    (_, levelIndex) => `${GENERAL_LEVEL_ID_PREFIX}${(levelIndex + 1) * LEVEL_WORD_COUNT}`,
  );
}

// The segment of every general level, read off the ladder.
function buildSegmentIdByLevelId(generalLevelIds) {
  const segmentIdByLevelId = new Map();
  let levelIndex = 0;
  for (const segment of SEGMENT_LADDER) {
    for (let levelOfSegment = 0; levelOfSegment < segment.levelCount; levelOfSegment += 1) {
      segmentIdByLevelId.set(generalLevelIds[levelIndex], segment.id);
      levelIndex += 1;
    }
  }
  return segmentIdByLevelId;
}

function resolveWordStatus(termId, levelTermMembership) {
  if (levelTermMembership.generalDeckIdsByTermId.has(termId)) return WordStatus.kept;
  if (levelTermMembership.specializedDeckIdsByTermId.has(termId)) return WordStatus.shared;
  return WordStatus.added;
}

// ------------------------------------------------------------- hand columns

// Hand marks keyed by rank: the "hand" lines of the present ranking list,
// replaced as a whole by the seed file when one is given.
function loadHandMarkLinesByRank(rankingListPath, marksSeedPath) {
  const handRecords = marksSeedPath
    ? readCsvRecords(marksSeedPath)
    : readCsvRecords(rankingListPath).filter((record) => record.mark_by === MarkSource.hand);
  const handLinesByRank = new Map();
  for (const record of handRecords) {
    const rank = Number(record.rank);
    if (!Object.values(RowMark).includes(record.mark)) {
      throw new Error(`hand mark at rank ${record.rank}: unknown mark "${record.mark}"`);
    }
    if (!handLinesByRank.has(rank)) handLinesByRank.set(rank, []);
    handLinesByRank.get(rank).push({
      rank,
      mark: record.mark,
      detail: record.detail,
      termId: record.term_id,
      english: record.english || '',
    });
  }
  return handLinesByRank;
}

// Present terms that a hand mark places on another row than their stored rank.
function collectHandTiedRanksByTermId(handLinesByRank, termsById) {
  const handTiedRanksByTermId = new Map();
  for (const handLines of handLinesByRank.values()) {
    for (const handLine of handLines) {
      const presentTerm = termsById.get(handLine.termId);
      const isTieToAnotherRow =
        handLine.mark === RowMark.card &&
        presentTerm !== undefined &&
        presentTerm.cocaRank !== handLine.rank;
      if (isTieToAnotherRow) handTiedRanksByTermId.set(handLine.termId, handLine.rank);
    }
  }
  return handTiedRanksByTermId;
}

// The decks and sets made by hand: which decks list which words, and which
// words belong to a named set. A word sits in one deck; only a Top 100 word may
// be listed a second time, in a deck of a later level, where it is repeated.
class HandDeckLayout {
  #generalLevelIds;
  #deckPlacesByTermId = new Map();
  #deckOrderByDeckId = new Map();
  #setNameByTermId = new Map();
  #listedWordCount = 0;

  constructor(generalLevelIds) {
    this.#generalLevelIds = generalLevelIds;
  }

  listWordInDeck(termId, levelId, deckId, deckName) {
    if (!this.#generalLevelIds.includes(levelId)) {
      throw new Error(`hand layout: deck "${deckId}" names the unknown level "${levelId}"`);
    }
    const deckPlaces = this.#deckPlacesByTermId.get(termId) || [];
    if (deckPlaces.length > 0 && !this.#isRepeatOfFirstLevelWord(deckPlaces, levelId)) {
      const deckIds = [...deckPlaces.map((deckPlace) => deckPlace.deckId), deckId];
      throw new Error(`hand layout: "${termId}" sits in more decks than allowed (${deckIds.join(', ')})`);
    }
    if (!this.#deckOrderByDeckId.has(deckId)) {
      this.#deckOrderByDeckId.set(deckId, this.#deckOrderByDeckId.size);
    }
    deckPlaces.push({
      levelId,
      deckId,
      deckName,
      deckOrder: this.#deckOrderByDeckId.get(deckId),
      wordOrder: this.#listedWordCount,
    });
    this.#listedWordCount += 1;
    this.#deckPlacesByTermId.set(termId, deckPlaces);
  }

  nameSetOfWord(termId, setName) {
    const knownSetName = this.#setNameByTermId.get(termId);
    if (knownSetName !== undefined && knownSetName !== setName) {
      throw new Error(`hand layout: "${termId}" belongs to two sets (${knownSetName}, ${setName})`);
    }
    this.#setNameByTermId.set(termId, setName);
  }

  findDeckPlaceInLevel(termId, levelId) {
    return (this.#deckPlacesByTermId.get(termId) || []).find(
      (deckPlace) => deckPlace.levelId === levelId,
    );
  }

  // The deck places of a word, in the order the decks list it.
  findDeckPlacesOfWord(termId) {
    return this.#deckPlacesByTermId.get(termId) || [];
  }

  // The name of the set a word belongs to; empty when it belongs to none.
  findSetNameOfWord(termId) {
    return this.#setNameByTermId.get(termId) || '';
  }

  collectTermIdsBySetName() {
    const termIdsBySetName = new Map();
    for (const [termId, setName] of this.#setNameByTermId) {
      if (!termIdsBySetName.has(setName)) termIdsBySetName.set(setName, []);
      termIdsBySetName.get(setName).push(termId);
    }
    return termIdsBySetName;
  }

  collectListedTermIds() {
    return new Set([...this.#deckPlacesByTermId.keys(), ...this.#setNameByTermId.keys()]);
  }

  #isRepeatOfFirstLevelWord(deckPlaces, newLevelId) {
    const levelIdsOfWord = [...deckPlaces.map((deckPlace) => deckPlace.levelId), newLevelId];
    const firstLevelPlaceCount = levelIdsOfWord.filter(
      (levelId) => levelId === this.#generalLevelIds[0],
    ).length;
    return firstLevelPlaceCount === 1 && levelIdsOfWord.length <= 1 + MAX_REPEATS_PER_WORD;
  }
}

function readSeedTermIds(termIdsText) {
  return termIdsText.split(/\s+/).filter((termId) => termId.length > 0);
}

// Reads the decks seed: a deck line lists the words of one deck, a set line
// names the words of one set.
function parseDecksSeedFile(decksSeedPath, generalLevelIds) {
  const handDeckLayout = new HandDeckLayout(generalLevelIds);
  const seedLines = fs
    .readFileSync(decksSeedPath, 'utf8')
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith(DECKS_SEED_COMMENT_PREFIX));
  for (const line of seedLines) {
    const fields = line.split(DECKS_SEED_FIELD_SEPARATOR).map((field) => field.trim());
    const isSetLine = fields[0] === DECKS_SEED_SET_LINE_TAG;
    const expectedFieldCount = isSetLine ? DECKS_SEED_SET_FIELD_COUNT : DECKS_SEED_DECK_FIELD_COUNT;
    if (fields.length !== expectedFieldCount) {
      throw new Error(`decks seed: expected ${expectedFieldCount} fields in "${line}"`);
    }
    if (isSetLine) {
      const [, setName, termIdsText] = fields;
      for (const termId of readSeedTermIds(termIdsText)) handDeckLayout.nameSetOfWord(termId, setName);
    } else {
      const [levelId, deckId, deckName, termIdsText] = fields;
      for (const termId of readSeedTermIds(termIdsText)) {
        handDeckLayout.listWordInDeck(termId, levelId, deckId, deckName);
      }
    }
  }
  return handDeckLayout;
}

// The hand layout kept from the present word list, in the order its rows stand there.
function loadKeptDeckLayout(wordListPath, generalLevelIds) {
  const handDeckLayout = new HandDeckLayout(generalLevelIds);
  for (const record of readCsvRecords(wordListPath)) {
    if (record.deck_id !== '') {
      handDeckLayout.listWordInDeck(record.term_id, record.level, record.deck_id, record.deck_name);
    }
    const setName = record.set || '';
    if (setName !== '') handDeckLayout.nameSetOfWord(record.term_id, setName);
  }
  return handDeckLayout;
}

// ------------------------------------------------------------ additions list

// Reads the hand-kept additions list: one row per new word, with the source
// it comes from and whether it enters the list or waits.
function loadAdditionRecords(additionsListPath) {
  const additionRecords = [];
  const knownTermIds = new Set();
  for (const record of readCsvRecords(additionsListPath)) {
    if (!Object.values(AdditionDecision).includes(record.decision)) {
      throw new Error(`additions: "${record.term_id}" has the unknown decision "${record.decision}"`);
    }
    if (knownTermIds.has(record.term_id)) {
      throw new Error(`additions: "${record.term_id}" is listed twice`);
    }
    knownTermIds.add(record.term_id);
    additionRecords.push({
      source: record.source,
      termId: record.term_id,
      rank: record.rank === '' ? null : Number(record.rank),
      decision: record.decision,
      english: record.english,
      pos: record.pos,
      note: record.note,
    });
  }
  return additionRecords;
}

// ------------------------------------------------------------- ranking list

function groupPresentTermsByStoredRank(termsById) {
  const presentTermsByRank = new Map();
  const termsInIdOrder = [...termsById.values()].sort((first, second) =>
    first.id.localeCompare(second.id),
  );
  for (const term of termsInIdOrder) {
    if (term.cocaRank === null) continue;
    if (!presentTermsByRank.has(term.cocaRank)) presentTermsByRank.set(term.cocaRank, []);
    presentTermsByRank.get(term.cocaRank).push(term);
  }
  return presentTermsByRank;
}

function deriveTermIdFromRow(frequencyRow, rowPos) {
  const lemmaId = frequencyRow.lemma
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, inventory.TERM_ID_TOKEN_SEPARATOR)
    .replace(/^_+|_+$/g, '');
  return rowPos === DictionaryPos.verb ? `${VERB_TERM_ID_PREFIX}${lemmaId}` : lemmaId;
}

function deriveEnglishTextFromRow(frequencyRow, rowPos) {
  return rowPos === DictionaryPos.verb
    ? `${VERB_ENGLISH_PREFIX}${frequencyRow.lemma}`
    : frequencyRow.lemma;
}

// Two rows of one lemma give one card when the word stays the same: equal part
// of speech, two function words, or an adjective with its adverb.
function arePosValuesOfSameWord(firstPos, secondPos) {
  if (firstPos === secondPos) return true;
  if (FUNCTION_WORD_POS_VALUES.has(firstPos) && FUNCTION_WORD_POS_VALUES.has(secondPos)) return true;
  const posPair = new Set([firstPos, secondPos]);
  return posPair.has(DictionaryPos.adjective) && posPair.has(DictionaryPos.adverb);
}

class RankingListBuilder {
  #sources;
  #handLinesByRank;
  #presentTermsByRank;
  #handTiedRanksByTermId;
  #newCardPosByTermId = new Map();
  #lines = [];

  constructor(sources, handLinesByRank) {
    this.#sources = sources;
    this.#handLinesByRank = handLinesByRank;
    this.#presentTermsByRank = groupPresentTermsByStoredRank(sources.termsById);
    this.#handTiedRanksByTermId = collectHandTiedRanksByTermId(handLinesByRank, sources.termsById);
  }

  buildLinesInRankOrder() {
    for (const frequencyRow of this.#sources.frequencyRows) {
      this.#appendLinesOfFrequencyRow(frequencyRow);
    }
    return this.#lines;
  }

  #appendLinesOfFrequencyRow(frequencyRow) {
    const tiedTerms = this.#presentTermsByRank.get(frequencyRow.rank) || [];
    const handLines = this.#handLinesByRank.get(frequencyRow.rank) || [];
    let isRowOwnedByPresentTerm = false;
    for (const term of tiedTerms) {
      const handLine = handLines.find((candidate) => candidate.termId === term.id);
      const line = this.#buildPresentTermLine(frequencyRow, term, handLine);
      if (line.mark === RowMark.card) isRowOwnedByPresentTerm = true;
      this.#lines.push(line);
    }
    if (isRowOwnedByPresentTerm) return;
    const tiedTermIds = new Set(tiedTerms.map((term) => term.id));
    const rowHandLine = handLines.find((candidate) => !tiedTermIds.has(candidate.termId));
    this.#lines.push(this.#resolveRowWithoutOwner(frequencyRow, rowHandLine));
  }

  #buildPresentTermLine(frequencyRow, term, handLine) {
    const handTiedRank = this.#handTiedRanksByTermId.get(term.id);
    const isPlacedOnAnotherRow = handTiedRank !== undefined && handTiedRank !== frequencyRow.rank;
    const isBorrowedRank = handLine !== undefined && handLine.mark === RowMark.borrowed;
    let detail = handLine === undefined ? '' : handLine.detail;
    if (isPlacedOnAnotherRow) detail = `${RULE_DETAIL_PLACED_BY_HAND_PREFIX}${handTiedRank}`;
    return this.#buildLine(frequencyRow, {
      mark: isBorrowedRank || isPlacedOnAnotherRow ? RowMark.borrowed : RowMark.card,
      markBy: handLine === undefined || isPlacedOnAnotherRow ? MarkSource.rule : MarkSource.hand,
      detail,
      termId: term.id,
      english: this.#sources.englishEntries[term.id].text,
      pos: term.pos,
      status: resolveWordStatus(term.id, this.#sources.levelTermMembership),
    });
  }

  #resolveRowWithoutOwner(frequencyRow, handLine) {
    const rowPos = DICTIONARY_POS_BY_FREQUENCY_CODE[frequencyRow.posCode];
    if (handLine !== undefined && handLine.mark !== RowMark.card) {
      return this.#buildLine(frequencyRow, {
        mark: handLine.mark,
        markBy: MarkSource.hand,
        detail: handLine.detail,
      });
    }
    if (rowPos === undefined) {
      return this.#buildLine(frequencyRow, {
        mark: RowMark.skipped,
        markBy: MarkSource.rule,
        detail: RULE_DETAIL_UNKNOWN_POS_CODE,
      });
    }
    if (handLine !== undefined && handLine.termId !== '') {
      return this.#buildHandNamedCardLine(frequencyRow, rowPos, handLine);
    }
    return this.#resolveRowByNamingRules(frequencyRow, rowPos, handLine);
  }

  // A hand mark names the card of this row: a present term placed here by
  // hand, or a new card under the given id and English text.
  #buildHandNamedCardLine(frequencyRow, rowPos, handLine) {
    const presentTerm = this.#sources.termsById.get(handLine.termId);
    if (presentTerm !== undefined) {
      return this.#buildLine(frequencyRow, {
        mark: RowMark.card,
        markBy: MarkSource.hand,
        detail: handLine.detail,
        termId: presentTerm.id,
        english: this.#sources.englishEntries[presentTerm.id].text,
        pos: presentTerm.pos,
        status: resolveWordStatus(presentTerm.id, this.#sources.levelTermMembership),
      });
    }
    if (this.#newCardPosByTermId.has(handLine.termId)) {
      throw new Error(`hand mark at rank ${frequencyRow.rank}: id "${handLine.termId}" is already in use`);
    }
    const line = this.#buildNewCardLine(frequencyRow, rowPos, handLine.termId, MarkSource.hand, handLine.detail);
    if (handLine.english !== '') line.english = handLine.english;
    return line;
  }

  #resolveRowByNamingRules(frequencyRow, rowPos, handLine) {
    const derivedTermId = deriveTermIdFromRow(frequencyRow, rowPos);
    const suffixedTermId = `${derivedTermId}${TERM_ID_SUFFIX_BY_POS[rowPos] || ''}`;
    const markBy = handLine === undefined ? MarkSource.rule : MarkSource.hand;
    const note = handLine === undefined ? '' : handLine.detail;

    for (const candidateTermId of [derivedTermId, suffixedTermId]) {
      const existingPos = this.#findPosOfExistingCard(candidateTermId);
      if (existingPos === null) continue;
      if (arePosValuesOfSameWord(existingPos, rowPos)) {
        return this.#buildLineForExistingWord(frequencyRow, candidateTermId);
      }
    }
    const freeTermId = this.#findPosOfExistingCard(derivedTermId) === null ? derivedTermId : suffixedTermId;
    return this.#buildNewCardLine(frequencyRow, rowPos, freeTermId, markBy, note);
  }

  #findPosOfExistingCard(termId) {
    const presentTerm = this.#sources.termsById.get(termId);
    if (presentTerm !== undefined) return presentTerm.pos;
    return this.#newCardPosByTermId.has(termId) ? this.#newCardPosByTermId.get(termId) : null;
  }

  // The row names a word that already has a card: a present term without a
  // stored rank takes this row; any other card absorbs the row.
  #buildLineForExistingWord(frequencyRow, existingTermId) {
    const presentTerm = this.#sources.termsById.get(existingTermId);
    if (presentTerm !== undefined && presentTerm.cocaRank === null) {
      return this.#buildLine(frequencyRow, {
        mark: RowMark.card,
        markBy: MarkSource.rule,
        detail: RULE_DETAIL_TIED_BY_NAME,
        termId: presentTerm.id,
        english: this.#sources.englishEntries[presentTerm.id].text,
        pos: presentTerm.pos,
        status: resolveWordStatus(presentTerm.id, this.#sources.levelTermMembership),
      });
    }
    return this.#buildLine(frequencyRow, {
      mark: RowMark.merged,
      markBy: MarkSource.rule,
      detail: existingTermId,
    });
  }

  #buildNewCardLine(frequencyRow, rowPos, termId, markBy, note) {
    this.#newCardPosByTermId.set(termId, rowPos);
    return this.#buildLine(frequencyRow, {
      mark: RowMark.card,
      markBy,
      detail: note,
      termId,
      english: deriveEnglishTextFromRow(frequencyRow, rowPos),
      pos: rowPos,
      status: WordStatus.added,
    });
  }

  #buildLine(frequencyRow, lineFields) {
    return {
      rank: frequencyRow.rank,
      lemma: frequencyRow.lemma,
      posCode: frequencyRow.posCode,
      mark: lineFields.mark,
      markBy: lineFields.markBy,
      detail: lineFields.detail || '',
      termId: lineFields.termId || '',
      english: lineFields.english || '',
      pos: lineFields.pos || '',
      status: lineFields.status || '',
    };
  }
}

// --------------------------------------------------------------- word entries

// The card line of every word a frequency row gives a card to.
function indexCardLinesByTermId(rankingLines) {
  return new Map(
    rankingLines.filter((line) => line.mark === RowMark.card).map((line) => [line.termId, line]),
  );
}

// One entry per present general word, in the order the app lists them. Every
// one of them stays in the levels, with or without a frequency row.
function collectPresentWordEntries(sources, cardLineByTermId) {
  const presentEntries = [];
  const knownTermIds = new Set();
  for (const level of sources.levelDeckStructure.levels) {
    if (level.id === inventory.SPECIALIZED_LEVEL_ID) continue;
    for (const deckId of level.deckIds) {
      for (const termId of sources.levelDeckStructure.decksById.get(deckId).termIds) {
        if (knownTermIds.has(termId)) continue;
        knownTermIds.add(termId);
        const cardLine = cardLineByTermId.get(termId);
        presentEntries.push({
          termId,
          english: sources.englishEntries[termId].text,
          pos: sources.termsById.get(termId).pos,
          rank: cardLine === undefined ? '' : cardLine.rank,
          source: level.id,
          status: WordStatus.kept,
          note: cardLine === undefined ? '' : cardLine.detail,
        });
      }
    }
  }
  return presentEntries;
}

// The card line an addition names by its rank. A row that gives its card to
// another word, or a word listed without the row it has, stops the run.
function findCardLineOfAddition(additionRecord, cardLineByTermId) {
  const cardLine = cardLineByTermId.get(additionRecord.termId);
  if (additionRecord.rank === null) {
    if (cardLine !== undefined) {
      throw new Error(
        `additions: "${additionRecord.termId}" has the frequency row ${cardLine.rank}; name that rank`,
      );
    }
    return undefined;
  }
  if (cardLine === undefined || cardLine.rank !== additionRecord.rank) {
    throw new Error(
      `additions: the frequency row ${additionRecord.rank} gives no card to "${additionRecord.termId}"`,
    );
  }
  return cardLine;
}

// The English text and part of speech of an addition: from the app's
// dictionary when the word sits in Specialized, else from its frequency row,
// else from the additions list itself. A text typed where a source already
// gives it is refused, so no word is described twice.
function resolveTextAndPosOfAddition(additionRecord, sources, cardLine) {
  const { termId } = additionRecord;
  const dictionaryTerm = sources.termsById.get(termId);
  const isDescribedInList = additionRecord.english !== '' || additionRecord.pos !== '';
  if (dictionaryTerm === undefined && cardLine === undefined) {
    const hasKnownPos = Object.values(DictionaryPos).includes(additionRecord.pos);
    if (additionRecord.english === '' || !hasKnownPos) {
      throw new Error(
        `additions: "${termId}" has no frequency row; it needs an English text and a part of speech`,
      );
    }
    return { english: additionRecord.english, pos: additionRecord.pos };
  }
  if (isDescribedInList) {
    throw new Error(
      `additions: "${termId}" takes its text from the app or its frequency row; leave english and pos empty`,
    );
  }
  return dictionaryTerm === undefined
    ? { english: cardLine.english, pos: cardLine.pos }
    : { english: sources.englishEntries[termId].text, pos: dictionaryTerm.pos };
}

// One entry per row of the additions list, entering or waiting.
function buildAdditionEntries(additionRecords, sources, cardLineByTermId) {
  const presentGeneralTermIds = sources.levelTermMembership.generalDeckIdsByTermId;
  return additionRecords.map((additionRecord) => {
    if (presentGeneralTermIds.has(additionRecord.termId)) {
      throw new Error(`additions: "${additionRecord.termId}" is a present general word`);
    }
    const cardLine = findCardLineOfAddition(additionRecord, cardLineByTermId);
    const textAndPos = resolveTextAndPosOfAddition(additionRecord, sources, cardLine);
    return {
      termId: additionRecord.termId,
      english: textAndPos.english,
      pos: textAndPos.pos,
      rank: additionRecord.rank === null ? '' : additionRecord.rank,
      source: additionRecord.source,
      status: resolveWordStatus(additionRecord.termId, sources.levelTermMembership),
      note: additionRecord.note,
      decision: additionRecord.decision,
    };
  });
}

// ------------------------------------------------------------------ placement

// Counts the seats still free in each general level.
class LevelSeats {
  #freeSeatCountByLevelId;

  constructor(generalLevelIds) {
    this.#freeSeatCountByLevelId = new Map(
      generalLevelIds.map((levelId) => [levelId, LEVEL_WORD_COUNT]),
    );
  }

  hasFreeSeatInLevel(levelId) {
    return this.#freeSeatCountByLevelId.get(levelId) > 0;
  }

  takeSeatInLevel(levelId, termId) {
    if (!this.hasFreeSeatInLevel(levelId)) {
      throw new Error(
        `level ${levelId}: no seat is left for "${termId}"; its decks list more than ${LEVEL_WORD_COUNT} cards`,
      );
    }
    this.#freeSeatCountByLevelId.set(levelId, this.#freeSeatCountByLevelId.get(levelId) - 1);
  }
}

// The deck a word sits in and, for a Top 100 word listed a second time, the
// deck that repeats it.
function splitDeckPlacesOfWord(termId, handDeckLayout, firstLevelId) {
  const deckPlaces = handDeckLayout.findDeckPlacesOfWord(termId);
  if (deckPlaces.length <= 1) return { homeDeckPlace: deckPlaces[0], repeatDeckPlace: undefined };
  return {
    homeDeckPlace: deckPlaces.find((deckPlace) => deckPlace.levelId === firstLevelId),
    repeatDeckPlace: deckPlaces.find((deckPlace) => deckPlace.levelId !== firstLevelId),
  };
}

// The words no deck lists yet fill the seats the decks leave, level after level, in source order.
function fillFreeSeatsInSourceOrder(unlistedEntries, generalLevelIds, levelSeats, levelIdByTermId) {
  let levelIndex = 0;
  for (const entry of unlistedEntries) {
    while (levelIndex < generalLevelIds.length && !levelSeats.hasFreeSeatInLevel(generalLevelIds[levelIndex])) {
      levelIndex += 1;
    }
    if (levelIndex === generalLevelIds.length) {
      throw new Error(`no level has a seat left for "${entry.termId}"`);
    }
    levelSeats.takeSeatInLevel(generalLevelIds[levelIndex], entry.termId);
    levelIdByTermId.set(entry.termId, generalLevelIds[levelIndex]);
  }
}

function rejectLayoutIdsOutsideTheList(placedEntries, handDeckLayout) {
  const placedTermIds = new Set(placedEntries.map((entry) => entry.termId));
  const outsideTermIds = [...handDeckLayout.collectListedTermIds()].filter(
    (termId) => !placedTermIds.has(termId),
  );
  if (outsideTermIds.length > 0) {
    throw new Error(
      `hand layout: ${outsideTermIds.length} ids name no word of the list: ${outsideTermIds.join(' ')}`,
    );
  }
}

// Gives every word of the list its level: a word listed in a deck sits in that
// deck's level, and a word no deck lists fills a free seat. A Top 100 word
// listed a second time, inside a set, is repeated in that deck. Returns the
// level of every word and the deck places of the repeats.
function placeWordsInLevels(placedEntries, handDeckLayout, generalLevelIds) {
  rejectLayoutIdsOutsideTheList(placedEntries, handDeckLayout);
  const firstLevelId = generalLevelIds[0];
  const levelSeats = new LevelSeats(generalLevelIds);
  const levelIdByTermId = new Map();
  const repeatDeckPlaceByTermId = new Map();
  const unlistedEntries = [];
  for (const entry of placedEntries) {
    const { homeDeckPlace, repeatDeckPlace } = splitDeckPlacesOfWord(
      entry.termId,
      handDeckLayout,
      firstLevelId,
    );
    if (homeDeckPlace === undefined) {
      unlistedEntries.push(entry);
      continue;
    }
    levelSeats.takeSeatInLevel(homeDeckPlace.levelId, entry.termId);
    levelIdByTermId.set(entry.termId, homeDeckPlace.levelId);
    if (repeatDeckPlace === undefined) continue;
    if (handDeckLayout.findSetNameOfWord(entry.termId) === '') {
      throw new Error(
        `hand layout: "${entry.termId}" is repeated in "${repeatDeckPlace.deckId}" without belonging to a set`,
      );
    }
    levelSeats.takeSeatInLevel(repeatDeckPlace.levelId, entry.termId);
    repeatDeckPlaceByTermId.set(entry.termId, repeatDeckPlace);
  }
  fillFreeSeatsInSourceOrder(unlistedEntries, generalLevelIds, levelSeats, levelIdByTermId);
  return { levelIdByTermId, repeatDeckPlaceByTermId };
}

function toRankingListRecord(line, levelIdByTermId) {
  return {
    rank: line.rank,
    lemma: line.lemma,
    pos_code: line.posCode,
    mark: line.mark,
    mark_by: line.markBy,
    detail: line.detail,
    term_id: line.termId,
    english: line.english,
    pos: line.pos,
    status: line.status,
    level: line.mark === RowMark.card ? levelIdByTermId.get(line.termId) || '' : '',
  };
}

// ------------------------------------------------------------------ word list

// One row per card: every word in its level, and every repeated Top 100 word a
// second time in the deck of its set. The set name stands on the rows of the
// later levels only. The rows of a deck keep the order the deck lists them.
function buildWordListRecords(placedEntries, placement, handDeckLayout, generalLevelIds) {
  const firstLevelId = generalLevelIds[0];
  const segmentIdByLevelId = buildSegmentIdByLevelId(generalLevelIds);
  const records = [];
  placedEntries.forEach((entry, sourceOrder) => {
    const buildRecordInLevel = (levelId, status, note) => {
      const deckPlace = handDeckLayout.findDeckPlaceInLevel(entry.termId, levelId);
      return {
        segment: segmentIdByLevelId.get(levelId),
        level: levelId,
        deck_id: deckPlace === undefined ? '' : deckPlace.deckId,
        deck_name: deckPlace === undefined ? '' : deckPlace.deckName,
        term_id: entry.termId,
        english: entry.english,
        pos: entry.pos,
        rank: entry.rank,
        source: entry.source,
        status,
        set: levelId === firstLevelId ? '' : handDeckLayout.findSetNameOfWord(entry.termId),
        note,
        deckOrder: deckPlace === undefined ? Number.MAX_SAFE_INTEGER : deckPlace.deckOrder,
        wordOrder: deckPlace === undefined ? sourceOrder : deckPlace.wordOrder,
      };
    };
    records.push(buildRecordInLevel(placement.levelIdByTermId.get(entry.termId), entry.status, entry.note));
    const repeatDeckPlace = placement.repeatDeckPlaceByTermId.get(entry.termId);
    if (repeatDeckPlace !== undefined) {
      records.push(buildRecordInLevel(repeatDeckPlace.levelId, WordStatus.repeated, ''));
    }
  });
  return records.sort(
    (first, second) =>
      generalLevelIds.indexOf(first.level) - generalLevelIds.indexOf(second.level) ||
      first.deckOrder - second.deckOrder ||
      first.wordOrder - second.wordOrder,
  );
}

// --------------------------------------------------------------- outside list

function isEnteringAddition(additionEntry) {
  return additionEntry.decision === AdditionDecision.enter;
}

function resolveReasonOfWordOutsideList(termId, waitingEntryByTermId, levelTermMembership) {
  if (waitingEntryByTermId.has(termId)) return OutsideReason.waiting;
  if (levelTermMembership.specializedDeckIdsByTermId.has(termId)) return OutsideReason.specializedOnly;
  return OutsideReason.inNeitherSource;
}

function toOutsideListRecord(line, wordFields) {
  return {
    rank: line.rank,
    lemma: line.lemma,
    pos_code: line.posCode,
    term_id: wordFields.termId || '',
    english: wordFields.english || '',
    pos: wordFields.pos || '',
    reason: wordFields.reason,
    note: wordFields.note || '',
  };
}

// Goes through the frequency rows down to the rank limit and sorts each into
// one of three: the first row of a word of the list, the first row of a word
// outside it, or a second row of a word already met. A word outside the list
// gives one line, at its commonest row, with the reason; so does a row left
// without a word. A row that gives two cards stands on two lines. Returns the
// lines of the outside list and the count of lines of each kind.
function buildOutsideListing(rankingLines, additionEntries, placement, sources) {
  const cardLineByTermId = indexCardLinesByTermId(rankingLines);
  const waitingEntryByTermId = new Map(
    additionEntries.filter((entry) => !isEnteringAddition(entry)).map((entry) => [entry.termId, entry]),
  );
  const metTermIds = new Set();
  const records = [];
  const rowLines = rankingLines.filter(
    (line) => line.rank <= OUTSIDE_LIST_RANK_LIMIT && line.mark !== RowMark.borrowed,
  );
  const rowAccount = {
    rowCount: new Set(rowLines.map((line) => line.rank)).size,
    lineCount: rowLines.length,
    listedWordCount: 0,
    secondRowCount: 0,
  };
  for (const line of rowLines) {
    if (line.mark === RowMark.skipped) {
      const reason = line.markBy === MarkSource.hand ? OutsideReason.leftOutByHand : OutsideReason.withoutCardForm;
      records.push(toOutsideListRecord(line, { reason, note: line.detail }));
      continue;
    }
    const termId = line.mark === RowMark.card ? line.termId : line.detail;
    if (metTermIds.has(termId)) {
      rowAccount.secondRowCount += 1;
      continue;
    }
    metTermIds.add(termId);
    if (placement.levelIdByTermId.has(termId)) {
      rowAccount.listedWordCount += 1;
      continue;
    }
    const cardLine = cardLineByTermId.get(termId);
    const waitingEntry = waitingEntryByTermId.get(termId);
    records.push(
      toOutsideListRecord(line, {
        termId,
        english: cardLine === undefined ? '' : cardLine.english,
        pos: cardLine === undefined ? '' : cardLine.pos,
        reason: resolveReasonOfWordOutsideList(termId, waitingEntryByTermId, sources.levelTermMembership),
        note: waitingEntry === undefined ? '' : waitingEntry.note,
      }),
    );
  }
  return { records, rowAccount };
}

// ------------------------------------------------------------------ printing

function printCompactItems(items) {
  const ITEMS_PER_PRINTED_LINE = 6;
  for (let index = 0; index < items.length; index += ITEMS_PER_PRINTED_LINE) {
    console.log(items.slice(index, index + ITEMS_PER_PRINTED_LINE).join(COMPACT_PRINT_SEPARATOR));
  }
}

function countItemsByKey(items, readKeyOfItem) {
  const countByKey = new Map();
  for (const item of items) {
    const key = readKeyOfItem(item);
    countByKey.set(key, (countByKey.get(key) || 0) + 1);
  }
  return countByKey;
}

function printAdditionCountsBySource(additionEntries) {
  const enteringCountBySource = countItemsByKey(
    additionEntries.filter(isEnteringAddition),
    (additionEntry) => additionEntry.source,
  );
  const sourceLabels = [...countItemsByKey(additionEntries, (additionEntry) => additionEntry.source)].map(
    ([source, rowCount]) => {
      const enteringCount = enteringCountBySource.get(source) || 0;
      return `${source}: ${rowCount} (${enteringCount} enter, ${rowCount - enteringCount} wait)`;
    },
  );
  console.log('additions by source:');
  printCompactItems(sourceLabels);
}

function printLadderOfSegments(generalLevelIds) {
  const segmentLabels = SEGMENT_LADDER.map((segment) => `${segment.id} ${segment.levelCount}`);
  console.log(
    `levels: ${generalLevelIds.length} in ${SEGMENT_LADDER.length} segments (${segmentLabels.join(', ')})`,
  );
}

// The rows down to the rank limit, split into the three kinds they were sorted
// into, and the lines of the outside list counted by reason.
function printOutsideListAccount(outsideListing) {
  const { records, rowAccount } = outsideListing;
  const reasonLabels = [...countItemsByKey(records, (record) => record.reason)].map(
    ([reason, lineCount]) => `${reason}: ${lineCount}`,
  );
  console.log(
    `frequency rows down to rank ${OUTSIDE_LIST_RANK_LIMIT}: ${rowAccount.rowCount} rows on ` +
      `${rowAccount.lineCount} lines = ${rowAccount.listedWordCount} words of the list + ` +
      `${records.length} lines outside the list + ${rowAccount.secondRowCount} second rows`,
  );
  console.log('outside the list by reason:');
  printCompactItems(reasonLabels);
  const leftOutRecords = records.filter((record) => record.reason === OutsideReason.leftOutByHand);
  console.log('left out by hand, by note:');
  printCompactItems(
    [...countItemsByKey(leftOutRecords, (record) => record.note)].map(
      ([note, lineCount]) => `${note}: ${lineCount}`,
    ),
  );
}

function printJoinSummary(joinResult) {
  const { rankingLines, presentEntries, additionEntries, wordListRecords, placement } = joinResult;
  const placedPresentCount = presentEntries.filter((entry) =>
    placement.levelIdByTermId.has(entry.termId),
  ).length;
  const enteringCount = additionEntries.filter(isEnteringAddition).length;
  const statusLabels = [...countItemsByKey(wordListRecords, (record) => record.status)].map(
    ([status, cardCount]) => `${status} ${cardCount}`,
  );
  const repeatCount = placement.repeatDeckPlaceByTermId.size;
  const setCount = joinResult.handDeckLayout.collectTermIdsBySetName().size;
  const cardCountWithoutDeck = wordListRecords.filter((record) => record.deck_id === '').length;
  const cardTermIds = new Set(indexCardLinesByTermId(rankingLines).keys());
  const mergeLinesWithoutTarget = rankingLines.filter(
    (line) => line.mark === RowMark.merged && !cardTermIds.has(line.detail),
  );

  console.log(`frequency rows read: ${joinResult.sources.frequencyRows.length}`);
  printLadderOfSegments(joinResult.generalLevelIds);
  console.log(`present general words placed: ${placedPresentCount} of ${presentEntries.length}`);
  console.log(
    `additions: ${additionEntries.length} rows, ${enteringCount} enter, ` +
      `${additionEntries.length - enteringCount} wait`,
  );
  printAdditionCountsBySource(additionEntries);
  console.log(`cards placed: ${wordListRecords.length} (${statusLabels.join(', ')})`);
  console.log(
    `distinct words: ${wordListRecords.length - repeatCount}; repeats: ${repeatCount}; sets: ${setCount}`,
  );
  console.log(`cards without a deck: ${cardCountWithoutDeck}`);
  printOutsideListAccount(joinResult.outsideListing);
  console.log(`merged rows whose target is not a card: ${mergeLinesWithoutTarget.length}`);
  for (const line of mergeLinesWithoutTarget) {
    console.log(`  ${line.rank} ${line.lemma}/${line.posCode} -> ${line.detail}`);
  }
}

// Every level deck by deck, the words in the order their deck lists them; a
// repeated Top 100 word carries a star.
function printLevelsSection(joinResult) {
  const REPEAT_LABEL_PREFIX = '*';
  for (const levelId of joinResult.generalLevelIds) {
    const levelRecords = joinResult.wordListRecords.filter((record) => record.level === levelId);
    console.log(`== ${levelId} (${levelRecords.length})`);
    const deckIds = [...new Set(levelRecords.map((record) => record.deck_id))];
    for (const deckId of deckIds) {
      const deckRecords = levelRecords.filter((record) => record.deck_id === deckId);
      const deckLabel = deckId === '' ? 'no deck' : `${deckId} "${deckRecords[0].deck_name}"`;
      console.log(`-- ${deckLabel} (${deckRecords.length})`);
      printCompactItems(
        deckRecords.map((record) =>
          record.status === WordStatus.repeated ? `${REPEAT_LABEL_PREFIX}${record.english}` : record.english,
        ),
      );
    }
  }
}

// The deck a set gathers a word into: the deck that repeats a Top 100 word,
// the word's own deck otherwise. A Top 100 word that is not repeated has none.
function findSetDeckPlaceOfWord(termId, joinResult) {
  const { placement, handDeckLayout, generalLevelIds } = joinResult;
  const repeatDeckPlace = placement.repeatDeckPlaceByTermId.get(termId);
  if (repeatDeckPlace !== undefined) return repeatDeckPlace;
  const levelId = placement.levelIdByTermId.get(termId);
  return levelId === generalLevelIds[0] ? undefined : handDeckLayout.findDeckPlaceInLevel(termId, levelId);
}

// Every set with its deck and its words. A set is whole when all its words
// sit in one deck of a later level.
function printSetsSection(joinResult) {
  const { placement, handDeckLayout } = joinResult;
  const termIdsBySetName = handDeckLayout.collectTermIdsBySetName();
  let wholeSetCount = 0;
  for (const [setName, termIds] of termIdsBySetName) {
    const deckLabels = new Set();
    let hasMemberOutsideSetDeck = false;
    const memberLabels = termIds.map((termId) => {
      const deckPlace = findSetDeckPlaceOfWord(termId, joinResult);
      if (deckPlace === undefined) {
        hasMemberOutsideSetDeck = true;
        return `${termId}[${SET_MEMBER_LABEL_OUTSIDE_SET_DECK}]`;
      }
      deckLabels.add(`${deckPlace.levelId}/${deckPlace.deckId}`);
      return placement.repeatDeckPlaceByTermId.has(termId) ? `${termId}[${WordStatus.repeated}]` : termId;
    });
    const isWholeSet = deckLabels.size === 1 && !hasMemberOutsideSetDeck;
    if (isWholeSet) wholeSetCount += 1;
    console.log(`== ${setName} -> ${[...deckLabels].join(' + ') || 'no deck'}${isWholeSet ? '' : '  NOT WHOLE'}`);
    printCompactItems(memberLabels);
  }
  console.log(
    `sets: ${termIdsBySetName.size}; whole: ${wholeSetCount}; repeats: ${placement.repeatDeckPlaceByTermId.size}`,
  );
}

// The words of the additions list that wait, source by source.
function printReserveSection(joinResult) {
  const waitingEntries = joinResult.additionEntries.filter((entry) => !isEnteringAddition(entry));
  const sources = [...new Set(waitingEntries.map((entry) => entry.source))];
  for (const source of sources) {
    const sourceEntries = waitingEntries.filter((entry) => entry.source === source);
    console.log(`== ${source} (${sourceEntries.length})`);
    printCompactItems(sourceEntries.map((entry) => entry.english));
  }
  console.log(`waiting words: ${waitingEntries.length}`);
}

const SECTION_PRINTER_BY_NAME = Object.freeze({
  [PrintSection.levels]: printLevelsSection,
  [PrintSection.sets]: printSetsSection,
  [PrintSection.reserve]: printReserveSection,
});

function printRequestedSection(printSection, joinResult) {
  if (printSection === null) return;
  const printSectionOfResult = SECTION_PRINTER_BY_NAME[printSection];
  if (printSectionOfResult === undefined) {
    throw new Error(`unknown section "${printSection}"; known: ${Object.values(PrintSection).join(', ')}`);
  }
  printSectionOfResult(joinResult);
}

// ---------------------------------------------------------------------- main

function parseCommandLineOptions(argumentList) {
  const options = {
    dataDirectory: inventory.DEFAULT_DATA_DIRECTORY,
    earlierAppDirectory: DEFAULT_EARLIER_APP_DIRECTORY,
    listsDirectory: DEFAULT_LISTS_DIRECTORY,
    marksSeedPath: null,
    decksSeedPath: null,
    printSection: null,
  };
  const optionKeyByFlag = {
    '--data': 'dataDirectory',
    '--before': 'earlierAppDirectory',
    '--lists': 'listsDirectory',
    '--marks-seed': 'marksSeedPath',
    '--decks-seed': 'decksSeedPath',
    '--print': 'printSection',
  };
  for (let index = 0; index < argumentList.length; index += 2) {
    const optionKey = optionKeyByFlag[argumentList[index]];
    if (optionKey === undefined || argumentList[index + 1] === undefined) {
      throw new Error(`unknown or incomplete option "${argumentList[index]}"`);
    }
    options[optionKey] = argumentList[index + 1];
  }
  return options;
}

// The app's words, levels and decks come from the earlier app; the frequency
// file comes from the live data.
function loadJoinSources(dataDirectory, earlierAppDirectory) {
  const levelDeckStructure = inventory.loadLevelDeckStructure(earlierAppDirectory);
  return {
    termsById: inventory.loadDictionaryTermsById(earlierAppDirectory),
    levelDeckStructure,
    levelTermMembership: inventory.collectLevelTermMembership(levelDeckStructure),
    frequencyRows: inventory.loadFrequencyRowsInRankOrder(dataDirectory),
    englishEntries: inventory.loadTranslationEntriesByLanguage(earlierAppDirectory).get(ENGLISH_LANGUAGE_CODE),
  };
}

function refreshReviewLists(options) {
  const rankingListPath = path.join(options.listsDirectory, RANKING_LIST_FILE_NAME);
  const wordListPath = path.join(options.listsDirectory, WORD_LIST_FILE_NAME);
  const additionsListPath = path.join(options.listsDirectory, ADDITIONS_LIST_FILE_NAME);
  const generalLevelIds = buildGeneralLevelIds();
  const sources = loadJoinSources(options.dataDirectory, options.earlierAppDirectory);

  const handLinesByRank = loadHandMarkLinesByRank(rankingListPath, options.marksSeedPath);
  const rankingLines = new RankingListBuilder(sources, handLinesByRank).buildLinesInRankOrder();
  const cardLineByTermId = indexCardLinesByTermId(rankingLines);
  const presentEntries = collectPresentWordEntries(sources, cardLineByTermId);
  const additionEntries = buildAdditionEntries(
    loadAdditionRecords(additionsListPath),
    sources,
    cardLineByTermId,
  );
  const placedEntries = [...presentEntries, ...additionEntries.filter(isEnteringAddition)];
  const handDeckLayout = options.decksSeedPath
    ? parseDecksSeedFile(options.decksSeedPath, generalLevelIds)
    : loadKeptDeckLayout(wordListPath, generalLevelIds);
  const placement = placeWordsInLevels(placedEntries, handDeckLayout, generalLevelIds);
  const wordListRecords = buildWordListRecords(placedEntries, placement, handDeckLayout, generalLevelIds);

  writeCsvRecords(
    rankingListPath,
    RANKING_LIST_COLUMNS,
    rankingLines.map((line) => toRankingListRecord(line, placement.levelIdByTermId)),
  );
  writeCsvRecords(wordListPath, WORD_LIST_COLUMNS, wordListRecords);
  const outsideListing = buildOutsideListing(rankingLines, additionEntries, placement, sources);
  writeCsvRecords(
    path.join(options.listsDirectory, OUTSIDE_LIST_FILE_NAME),
    OUTSIDE_LIST_COLUMNS,
    outsideListing.records,
  );

  const joinResult = {
    sources,
    rankingLines,
    presentEntries,
    additionEntries,
    wordListRecords,
    outsideListing,
    placement,
    handDeckLayout,
    generalLevelIds,
  };
  printJoinSummary(joinResult);
  printRequestedSection(options.printSection, joinResult);
}

if (require.main === module) {
  refreshReviewLists(parseCommandLineOptions(process.argv.slice(2)));
}

module.exports = {
  RANKING_LIST_FILE_NAME,
  WORD_LIST_FILE_NAME,
  ADDITIONS_LIST_FILE_NAME,
  LEVEL_WORD_COUNT,
  MAX_REPEATS_PER_WORD,
  DEFAULT_LISTS_DIRECTORY,
  DEFAULT_EARLIER_APP_DIRECTORY,
  DECKS_SEED_FIELD_SEPARATOR,
  DECKS_SEED_SET_LINE_TAG,
  DECKS_SEED_COMMENT_PREFIX,
  ListColumn,
  RowMark,
  WordStatus,
  AdditionDecision,
  buildGeneralLevelIds,
  readCsvRecords,
  loadAdditionRecords,
};
